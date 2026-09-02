import 'package:flutter/foundation.dart';

import '../../data/repositories/address_repository.dart';
import '../../models/address_model.dart';
import '../../services/address_service.dart';
import '../../services/cep_service.dart';

class AddressProvider extends ChangeNotifier {
  AddressProvider({AddressRepository? repository, AddressService? service})
    : _repository = repository,
      _service = service ?? (repository == null ? AddressService() : null);

  final AddressRepository? _repository;
  final AddressService? _service;
  List<AddressModel> _addresses = [];
  bool _loading = false;
  String? _error;

  List<AddressModel> get addresses => List.unmodifiable(_addresses);
  bool get loading => _loading;
  String? get error => _error;

  Future<void> load(String uid) async {
    _setLoading(true);
    try {
      _addresses = _repository == null
          ? await _legacyService.fetchAddresses(uid)
          : await _repository.list();
    } catch (error) {
      _error = 'Erro ao carregar endereços.';
      debugPrint('[AddressProvider] load error: $error');
    } finally {
      _setLoading(false);
    }
  }

  Future<AddressModel> resolveZipCode(String zipCode) async {
    if (_repository != null) return _repository.resolveZipCode(zipCode);
    final result = await CepService.fetch(zipCode);
    return switch (result) {
      CepSuccess(:final data) => AddressModel(
        id: '',
        label: '',
        street: data.street,
        number: '',
        complement: '',
        neighborhood: data.neighborhood,
        city: data.city,
        state: data.state,
        zipCode: data.zipCode,
        isDefault: false,
      ),
      CepFailure(:final message) => throw StateError(message),
    };
  }

  Future<AddressModel> add(String uid, AddressModel address) async {
    final created = _repository == null
        ? await _legacyService.addAddress(uid, address)
        : await _repository.create(address);
    if (created.isDefault) _clearLocalDefault();
    _addresses.add(created);
    notifyListeners();
    return created;
  }

  Future<void> update(String uid, AddressModel address) async {
    final updated = _repository == null
        ? await _legacyUpdate(uid, address)
        : await _repository.update(address);
    _replace(updated);
    notifyListeners();
  }

  Future<void> setDefault(String uid, String addressId) async {
    if (_repository == null) {
      await _legacyService.setDefault(uid, addressId);
    } else {
      await _repository.setDefault(addressId);
    }
    _addresses = _addresses
        .map((address) => address.copyWith(isDefault: address.id == addressId))
        .toList();
    notifyListeners();
  }

  Future<void> delete(String uid, String addressId) async {
    if (_repository == null) {
      await _legacyService.deleteAddress(uid, addressId);
    } else {
      await _repository.delete(addressId);
    }
    _addresses.removeWhere((address) => address.id == addressId);
    notifyListeners();
  }

  Future<AddressModel> _legacyUpdate(String uid, AddressModel address) async {
    await _legacyService.updateAddress(uid, address);
    return address;
  }

  AddressService get _legacyService {
    final service = _service;
    if (service != null) return service;
    throw StateError('O serviço legado de endereços não está configurado.');
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
