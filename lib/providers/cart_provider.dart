import 'package:flutter/foundation.dart';

import '../data/repositories/cart_repository.dart';
import '../models/cart_item_model.dart';
import '../services/business_hours_service.dart';
import '../services/cart_service.dart';

class CartProvider extends ChangeNotifier {
  CartProvider({
    required this.uid,
    CartRepository? repository,
    CartService? service,
    BusinessHoursService? hoursService,
  }) : _repository = repository,
       _service = service ?? (repository == null ? CartService() : null),
       _hoursService =
           hoursService ?? (repository == null ? BusinessHoursService() : null);

  final String uid;
  final CartRepository? _repository;
  final CartService? _service;
  final BusinessHoursService? _hoursService;
  final Map<String, bool> _unitOpenStatus = {};

  List<CartItemModel> _items = [];
  bool _isLoading = false;
  String? _error;

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
    _setLoading(true);
    try {
      _items = _repository == null
          ? await _loadLegacyCart()
          : await _repository.getCart();
      await _checkUnitsOpen();
    } catch (error) {
      _error = 'Não foi possível carregar o carrinho.';
      debugPrint('[CartProvider] load error: $error');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> addItem(CartItemModel item) async {
    await _mutate(() async {
      if (_repository != null) {
        _items = await _repository.addItem(item.productId, item.quantity);
        return;
      }
      final index = _items.indexWhere(
        (current) => current.productId == item.productId,
      );
      if (index == -1) {
        await _legacyService.addItem(uid, item);
        _items.add(item);
        return;
      }
      final quantity = _items[index].quantity + item.quantity;
      await _legacyService.updateQuantity(uid, item.productId, quantity);
      _items[index] = _items[index].copyWith(quantity: quantity);
    });
  }

  Future<void> updateQuantity(String productId, double quantity) async {
    if (quantity <= 0) return removeItem(productId);
    await _mutate(() async {
      final index = _items.indexWhere((item) => item.productId == productId);
      if (index == -1) return;
      if (_repository != null) {
        _items = await _repository.updateItem(
          _requiredCartItemId(_items[index]),
          quantity,
        );
      } else {
        await _legacyService.updateQuantity(uid, productId, quantity);
        _items[index] = _items[index].copyWith(quantity: quantity);
      }
    });
  }

  Future<void> removeItem(String productId) async {
    await _mutate(() async {
      final item = _findByProductId(productId);
      if (item == null) return;
      if (_repository != null) {
        _items = await _repository.removeItem(_requiredCartItemId(item));
      } else {
        await _legacyService.removeItem(uid, productId);
        _items.removeWhere((current) => current.productId == productId);
      }
    });
  }

  Future<void> clearCart() async {
    await _mutate(() async {
      _items = _repository == null
          ? await _clearLegacyCart()
          : await _repository.clear();
      _unitOpenStatus.clear();
    });
  }

  Future<List<CartItemModel>> _clearLegacyCart() async {
    await _legacyService.clearCart(uid);
    return [];
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
    _error = null;
    try {
      await operation();
      notifyListeners();
    } catch (error) {
      _error = 'Não foi possível atualizar o carrinho.';
      debugPrint('[CartProvider] mutation error: $error');
      notifyListeners();
    }
  }

  Future<List<CartItemModel>> _loadLegacyCart() async {
    final rawItems = await _legacyService.fetchItems(uid);
    return Future.wait(rawItems.map(_resolveLegacySnapshots));
  }

  Future<CartItemModel> _resolveLegacySnapshots(CartItemModel item) async {
    var resolved = item;
    if (item.unitName.isEmpty) {
      resolved = resolved.copyWith(
        unitName: await _legacyService.fetchUnitName(item.unitId),
      );
    }
    if (item.unitImageUrl.isEmpty) {
      resolved = resolved.copyWith(
        unitImageUrl: await _legacyService.fetchUnitImageUrl(item.unitId),
      );
    }
    if (item.productImageUrl.isEmpty) {
      resolved = resolved.copyWith(
        productImageUrl: await _legacyService.fetchProductImageUrl(
          item.productId,
        ),
      );
    }
    return resolved;
  }

  CartService get _legacyService {
    final service = _service;
    if (service != null) return service;
    throw StateError('O serviço legado do carrinho não está configurado.');
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
