import 'package:flutter/foundation.dart';
import 'package:meatshop_mobile/models/cart_item_model.dart';
import 'package:meatshop_mobile/services/cart_service.dart';

class CartProvider extends ChangeNotifier {
  final CartService _service;
  final String uid;

  CartProvider({required this.uid, CartService? service})
    : _service = service ?? CartService();

  List<CartItemModel> _items = [];
  List<CartItemModel> get items => _items;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  Map<String, List<CartItemModel>> get itemsByUnit {
    final map = <String, List<CartItemModel>>{};
    for (final item in _items) {
      map.putIfAbsent(item.unitId, () => []).add(item);
    }
    return map;
  }

  double get total => _items.fold(0, (sum, item) => sum + item.subtotal);

  Future<void> loadCart() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _items = await _service.fetchItems(uid);
    } catch (e) {
      _error = 'Não foi possível carregar o carrinho.';
      debugPrint('[CartProvider] erro: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> updateQuantity(String productId, double quantity) async {
    if (quantity <= 0) {
      await removeItem(productId);
      return;
    }
    try {
      await _service.updateQuantity(uid, productId, quantity);
      final index = _items.indexWhere((i) => i.productId == productId);
      if (index != -1) {
        _items[index] = _items[index].copyWith(quantity: quantity);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('[CartProvider] erro ao atualizar: $e');
    }
  }

  Future<void> removeItem(String productId) async {
    try {
      await _service.removeItem(uid, productId);
      _items.removeWhere((i) => i.productId == productId);
      notifyListeners();
    } catch (e) {
      debugPrint('[CartProvider] erro ao remover: $e');
    }
  }
}
