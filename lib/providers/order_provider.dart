import 'package:flutter/foundation.dart';
import 'package:meatshop_mobile/models/cart_item_model.dart';
import 'package:meatshop_mobile/models/checkout_summary_model.dart';
import 'package:meatshop_mobile/services/order_service.dart';

class OrderProvider extends ChangeNotifier {
  OrderProvider({OrderService? service}) : _service = service ?? OrderService();

  final OrderService _service;

  bool _isLoading = false;
  String? _error;
  String? _lastOrderId;

  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get lastOrderId => _lastOrderId;

  Future<bool> placeOrder({
    required CheckoutSummaryModel summary,
    required List<CartItemModel> items,
    required double total,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _lastOrderId = await _service.createOrder(
        summary: summary,
        items: items,
        total: total,
      );
      return true;
    } catch (e) {
      _error = 'Erro ao registrar pedido: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clear() {
    _lastOrderId = null;
    _error = null;
    _isLoading = false;
    notifyListeners();
  }
}
