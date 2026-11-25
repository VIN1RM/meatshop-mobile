import '../../models/product_model.dart';

abstract interface class ProductDetailsRepository {
  Future<ProductModel> getProduct(String id);
}
