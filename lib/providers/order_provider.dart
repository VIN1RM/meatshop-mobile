import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:meatshop_mobile/data/repositories/order_repository.dart';
import 'package:meatshop_mobile/core/utils/idempotency_key.dart';
import 'package:meatshop_mobile/models/cart_item_model.dart';
import 'package:meatshop_mobile/models/checkout_summary_model.dart';
import 'package:meatshop_mobile/models/order_model.dart';
import 'package:meatshop_mobile/providers/cart_provider.dart';
import 'package:meatshop_mobile/services/cart_service.dart';
import 'package:meatshop_mobile/services/order_service.dart';

class OrderProvider extends ChangeNotifier {
  OrderProvider({
    OrderRepository? repository,
    OrderService? service,
    CartService? cartService,
  }) : _repository = repository,
       _service = service ?? (repository == null ? OrderService() : null),
       _cartService =
           cartService ?? (repository == null ? CartService() : null);

  final OrderRepository? _repository;
  final OrderService? _service;
  final CartService? _cartService;

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
    final repository = _repository;
    if (repository == null) return null;
    return repository.quote(summary);
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
      final repository = _repository;
      if (repository != null) {
        final key = _pendingIdempotencyKey ?? IdempotencyKey.generate();
        _pendingIdempotencyKey = key;
        final checkout = await repository.create(summary, idempotencyKey: key);
        _lastCheckoutId = checkout.checkoutId;
        _lastOrderId = checkout.orders.firstOrNull?.id;
        if (_isOnlinePayment(summary.paymentMethod)) {
          _paymentCheckoutUrl = await repository.createPayment(
            checkout.checkoutId,
          );
        }
        _pendingIdempotencyKey = null;
        await cartProvider.clearCart();
      } else {
        _lastOrderId = await _service!.createOrder(
          summary: summary,
          items: items,
          total: total,
          feeByUnit: feeByUnit,
        );
        await _cartService!.clearCart(cartProvider.uid);
        await cartProvider.clearCart();
      }
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
    if (repository == null) return _service!.activeOrdersStream();
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
    if (repository == null) return _service!.finishedOrdersStream();
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
    final repository = _repository;
    if (repository != null) {
      await repository.cancel(orderId, reason);
    } else {
      await _service!.cancelOrder(orderId: orderId, reason: reason);
    }
  }

  Future<CheckoutResult?> repeatOrder(String orderId) async {
    return _repository?.repeat(orderId);
  }

  Stream<List<OrderModel>> _poll(OrderRepository repository) async* {
    yield await repository.list();
    await for (final _ in Stream<void>.periodic(const Duration(seconds: 10))) {
      yield await repository.list();
    }
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
