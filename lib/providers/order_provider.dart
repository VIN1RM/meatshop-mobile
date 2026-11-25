import 'dart:async';

import 'package:flutter/foundation.dart';
import '../core/network/api_failure.dart';
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

  final Set<Future<void> Function()> _orderRefreshers = {};
  Object? _refreshFailure;
  Future<void> refreshOrders() async {
    _refreshFailure = null;
    await Future.wait(_orderRefreshers.toList().map((refresh) => refresh()));
    if (_refreshFailure != null) throw _refreshFailure!;
  }

  final OrderRepository _repository;
  final RealtimeRepository? _realtime;

  bool _isLoading = false;
  int _generation = 0;
  String? _error;
  String? _lastOrderId;
  String? _lastCheckoutId;
  String? _paymentCheckoutUrl;
  String? _pendingIdempotencyKey;
  List<OrderModel> lastCheckoutOrders = [];
  Future<bool> onlinePaymentsAvailable() =>
      _repository.onlinePaymentsAvailable();
  Future<Map<String, bool>> paymentAvailability(List<String> units) async {
    final repository = _repository;
    if (repository is CheckoutCapabilities) {
      return (repository as CheckoutCapabilities).paymentAvailability(units);
    }
    final online = await onlinePaymentsAvailable();
    return {for (final unit in units) unit: online};
  }

  Future<String> payOrder(String id) => _repository.createPayment(id);
  Future<OrderModel> refreshPayment(String id) async {
    try {
      await _repository.reconcilePayment(id);
    } catch (_) {
      /* The local state remains available during provider outages. */
    }
    return _repository.get(id);
  }

  Future<bool> recoverPending(CartProvider cart) async {
    final repository = _repository;
    if (repository is! CheckoutRecovery) return false;
    final result = await (repository as CheckoutRecovery).recoverPending();
    if (result == null) return false;
    lastCheckoutOrders = result.orders;
    _lastCheckoutId = result.checkoutId;
    _lastOrderId = result.orders.firstOrNull?.id;
    await cart.loadCart();
    notifyListeners();
    return true;
  }

  Future<OrderHistoryPage> historyPage(int page) async {
    final repository = _repository;
    if (repository is PaginatedOrderHistory) {
      return (repository as PaginatedOrderHistory).historyPage(page);
    }
    if (page > 0) return const OrderHistoryPage([], hasMore: false);
    final rows = await repository.list();
    return OrderHistoryPage(
      rows
          .where(
            (order) => const {'DELIVERED', 'CANCELLED'}.contains(order.status),
          )
          .toList(),
      hasMore: false,
    );
  }

  Future<OrderModel> getOrder(String id) => _repository.get(id);

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
    String? quoteToken,
  }) async {
    if (_isLoading) return false;
    final generation = _generation;
    _isLoading = true;
    _error = null;
    _paymentCheckoutUrl = null;
    notifyListeners();

    try {
      final key = _pendingIdempotencyKey ?? IdempotencyKey.generate();
      _pendingIdempotencyKey = key;
      final checkout = await _repository.create(
        summary.withExpectedTotal(total, token: quoteToken),
        idempotencyKey: key,
      );
      if (generation != _generation) return false;
      _lastCheckoutId = checkout.checkoutId;
      _lastOrderId = checkout.orders.firstOrNull?.id;
      lastCheckoutOrders = checkout.orders;
      _pendingIdempotencyKey = null;
      if (checkout.recovered) {
        await cartProvider.loadCart();
      } else {
        cartProvider.checkoutCompleted();
      }
      return true;
    } catch (error) {
      _error = _message(error);
      return false;
    } finally {
      if (generation == _generation) {
        _isLoading = false;
        notifyListeners();
      }
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
    return _poll(repository).map(
      (orders) => orders
          .where(
            (order) => const {'DELIVERED', 'CANCELLED'}.contains(order.status),
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

  Future<List<String>> repeatOrder(String orderId) async {
    return _repository.repeat(orderId);
  }

  Stream<List<OrderModel>> _poll(OrderRepository repository) {
    late StreamController<List<OrderModel>> controller;
    Timer? timer;
    Future<void>? pending;
    bool hasData = false;
    Future<void> fetch() async {
      try {
        final orders = await repository.list();
        if (!controller.isClosed) {
          hasData = true;
          controller.add(orders);
        }
      } catch (error, stack) {
        _refreshFailure = error;
        if (!controller.isClosed && !hasData) controller.addError(error, stack);
      }
    }

    Future<void> refresh() =>
        pending ??= fetch().whenComplete(() => pending = null);
    controller = StreamController<List<OrderModel>>(
      onListen: () {
        _orderRefreshers.add(refresh);
        refresh();
        timer = Timer.periodic(const Duration(seconds: 10), (_) => refresh());
      },
      onCancel: () {
        _orderRefreshers.remove(refresh);
        timer?.cancel();
      },
    );
    return controller.stream;
  }

  Stream<List<OrderModel>> _realtimeOrders(
    OrderRepository repository, {
    required bool active,
  }) {
    late StreamController<List<OrderModel>> controller;
    StreamSubscription<Map<String, Object?>>? statusSubscription;
    StreamSubscription<RealtimeConnectionState>? connectionSubscription;
    final subscribedOrderIds = <int>{};
    Timer? fallback;
    Future<void>? pending;
    bool closed = false;

    bool hasData = false;
    Future<void> fetch() async {
      if (closed) return;
      try {
        final orders = await repository.list();
        final activeOrders = orders
            .where(
              (order) =>
                  !const {'DELIVERED', 'CANCELLED'}.contains(order.status),
            )
            .toList(growable: false);
        if (closed) return;
        final ids = activeOrders
            .map((o) => int.tryParse(o.id))
            .whereType<int>()
            .toSet();
        for (final id in subscribedOrderIds.difference(ids).toList()) {
          _realtime!.unsubscribeDelivery(id);
          subscribedOrderIds.remove(id);
        }
        for (final order in activeOrders) {
          final orderId = int.tryParse(order.id);
          if (orderId != null && subscribedOrderIds.add(orderId)) {
            await _realtime!.subscribeDelivery(orderId);
          }
        }
        if (closed || controller.isClosed) return;
        hasData = true;
        if (active) {
          controller.add(activeOrders);
        } else {
          controller.add(
            orders
                .where(
                  (order) =>
                      const {'DELIVERED', 'CANCELLED'}.contains(order.status),
                )
                .toList(growable: false),
          );
        }
      } catch (error, stackTrace) {
        _refreshFailure = error;
        if (!closed && !hasData) controller.addError(error, stackTrace);
      }
    }

    Future<void> refresh() =>
        pending ??= fetch().whenComplete(() => pending = null);
    controller = StreamController<List<OrderModel>>(
      onListen: () {
        _orderRefreshers.add(refresh);
        refresh();
        _realtime!.connect();
        fallback = Timer.periodic(
          const Duration(seconds: 15),
          (_) => refresh(),
        );
        statusSubscription = _realtime.statuses.listen((_) => refresh());
        connectionSubscription = _realtime.connection.listen((state) {
          if (state == RealtimeConnectionState.connected) refresh();
        });
      },
      onCancel: () async {
        _orderRefreshers.remove(refresh);
        closed = true;
        fallback?.cancel();
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

  String _message(Object error) {
    if (error is ApiFailure) return error.message;
    return 'Nao foi possivel registrar o pedido. Tente novamente.';
  }

  void clear() {
    ++_generation;
    lastCheckoutOrders = [];
    _lastOrderId = null;
    _lastCheckoutId = null;
    _paymentCheckoutUrl = null;
    _pendingIdempotencyKey = null;
    _error = null;
    _isLoading = false;
    notifyListeners();
  }
}
