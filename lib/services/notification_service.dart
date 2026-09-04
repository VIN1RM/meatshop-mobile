import 'dart:convert';

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
import 'firebase_complementary_services.dart';

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final _messaging = FirebaseMessaging.instance;
  final _localNotifications = FlutterLocalNotificationsPlugin();
  NotificationRepository? _backend;
  String? _registeredToken;

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
      _navigateFromData(data);
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
    var verified = data;
    final notificationId = '${data['notification_id'] ?? ''}';
    if (notificationId.isEmpty) return;
    final current = await _backend!.list();
    final item = current
        .where((entry) => entry.id == notificationId)
        .firstOrNull;
    if (item == null) return;
    await _backend!.markAsRead(notificationId);
    verified = {'type': item.type.name.toUpperCase(), ...?item.payload};
    _navigateFromData(verified);
  }

  void _navigateFromData(Map<String, dynamic> data) {
    final type = (data['type'] as String? ?? '').toUpperCase();
    FirebaseComplementaryServices.logNavigation(type.toLowerCase());
    final nav = navigatorKey?.currentState;
    if (nav == null) return;

    switch (type) {
      case 'ORDER':
        final orderId = data['order_id'] as String?;

        if (orderId != null && orderId.isNotEmpty) {
          nav.pushNamed(AppRoutes.deliveries, arguments: orderId);
          return;
        }

        nav.pushNamed(AppRoutes.deliveries);
        return;

      case 'DELIVERY':
        nav.pushNamed(AppRoutes.deliveries);
        return;

      case 'PROMOTION':
        nav.pushNamed(AppRoutes.acougues);
        return;

      case 'SYSTEM':
      default:
        return;
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
      } catch (_) {
        // O logout local deve prosseguir mesmo sem rede.
      }
    }
    _registeredToken = null;
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
