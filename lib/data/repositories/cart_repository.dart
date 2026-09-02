import '../../models/cart_item_model.dart';

abstract interface class CartRepository {
  Future<List<CartItemModel>> getCart();
  Future<List<CartItemModel>> addItem(String productId, double quantity);
  Future<List<CartItemModel>> updateItem(String itemId, double quantity);
  Future<List<CartItemModel>> removeItem(String itemId);
  Future<List<CartItemModel>> clear();
}
