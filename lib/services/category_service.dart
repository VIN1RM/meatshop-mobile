import '../data/repositories/marketplace_repository.dart';

class CategoryService {
  CategoryService({required MarketplaceRepository marketplace})
    : _marketplace = marketplace;
  final MarketplaceRepository _marketplace;

  Future<List<String>> fetchCategoryIdsByName(String name) async {
    final categories = await _marketplace.listCategories();
    return categories
        .where((item) => item.name.toLowerCase() == name.toLowerCase())
        .map((item) => item.id)
        .toList();
  }
}
