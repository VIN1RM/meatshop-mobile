import 'package:flutter/foundation.dart';
import 'package:meatshop_mobile/models/address_model.dart';
import 'package:meatshop_mobile/services/address_service.dart';

class AddressProvider extends ChangeNotifier {
  final _service = AddressService();

  List<AddressModel> _addresses = [];
  bool _loading = false;
  String? _error;

  List<AddressModel> get addresses => _addresses;
  bool get loading => _loading;
  String? get error => _error;

  Future<void> load(String uid) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      _addresses = await _service.fetchAddresses(uid);
    } catch (e) {
      _error = 'Erro ao carregar endereços.';
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> add(String uid, AddressModel address) async {
    final created = await _service.addAddress(uid, address);
    if (address.isDefault) {
      _addresses = _addresses.map((a) => a.copyWith(isDefault: false)).toList();
    }
    _addresses.add(created);
    notifyListeners();
  }

  Future<void> update(String uid, AddressModel address) async {
    await _service.updateAddress(uid, address);
    if (address.isDefault) {
      _addresses = _addresses.map((a) => a.copyWith(isDefault: false)).toList();
    }
    final idx = _addresses.indexWhere((a) => a.id == address.id);
    if (idx != -1) _addresses[idx] = address;
    notifyListeners();
  }

  Future<void> setDefault(String uid, String addressId) async {
    await _service.setDefault(uid, addressId);
    _addresses = _addresses
        .map((a) => a.copyWith(isDefault: a.id == addressId))
        .toList();
    notifyListeners();
  }

  Future<void> delete(String uid, String addressId) async {
    await _service.deleteAddress(uid, addressId);
    _addresses.removeWhere((a) => a.id == addressId);
    notifyListeners();
  }
}