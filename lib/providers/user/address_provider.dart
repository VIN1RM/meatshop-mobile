import 'package:flutter/foundation.dart';

import '../../data/repositories/address_repository.dart';
import '../../models/address_model.dart';

class AddressProvider extends ChangeNotifier {
  AddressProvider({required AddressRepository repository})
    : _repository = repository;

  final AddressRepository _repository;
  List<AddressModel> _addresses = [];
  bool _loading = false;
  String? _error;

  List<AddressModel> get addresses => List.unmodifiable(_addresses);
  bool get loading => _loading;
  String? get error => _error;

  Future<void> load(String uid) async {
    _setLoading(true);
    try {
      _addresses = await _repository.list();
    } catch (error) {
      _error = 'Erro ao carregar endereços.';
      debugPrint('[AddressProvider] load error: $error');
    } finally {
      _setLoading(false);
    }
  }

  Future<AddressModel> resolveZipCode(String zipCode) async {
    return _repository.resolveZipCode(zipCode);
  }

  Future<AddressModel> add(String uid, AddressModel address) async {
    final created = await _repository.create(address);
    if (created.isDefault) _clearLocalDefault();
    _addresses.add(created);
    notifyListeners();
    return created;
  }

  Future<void> update(String uid, AddressModel address) async {
    final updated = await _repository.update(address);
    _replace(updated);
    notifyListeners();
  }

  Future<void> setDefault(String uid, String addressId) async {
    await _repository.setDefault(addressId);
    _addresses = _addresses
        .map((address) => address.copyWith(isDefault: address.id == addressId))
        .toList();
    notifyListeners();
  }

  Future<void> delete(String uid, String addressId) async {
    await _repository.delete(addressId);
    _addresses.removeWhere((address) => address.id == addressId);
    notifyListeners();
  }

  void _replace(AddressModel address) {
    final index = _addresses.indexWhere((item) => item.id == address.id);
    if (index != -1) _addresses[index] = address;
  }

  void _clearLocalDefault() {
    _addresses = _addresses
        .map((address) => address.copyWith(isDefault: false))
        .toList();
  }

  void _setLoading(bool value) {
    _loading = value;
    if (value) _error = null;
    notifyListeners();
  }
}
