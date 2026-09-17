import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:meatshop_mobile/data/repositories/order_repository.dart';
import 'package:meatshop_mobile/core/utils/idempotency_key.dart';
import 'package:meatshop_mobile/models/cart_item_model.dart';
import 'package:meatshop_mobile/models/checkout_summary_model.dart';
import 'package:meatshop_mobile/models/order_model.dart';
import 'package:meatshop_mobile/providers/cart_provider.dart';
import 'package:meatshop_mobile/data/repositories/realtime_repository.dart';

class OrderProvider extends ChangeNotifier {
  OrderProvider({
    required OrderRepository repository,
    RealtimeRepository? realtime,
  }) : _repository = repository,
       _realtime = realtime;

  final OrderRepository _repository;
  final RealtimeRepository? _realtime;

  bool _isLoading = false;
  String? _error;
  String? _lastOrderId;
  String? _lastCheckoutId;
  String? _paymentCheckoutUrl;
  String? _pendingIdempotencyKey;

  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get lastOrderId => _lastOrderId;
  String? get lastCheckoutId => _lastCheckoutId;
  String? get paymentCheckoutUrl => _paymentCheckoutUrl;

  Future<CheckoutQuote?> quote(CheckoutSummaryModel summary) async {
    return _repository.quote(summary);
  }

  Future<bool> placeOrder({
    required CheckoutSummaryModel summary,
    required List<CartItemModel> items,
    required double total,
    required CartProvider cartProvider,
    Map<String, double> feeByUnit = const {},
  }) async {
    _isLoading = true;
    _error = null;
    _paymentCheckoutUrl = null;
    notifyListeners();

    try {
      final key = _pendingIdempotencyKey ?? IdempotencyKey.generate();
      _pendingIdempotencyKey = key;
      final checkout = await _repository.create(summary, idempotencyKey: key);
      _lastCheckoutId = checkout.checkoutId;
      _lastOrderId = checkout.orders.firstOrNull?.id;
      if (_isOnlinePayment(summary.paymentMethod)) {
        _paymentCheckoutUrl = await _repository.createPayment(
          checkout.checkoutId,
        );
      }
      _pendingIdempotencyKey = null;
      await cartProvider.clearCart();
      return true;
    } catch (error) {
      _error = _message(error);
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Stream<List<OrderModel>> activeOrdersStream() {
    final repository = _repository;
    if (_realtime != null) return _realtimeOrders(repository, active: true);
    return _poll(repository).map(
      (orders) => orders
          .where(
            (order) => !const {'DELIVERED', 'CANCELLED'}.contains(order.status),
          )
          .toList(growable: false),
    );
  }

  Stream<List<OrderModel>> finishedOrdersStream() {
    final repository = _repository;
    if (_realtime != null) return _realtimeOrders(repository, active: false);
    final since = DateTime.now().subtract(const Duration(days: 90));
    return _poll(repository).map(
      (orders) => orders
          .where(
            (order) =>
                const {'DELIVERED', 'CANCELLED'}.contains(order.status) &&
                (order.orderDate?.isAfter(since) ?? false),
          )
          .toList(growable: false),
    );
  }

  Future<void> cancelOrder({
    required String orderId,
    required String reason,
  }) async {
    await _repository.cancel(orderId, reason);
  }

  Future<CheckoutResult?> repeatOrder(String orderId) async {
    return _repository.repeat(orderId);
  }

  Stream<List<OrderModel>> _poll(OrderRepository repository) async* {
    yield await repository.list();
    await for (final _ in Stream<void>.periodic(const Duration(seconds: 10))) {
      yield await repository.list();
    }
  }

  Stream<List<OrderModel>> _realtimeOrders(
    OrderRepository repository, {
    required bool active,
  }) {
    late StreamController<List<OrderModel>> controller;
    StreamSubscription<Map<String, Object?>>? statusSubscription;
    StreamSubscription<RealtimeConnectionState>? connectionSubscription;
    final subscribedOrderIds = <int>{};

    Future<void> refresh() async {
      try {
        final orders = await repository.list();
        final activeOrders = orders
            .where(
              (order) =>
                  !const {'DELIVERED', 'CANCELLED'}.contains(order.status),
            )
            .toList(growable: false);
        for (final order in activeOrders) {
          final orderId = int.tryParse(order.id);
          if (orderId != null && subscribedOrderIds.add(orderId)) {
            await _realtime!.subscribeDelivery(orderId);
          }
        }
        if (active) {
          controller.add(activeOrders);
        } else {
          final since = DateTime.now().subtract(const Duration(days: 90));
          controller.add(
            orders
                .where(
                  (order) =>
                      const {'DELIVERED', 'CANCELLED'}.contains(order.status) &&
                      (order.orderDate?.isAfter(since) ?? false),
                )
                .toList(growable: false),
          );
        }
      } catch (error, stackTrace) {
        controller.addError(error, stackTrace);
      }
    }

    controller = StreamController<List<OrderModel>>(
      onListen: () {
        refresh();
        _realtime!.connect();
        statusSubscription = _realtime.statuses.listen((_) => refresh());
        connectionSubscription = _realtime.connection.listen((state) {
          if (state == RealtimeConnectionState.connected) refresh();
        });
      },
      onCancel: () async {
        await statusSubscription?.cancel();
        await connectionSubscription?.cancel();
        for (final orderId in subscribedOrderIds) {
          _realtime!.unsubscribeDelivery(orderId);
        }
        subscribedOrderIds.clear();
      },
    );
    return controller.stream;
  }

  bool _isOnlinePayment(String method) =>
      const {'pix', 'credit', 'debit'}.contains(method);

  String _message(Object error) {
    final text = error.toString();
    return text.isEmpty
        ? 'Erro ao registrar pedido.'
        : 'Erro ao registrar pedido: $text';
  }

  void clear() {
    _lastOrderId = null;
    _lastCheckoutId = null;
    _paymentCheckoutUrl = null;
    _pendingIdempotencyKey = null;
    _error = null;
    _isLoading = false;
    notifyListeners();
  }
}
