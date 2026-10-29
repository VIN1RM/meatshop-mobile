abstract interface class ProductImagesRepository {
  Future<List<String>> getProductImages(String productId);
}
