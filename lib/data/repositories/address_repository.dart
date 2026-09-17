import '../../models/address_model.dart';

abstract interface class AddressRepository {
  Future<List<AddressModel>> list();
  Future<AddressModel> create(AddressModel address);
  Future<AddressModel> update(AddressModel address);
  Future<AddressModel> setDefault(String addressId);
  Future<void> delete(String addressId);
  Future<AddressModel> resolveZipCode(String zipCode);
}
