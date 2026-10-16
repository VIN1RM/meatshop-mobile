import 'dart:convert';
import 'package:provider/provider.dart';
import '../providers/auth/auth_provider.dart' as app_auth;
import '../ui/screens/orders/order_tracking_screen.dart';
import '../ui/screens/fallback/order_processing_screen.dart';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:meatshop_mobile/models/notification_model.dart';
import 'package:meatshop_mobile/routes/app_routes.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:meatshop_mobile/ui/widgets/in_app_notification_banner.dart';
import 'package:meatshop_mobile/services/user_preferences_service.dart';
import 'package:meatshop_mobile/data/repositories/notification_repository.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'dart:io' show Platform;

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final _messaging = FirebaseMessaging.instance;
  final _localNotifications = FlutterLocalNotificationsPlugin();
  NotificationRepository? _backend;
  String? _registeredToken;
  Map<String, dynamic>? _pendingData;
  bool _opening = false;

  Future<void> resumePending() async {
    final data = _pendingData;
    if (data == null || _opening) return;
    await _navigateAfterRefresh(data);
  }

  static const _channelId = 'meatshop_channel';
  static const _channelName = 'MeatShop Notificações';
  static const _channelDesc = 'Pedidos, entregas e promoções';

  GlobalKey<NavigatorState>? navigatorKey;

  void configure({required NotificationRepository backend}) {
    _backend = backend;
  }

  Future<void> initialize({
    required GlobalKey<NavigatorState> navigatorKey,
  }) async {
    this.navigatorKey = navigatorKey;

    await _requestPermission();
    await _setupLocalNotifications();
    _setupForegroundHandler();
    _setupMessageOpenedHandler();
    await _checkInitialMessage();
    _messaging.onTokenRefresh.listen((newToken) async {
      await _registerBackendToken(newToken);
    });
  }

  Future<void> _requestPermission() async {
    await _messaging.requestPermission(alert: true, badge: true, sound: true);
  }

  Future<void> _setupLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    await _localNotifications.initialize(
      const InitializationSettings(android: androidSettings, iOS: iosSettings),
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    final androidPlugin = _localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    await androidPlugin?.createNotificationChannel(
      const AndroidNotificationChannel(
        _channelId,
        _channelName,
        description: _channelDesc,
        importance: Importance.high,
      ),
    );
  }

  void _setupForegroundHandler() {
    FirebaseMessaging.onMessage.listen((message) async {
      final context = navigatorKey?.currentContext;
      if (context == null) return;

      final type = (message.data['type'] as String? ?? 'SYSTEM').toUpperCase();
      if (!await _isTypeAllowed(type)) return;
      if (!context.mounted) return;

      final notification = message.notification;
      final data = message.data;

      InAppNotificationBanner.show(
        context: context,
        title: notification?.title ?? data['title'] as String? ?? 'MeatShop',
        message:
            notification?.body ??
            data['message'] as String? ??
            data['body'] as String? ??
            'Você recebeu uma nova notificação',
        type: data['type'] as String? ?? 'SYSTEM',
        onTap: () => _handleNavigation(message),
      );
    });
  }

  Future<bool> _isTypeAllowed(String type) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return true;
    final prefs = await UserPreferencesService.instance.load(uid);
    return switch (type) {
      'ORDER' => prefs.notifOrders,
      'DELIVERY' => prefs.notifDelivery,
      'PROMOTION' => prefs.notifPromotions,
      'SYSTEM' => prefs.notifSystem,
      _ => true,
    };
  }

  void _setupMessageOpenedHandler() {
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNavigation);
  }

  Future<void> _checkInitialMessage() async {
    final initial = await _messaging.getInitialMessage();
    if (initial != null) {
      await Future.delayed(const Duration(milliseconds: 500));
      _handleNavigation(initial);
    }
  }

  void _onNotificationTap(NotificationResponse response) {
    if (response.payload == null) return;
    try {
      final data = jsonDecode(response.payload!) as Map<String, dynamic>;
      _navigateAfterRefresh(data);
    } catch (_) {}
  }

  Future<void> showLocalNotification(RemoteMessage message) async {
    final content = notificationContent(message);

    final androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDesc,
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    await _localNotifications.show(
      message.hashCode,
      content.title,
      content.body,
      NotificationDetails(
        android: androidDetails,
        iOS: const DarwinNotificationDetails(),
      ),
      payload: jsonEncode(message.data),
    );
  }

  Future<void> showBackgroundNotification(RemoteMessage message) async {
    await _setupLocalNotifications();
    await showLocalNotification(message);
  }

  @visibleForTesting
  static ({String title, String body}) notificationContent(
    RemoteMessage message,
  ) {
    final data = message.data;
    return (
      title:
          message.notification?.title ?? data['title'] as String? ?? 'MeatShop',
      body:
          message.notification?.body ??
          data['message'] as String? ??
          data['body'] as String? ??
          'Você recebeu uma nova notificação',
    );
  }

  Future<void> _handleNavigation(RemoteMessage message) async {
    await _navigateAfterRefresh(message.data);
  }

  Future<void> _navigateAfterRefresh(Map<String, dynamic> data) async {
    _pendingData = data;
    final context = navigatorKey?.currentContext;
    if (_opening || context == null) return;
    final auth = context.read<app_auth.AuthProvider>();
    if (!auth.isAuthenticated ||
        auth.needsProfileCompletion ||
        auth.activeProfile == null) {
      return;
    }
    final owner = auth.backendUserId;
    final id = '${data['notification_id'] ?? ''}';
    if (id.isEmpty) {
      _pendingData = null;
      return;
    }
    _opening = true;
    try {
      NotificationModel? item;
      for (var page = 1; page <= 20; page++) {
        final items = await _backend!.list(page: page);
        item = items.where((entry) => entry.id == id).firstOrNull;
        if (item != null || items.length < 50) break;
      }
      if (item == null) {
        _pendingData = null;
        return;
      }
      if (!context.mounted ||
          !auth.isAuthenticated ||
          auth.backendUserId != owner) {
        return;
      }
      await _backend!.markAsRead(id);
      _pendingData = null;
      final nav = navigatorKey?.currentState;
      if (nav == null) {
        _pendingData = data;
        return;
      }
      final path = '${item.payload?['action_url'] ?? ''}';
      final match = RegExp(r'^/orders/(\d+)$').firstMatch(path);
      final orderId = match == null ? null : int.tryParse(match.group(1)!);
      if (item.type == NotificationType.promotion) {
        nav.pushNamed(AppRoutes.butchers);
      } else if (item.type == NotificationType.order ||
          item.type == NotificationType.delivery) {
        if (auth.isDelivery) {
          nav.pushNamedAndRemoveUntil(AppRoutes.deliveryShell, (_) => false);
        } else if (orderId != null) {
          nav.push(
            MaterialPageRoute(
              builder: (_) => item!.type == NotificationType.delivery
                  ? OrderTrackingScreen(orderId: orderId)
                  : OrderProcessingScreen(orderIds: ['$orderId']),
            ),
          );
        } else {
          nav.pushNamed(AppRoutes.deliveries);
        }
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.maybeOf(context)?.showSnackBar(
          const SnackBar(
            content: Text(
              'Não foi possível abrir a notificação. Tente novamente.',
            ),
          ),
        );
      }
    } finally {
      _opening = false;
    }
  }

  Future<String?> getToken() async {
    return _messaging.getToken();
  }

  Future<void> saveTokenForUser(String userId) async {
    final token = await getToken();
    if (token == null) return;
    await _registerBackendToken(token);
  }

  Future<void> clearTokenForUser(String userId) async {
    final token = _registeredToken ?? await getToken();
    if (token != null) {
      try {
        await _backend!.unregisterDeviceToken(token);
      } catch (_) {}
    }
    _registeredToken = null;
    _pendingData = null;
    await _messaging.deleteToken();
  }

  Stream<List<NotificationModel>> notificationsStream(String userId) {
    return Stream.fromFuture(_backend!.list());
  }

  Future<void> markAsRead(String notificationId) async {
    return _backend!.markAsRead(notificationId);
  }

  Future<void> markAllAsRead(String userId) async {
    return _backend!.markAllAsRead();
  }

  Future<void> showLocalNotificationFromData({
    required int id,
    required String title,
    required String body,
    required Map<String, dynamic> data,
  }) async {
    final androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDesc,
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    await _localNotifications.show(
      id,
      title,
      body,
      NotificationDetails(
        android: androidDetails,
        iOS: const DarwinNotificationDetails(),
      ),
      payload: jsonEncode(data),
    );
  }

  Future<void> _registerBackendToken(String token) async {
    final info = await PackageInfo.fromPlatform();
    await _backend!.registerDeviceToken(
      token: token,
      platform: Platform.isIOS ? 'IOS' : 'ANDROID',
      appVersion: info.version,
    );
    _registeredToken = token;
  }
}
