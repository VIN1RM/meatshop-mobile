import 'package:flutter/foundation.dart';
import 'package:meatshop_mobile/models/cart_item_model.dart';
import 'package:meatshop_mobile/services/cart_service.dart';
import 'package:meatshop_mobile/services/business_hours_service.dart';

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

  final BusinessHoursService _hoursService = BusinessHoursService();
  final Map<String, bool> _unitOpenStatus = {};

  Map<String, bool> get unitOpenStatus => Map.unmodifiable(_unitOpenStatus);

  bool isUnitOpen(String unitId) => _unitOpenStatus[unitId] ?? true;

  Future<void> loadCart() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final raw = await _service.fetchItems(uid);
      _items = await Future.wait(
        raw.map((item) async {
          if (item.unitName.isNotEmpty) return item;
          final name = await _service.fetchUnitName(item.unitId);

          if (name.isNotEmpty) {
            await _service.patchUnitName(uid, item.productId, name);
          }
          return item.copyWith(unitName: name);
        }),
      );
    } catch (e) {
      _error = 'Não foi possível carregar o carrinho.';
      debugPrint('[CartProvider] erro: $e');
    }

    await _checkUnitsOpen();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> _checkUnitsOpen() async {
    final unitIds = _items.map((i) => i.unitId).toSet();
    for (final unitId in unitIds) {
      final hours = await _hoursService.fetchToday(unitId);
      _unitOpenStatus[unitId] = hours?.isOpenNow ?? true;
    }
  }

  Future<void> addItem(CartItemModel item) async {
    try {
      final existing = _items.indexWhere((i) => i.productId == item.productId);
      if (existing != -1) {
        final updated = _items[existing].copyWith(
          quantity: _items[existing].quantity + item.quantity,
        );
        await _service.updateQuantity(uid, item.productId, updated.quantity);
        _items[existing] = updated;
      } else {
        await _service.addItem(uid, item);
        _items.add(item);
      }
      notifyListeners();
    } catch (e) {
      debugPrint('[CartProvider] addItem error: $e');
    }
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

  Future<void> clearCart() async {
    _items.clear();
    notifyListeners();
  }
}
