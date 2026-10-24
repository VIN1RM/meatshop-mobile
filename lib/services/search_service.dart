import 'package:meatshop_mobile/models/search_model.dart';
import '../data/repositories/marketplace_repository.dart';

class SearchService {
  SearchService({required MarketplaceRepository marketplace})
    : _marketplace = marketplace;
  final MarketplaceRepository _marketplace;

  Future<List<SearchResultModel>> search(
    String query, {
    String? category,
    double? minPrice,
    double? maxPrice,
    String? brand,
  }) async {
    final normalizedQuery = query.trim();
    final normalizedBrand = brand?.trim();
    final normalizedCategory = category?.trim();
    if (normalizedQuery.isEmpty &&
        (normalizedBrand == null || normalizedBrand.isEmpty) &&
        (normalizedCategory == null || normalizedCategory.isEmpty) &&
        minPrice == null &&
        maxPrice == null) {
      return [];
    }
    return (await _marketplace.search(
      normalizedQuery,
      category: normalizedCategory?.isEmpty == true ? null : normalizedCategory,
      minPrice: minPrice,
      maxPrice: maxPrice,
      brand: normalizedBrand?.isEmpty == true ? null : normalizedBrand,
    )).items;
  }

  Future<List<String>> listBrands({String? category}) =>
      _marketplace.listBrands(category: category);

  Future<List<String>> listCategories() async {
    final categories = await _marketplace.listCategories();
    final byName = <String, String>{};
    for (final category in categories) {
      final name = category.name.trim();
      if (name.isNotEmpty) byName.putIfAbsent(name.toLowerCase(), () => name);
    }
    final names = byName.values.toList(growable: false);
    names.sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    return names;
  }
}
