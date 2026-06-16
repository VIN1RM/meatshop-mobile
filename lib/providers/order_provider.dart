import 'package:flutter/foundation.dart';
import 'package:meatshop_mobile/models/cart_item_model.dart';
import 'package:meatshop_mobile/models/checkout_summary_model.dart';
import 'package:meatshop_mobile/providers/cart_provider.dart';
import 'package:meatshop_mobile/services/cart_service.dart';
import 'package:meatshop_mobile/services/order_service.dart';

class OrderProvider extends ChangeNotifier {
  OrderProvider({OrderService? service, CartService? cartService})
    : _service = service ?? OrderService(),
      _cartService = cartService ?? CartService();

  final OrderService _service;
  final CartService _cartService;

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
    required CartProvider cartProvider,
    Map<String, double> feeByUnit = const {},
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _lastOrderId = await _service.createOrder(
        summary: summary,
        items: items,
        total: total,
        feeByUnit: feeByUnit,
      );

      await _cartService.clearCart(cartProvider.uid);
      await cartProvider.clearCart();

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
