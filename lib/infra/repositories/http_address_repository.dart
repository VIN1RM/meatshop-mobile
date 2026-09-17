import '../../core/network/api_failure.dart';
import '../../data/repositories/address_repository.dart';
import '../../models/address_model.dart';
import '../http/api_client.dart';

final class HttpAddressRepository implements AddressRepository {
  HttpAddressRepository(this._client);

  final ApiClient _client;

  @override
  Future<List<AddressModel>> list() =>
      _client.get('/addresses', decode: (json) => _list(json));

  @override
  Future<AddressModel> create(AddressModel address) => _client.post(
    '/addresses',
    body: address.toApi(),
    decode: (json) => AddressModel.fromApi(_map(json)),
  );

  @override
  Future<AddressModel> update(AddressModel address) {
    final body = Map<String, Object?>.from(address.toApi())
      ..remove('is_default');
    return _client.patch(
      '/addresses/${address.id}',
      body: body,
      decode: (json) => AddressModel.fromApi(_map(json)),
    );
  }

  @override
  Future<AddressModel> setDefault(String addressId) => _client.patch(
    '/addresses/$addressId/default',
    decode: (json) => AddressModel.fromApi(_map(json)),
  );

  @override
  Future<void> delete(String addressId) =>
      _client.delete('/addresses/$addressId', decode: (_) {});

  @override
  Future<AddressModel> resolveZipCode(String zipCode) => _client.post(
    '/geocoding/resolve',
    body: {'zip_code': zipCode},
    decode: (json) => AddressModel.fromApi(_map(json)),
  );

  static List<AddressModel> _list(Object? value) {
    if (value is! List) throw _malformed();
    return value
        .map((item) => AddressModel.fromApi(_map(item)))
        .toList(growable: false);
  }

  static Map<String, Object?> _map(Object? value) {
    if (value is Map<String, Object?>) return value;
    throw _malformed();
  }

  static ApiFailure _malformed() => const ApiFailure(
    kind: ApiFailureKind.malformedResponse,
    message: 'O endereço retornado é inválido.',
    code: 'MALFORMED_ADDRESS_RESPONSE',
  );
}
