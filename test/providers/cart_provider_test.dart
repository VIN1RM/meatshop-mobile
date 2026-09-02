import 'package:flutter_test/flutter_test.dart';
import 'package:meatshop_mobile/data/repositories/cart_repository.dart';
import 'package:meatshop_mobile/models/cart_item_model.dart';
import 'package:meatshop_mobile/providers/cart_provider.dart';

void main() {
  test('preserves multi-unit cart and clears remote persistence', () async {
    final repository = _FakeCartRepository();
    final provider = CartProvider(uid: 'firebase-user', repository: repository);

    await provider.addItem(_item(productId: '1', unitId: '10'));

    expect(provider.itemsByUnit.keys, {'10', '20'});
    expect(provider.items, hasLength(2));

    await provider.clearCart();

    expect(repository.clearCalls, 1);
    expect(provider.items, isEmpty);
  });
}

CartItemModel _item({required String productId, required String unitId}) =>
    CartItemModel(
      cartItemId: productId,
      productId: productId,
      productName: 'Produto $productId',
      productImageUrl: '',
      unitOfMeasure: 'KG',
      unitPrice: 20,
      quantity: 0.5,
      unitId: unitId,
      unitName: 'Unidade $unitId',
    );

final class _FakeCartRepository implements CartRepository {
  int clearCalls = 0;

  @override
  Future<List<CartItemModel>> addItem(
    String productId,
    double quantity,
  ) async => [
    _item(productId: '1', unitId: '10'),
    _item(productId: '2', unitId: '20'),
  ];

  @override
  Future<List<CartItemModel>> clear() async {
    clearCalls++;
    return [];
  }

  @override
  Future<List<CartItemModel>> getCart() async => [];

  @override
  Future<List<CartItemModel>> removeItem(String itemId) async => [];

  @override
  Future<List<CartItemModel>> updateItem(
    String itemId,
    double quantity,
  ) async => [];
}
