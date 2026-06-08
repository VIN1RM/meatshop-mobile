import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:meatshop_mobile/routes/app_routes.dart';
import 'package:meatshop_mobile/services/notification_service.dart';
import 'package:meatshop_mobile/ui/widgets/in_app_notification_banner.dart';
import 'package:meatshop_mobile/services/user_preferences_service.dart';

class OrderStatusNotificationWatcher with WidgetsBindingObserver {
  OrderStatusNotificationWatcher._();

  static final OrderStatusNotificationWatcher instance =
      OrderStatusNotificationWatcher._();

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _ordersSub;

  final Map<String, String> _lastOrderStatus = {};
  final Map<String, String> _lastDeliveryStatus = {};

  bool _started = false;
  AppLifecycleState _lifecycleState = AppLifecycleState.resumed;

  void start({
    required String userId,
    required GlobalKey<NavigatorState> navigatorKey,
  }) {
    if (_started) return;

    _started = true;
    WidgetsBinding.instance.addObserver(this);

    _ordersSub = _db
        .collection('orders')
        .where('client_id', isEqualTo: userId)
        .where(
          'status',
          whereIn: [
            'PENDING',
            'CONFIRMED',
            'PREPARING',
            'READY',
            'OUT_FOR_DELIVERY',
            'DELIVERED',
            'CANCELLED',
          ],
        )
        .snapshots()
        .listen((snapshot) {
          for (final change in snapshot.docChanges) {
            final doc = change.doc;
            final data = doc.data();

            if (data == null) continue;

            final orderId = doc.id;
            final currentStatus = data['status'] as String? ?? 'PENDING';
            final currentDeliveryStatus =
                data['delivery_status'] as String? ?? 'WAITING_DELIVERY_PERSON';

            if (change.type == DocumentChangeType.added) {
              _lastOrderStatus[orderId] = currentStatus;
              _lastDeliveryStatus[orderId] = currentDeliveryStatus;
              continue;
            }

            if (change.type != DocumentChangeType.modified) continue;

            final previousStatus = _lastOrderStatus[orderId];
            final previousDeliveryStatus = _lastDeliveryStatus[orderId];

            final statusChanged =
                previousStatus != null && previousStatus != currentStatus;

            final deliveryStatusChanged =
                previousDeliveryStatus != null &&
                previousDeliveryStatus != currentDeliveryStatus;

            _lastOrderStatus[orderId] = currentStatus;
            _lastDeliveryStatus[orderId] = currentDeliveryStatus;

            if (!statusChanged && !deliveryStatusChanged) continue;

            final title = 'Atualização do pedido';
            final message = _buildMessage(
              status: currentStatus,
              deliveryStatus: currentDeliveryStatus,
            );

            _showNotification(
              navigatorKey: navigatorKey,
              title: title,
              message: message,
              orderId: orderId,
              status: currentStatus,
              deliveryStatus: currentDeliveryStatus,
              userId: userId,
            );

            _saveNotificationHistory(
              userId: userId,
              title: title,
              message: message,
              orderId: orderId,
              status: currentStatus,
              deliveryStatus: currentDeliveryStatus,
            );
          }
        });
  }

  Future<void> _showNotification({
    required GlobalKey<NavigatorState> navigatorKey,
    required String title,
    required String message,
    required String orderId,
    required String status,
    required String deliveryStatus,
    required String userId,
  }) async {
    final prefs = await UserPreferencesService.instance.load(userId);
    if (!prefs.notifOrders) return;

    final data = {
      'type': 'ORDER',
      'order_id': orderId,
      'status': status,
      'delivery_status': deliveryStatus,
      'title': title,
      'body': message,
    };

    final context = navigatorKey.currentContext;

    if (_lifecycleState == AppLifecycleState.resumed && context != null) {
      InAppNotificationBanner.show(
        context: context,
        title: title,
        message: message,
        type: 'ORDER',
        duration: const Duration(seconds: 10),
        onTap: () {
          navigatorKey.currentState?.pushNamed(
            AppRoutes.deliveries,
            arguments: orderId,
          );
        },
      );

      return;
    }

    await NotificationService.instance.showLocalNotificationFromData(
      id: orderId.hashCode,
      title: title,
      body: message,
      data: data,
    );
  }

  Future<void> _saveNotificationHistory({
    required String userId,
    required String title,
    required String message,
    required String orderId,
    required String status,
    required String deliveryStatus,
  }) async {
    await _db.collection('notifications').add({
      'user_id': userId,
      'user_ref': _db.collection('users').doc(userId),
      'title': title,
      'message': message,
      'type': 'ORDER',
      'read': false,
      'created_at': FieldValue.serverTimestamp(),
      'payload': {
        'order_id': orderId,
        'status': status,
        'delivery_status': deliveryStatus,
      },
    });
  }

  String _buildMessage({
    required String status,
    required String deliveryStatus,
  }) {
    switch (status) {
      case 'CONFIRMED':
        return 'Seu pedido foi confirmado pelo açougue.';
      case 'PREPARING':
        return 'Seu pedido está sendo preparado.';
      case 'READY':
        return 'Seu pedido está pronto para entrega.';
      case 'OUT_FOR_DELIVERY':
        return 'Seu pedido saiu para entrega.';
      case 'DELIVERED':
        return 'Seu pedido foi entregue.';
      case 'CANCELLED':
        return 'Seu pedido foi cancelado.';
      default:
        break;
    }

    switch (deliveryStatus) {
      case 'WAITING_DELIVERY_PERSON':
        return 'Estamos procurando um entregador para seu pedido.';
      case 'PICKUP':
        return 'O entregador está indo retirar seu pedido.';
      case 'ON_THE_WAY':
        return 'Seu pedido está a caminho.';
      case 'DELIVERED':
        return 'A entrega foi concluída.';
      default:
        return 'O status do seu pedido foi atualizado.';
    }
  }

  void stop() {
    _ordersSub?.cancel();
    _ordersSub = null;

    _lastOrderStatus.clear();
    _lastDeliveryStatus.clear();

    if (_started) {
      WidgetsBinding.instance.removeObserver(this);
    }

    _started = false;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _lifecycleState = state;
  }
}
