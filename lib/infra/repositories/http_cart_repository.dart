import '../../core/network/api_failure.dart';
import '../../data/repositories/cart_repository.dart';
import '../../models/cart_item_model.dart';
import '../http/api_client.dart';

final class HttpCartRepository implements CartRepository {
  HttpCartRepository(this._client);

  final ApiClient _client;

  @override
  Future<List<CartItemModel>> getCart() => _client.get('/cart', decode: _items);

  @override
  Future<List<CartItemModel>> addItem(String productId, double quantity) =>
      _client.post(
        '/cart/items',
        body: {'product_id': int.parse(productId), 'quantity': quantity},
        decode: _items,
      );

  @override
  Future<List<CartItemModel>> updateItem(String itemId, double quantity) =>
      _client.patch(
        '/cart/items/$itemId',
        body: {'quantity': quantity},
        decode: _items,
      );

  @override
  Future<List<CartItemModel>> removeItem(String itemId) =>
      _client.delete('/cart/items/$itemId', decode: _items);

  @override
  Future<List<CartItemModel>> clear() =>
      _client.delete('/cart', decode: _items);

  static List<CartItemModel> _items(Object? value) {
    final map = _map(value);
    final rawItems = map['items'];
    if (rawItems is! List) throw _malformed();
    return rawItems
        .map((item) => CartItemModel.fromApi(_map(item)))
        .toList(growable: false);
  }

  static Map<String, Object?> _map(Object? value) {
    if (value is Map<String, Object?>) return value;
    throw _malformed();
  }

  static ApiFailure _malformed() => const ApiFailure(
    kind: ApiFailureKind.malformedResponse,
    message: 'O carrinho retornado é inválido.',
    code: 'MALFORMED_CART_RESPONSE',
  );
}
