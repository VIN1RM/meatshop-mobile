import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:meatshop_mobile/core/firebase/firestore_collections.dart';
import 'package:meatshop_mobile/models/notification_model.dart';
import 'package:meatshop_mobile/routes/app_routes.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:meatshop_mobile/ui/widgets/in_app_notification_banner.dart';
import 'package:meatshop_mobile/services/user_preferences_service.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await NotificationService.instance.showLocalNotification(message);
}

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final _messaging = FirebaseMessaging.instance;
  final _localNotifications = FlutterLocalNotificationsPlugin();
  final _db = FirebaseFirestore.instance;

  static const _channelId = 'meatshop_channel';
  static const _channelName = 'MeatShop Notificações';
  static const _channelDesc = 'Pedidos, entregas e promoções';

  GlobalKey<NavigatorState>? navigatorKey;

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
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;
      await _db.collection(FirestoreCollections.users).doc(user.uid).set({
        'fcm_token': newToken,
      }, SetOptions(merge: true));
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
    final notification = message.notification;
    if (notification == null) return;

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
      notification.title ?? 'MeatShop',
      notification.body ?? '',
      NotificationDetails(
        android: androidDetails,
        iOS: const DarwinNotificationDetails(),
      ),
      payload: jsonEncode(message.data),
    );
  }

  void _handleNavigation(RemoteMessage message) {
    _navigateFromData(message.data);
  }

  void _navigateFromData(Map<String, dynamic> data) {
    final type = (data['type'] as String? ?? '').toUpperCase();
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
    await _db.collection(FirestoreCollections.users).doc(userId).set({
      'fcm_token': token,
      'fcm_token_updated_at': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> clearTokenForUser(String userId) async {
    await _db.collection(FirestoreCollections.users).doc(userId).set({
      'fcm_token': null,
    }, SetOptions(merge: true));
    await _messaging.deleteToken();
  }

  Stream<List<NotificationModel>> notificationsStream(String userId) {
    return _db
        .collection(FirestoreCollections.notifications)
        .where('user_id', isEqualTo: userId)
        .orderBy('created_at', descending: true)
        .limit(50)
        .snapshots()
        .map((snap) => snap.docs.map(NotificationModel.fromDoc).toList());
  }

  Future<void> markAsRead(String notificationId) async {
    await _db
        .collection(FirestoreCollections.notifications)
        .doc(notificationId)
        .update({'read': true});
  }

  Future<void> markAllAsRead(String userId) async {
    final snap = await _db
        .collection(FirestoreCollections.notifications)
        .where('user_id', isEqualTo: userId)
        .where('read', isEqualTo: false)
        .get();

    final batch = _db.batch();
    for (final doc in snap.docs) {
      batch.update(doc.reference, {'read': true});
    }
    await batch.commit();
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
}
