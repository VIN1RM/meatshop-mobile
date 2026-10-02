import 'package:flutter/foundation.dart';

import '../data/repositories/cart_repository.dart';
import '../models/cart_item_model.dart';
import '../services/business_hours_service.dart';

class CartProvider extends ChangeNotifier {
  CartProvider({
    required this.uid,
    required CartRepository repository,
    BusinessHoursService? hoursService,
  }) : _repository = repository,
       _hoursService = hoursService;

  final String uid;
  final CartRepository _repository;
  final BusinessHoursService? _hoursService;
  final Map<String, bool> _unitOpenStatus = {};

  List<CartItemModel> _items = [];
  bool _isLoading = false;
  String? _error;
  int _generation = 0;

  List<CartItemModel> get items => List.unmodifiable(_items);
  bool get isLoading => _isLoading;
  String? get error => _error;
  double get total => _items.fold(0, (sum, item) => sum + item.subtotal);
  Map<String, bool> get unitOpenStatus => Map.unmodifiable(_unitOpenStatus);

  Map<String, List<CartItemModel>> get itemsByUnit {
    final grouped = <String, List<CartItemModel>>{};
    for (final item in _items) {
      grouped.putIfAbsent(item.unitId, () => []).add(item);
    }
    return grouped;
  }

  bool isUnitOpen(String unitId) => _unitOpenStatus[unitId] ?? true;

  Future<void> loadCart() async {
    final generation = ++_generation;
    _setLoading(true);
    try {
      final items = await _repository.getCart();
      if (generation != _generation) return;
      _items = items;
      await _checkUnitsOpen();
    } catch (error) {
      if (generation != _generation) return;
      _error = 'Não foi possível carregar o carrinho.';
      debugPrint('[CartProvider] load error: $error');
    } finally {
      if (generation == _generation) _setLoading(false);
    }
  }

  Future<void> addItem(CartItemModel item) async {
    await _mutate(() async {
      _items = await _repository.addItem(item.productId, item.quantity);
    });
  }

  Future<void> updateQuantity(String productId, double quantity) async {
    if (quantity <= 0) return removeItem(productId);
    await _mutate(() async {
      final index = _items.indexWhere((item) => item.productId == productId);
      if (index == -1) return;
      _items = await _repository.updateItem(
        _requiredCartItemId(_items[index]),
        quantity,
      );
    });
  }

  Future<void> removeItem(String productId) async {
    await _mutate(() async {
      final item = _findByProductId(productId);
      if (item == null) return;
      _items = await _repository.removeItem(_requiredCartItemId(item));
    });
  }

  Future<void> clearCart() async {
    await _mutate(() async {
      _items = await _repository.clear();
      _unitOpenStatus.clear();
    });
  }

  void clearLocal() {
    ++_generation;
    _items = [];
    _unitOpenStatus.clear();
    _isLoading = false;
    _error = null;
    notifyListeners();
  }

  String _requiredCartItemId(CartItemModel item) {
    if (item.cartItemId.isNotEmpty) return item.cartItemId;
    throw StateError('O item do carrinho não possui identificador remoto.');
  }

  CartItemModel? _findByProductId(String productId) {
    for (final item in _items) {
      if (item.productId == productId) return item;
    }
    return null;
  }

  Future<void> _mutate(Future<void> Function() operation) async {
    final generation = _generation;
    _error = null;
    try {
      await operation();
      if (generation != _generation) {
        _items = [];
        _unitOpenStatus.clear();
        return;
      }
      notifyListeners();
    } catch (error) {
      _error = 'Não foi possível atualizar o carrinho.';
      debugPrint('[CartProvider] mutation error: $error');
      notifyListeners();
    }
  }

  Future<void> _checkUnitsOpen() async {
    _unitOpenStatus.clear();
    for (final unitId in _items.map((item) => item.unitId).toSet()) {
      try {
        final hours = await _hoursService?.fetchToday(unitId);
        _unitOpenStatus[unitId] = hours?.isOpenNow ?? true;
      } catch (error) {
        _unitOpenStatus[unitId] = true;
        debugPrint('[CartProvider] business hours error: $error');
      }
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    if (value) _error = null;
    notifyListeners();
  }
}
