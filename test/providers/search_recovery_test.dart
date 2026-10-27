import 'package:flutter_test/flutter_test.dart';
import 'package:meatshop_mobile/providers/search_provider.dart';
import 'package:meatshop_mobile/services/search_service.dart';
import 'package:meatshop_mobile/data/repositories/marketplace_repository.dart';
import 'package:meatshop_mobile/core/network/page.dart';
import 'package:meatshop_mobile/models/search_model.dart';
import 'package:meatshop_mobile/models/category_model.dart';

class SearchRepository extends Fake implements MarketplaceRepository {
  bool fail = true;
  bool failBrands = false;
  String? searchedCategory;
  String? searchedBrand;
  double? searchedMinPrice;
  double? searchedMaxPrice;
  @override
  Future<Page<SearchResultModel>> search(
    String query, {
    String? unitId,
    String? categoryId,
    String? category,
    double? minPrice,
    double? maxPrice,
    String? brand,
    int page = 1,
    int limit = 20,
  }) async {
    searchedCategory = category;
    searchedBrand = brand;
    searchedMinPrice = minPrice;
    searchedMaxPrice = maxPrice;
    if (fail) throw StateError('offline');
    return const Page(
      items: [],
      meta: PageMeta(page: 1, limit: 20, total: 0, totalPages: 0),
    );
  }

  @override
  Future<List<String>> listBrands({
    String? unitId,
    String? categoryId,
    String? category,
  }) async {
    if (failBrands) throw StateError('offline');
    return ['Friboi'];
  }

  @override
  Future<List<CategoryModel>> listCategories({String? unitId}) async => const [
    CategoryModel(
      id: '1',
      name: 'Bovinos',
      description: '',
      active: true,
      unitId: '1',
    ),
    CategoryModel(
      id: '2',
      name: 'bovinos',
      description: '',
      active: true,
      unitId: '2',
    ),
  ];
}

void main() {
  testWidgets('failed search stops loading and can retry', (tester) async {
    final repository = SearchRepository();
    final provider = SearchProvider(
      service: SearchService(marketplace: repository),
    );
    provider.onQueryChanged('carne');
    await tester.pump(const Duration(milliseconds: 401));
    expect(provider.isLoading, false);
    expect(provider.error, isNotNull);
    repository.fail = false;
    provider.onQueryChanged('carne');
    await tester.pump(const Duration(milliseconds: 401));
    expect(provider.error, isNull);
    expect(provider.isLoading, false);
    provider.dispose();
  });

  testWidgets('applies a brand filter without requiring a text query', (
    tester,
  ) async {
    final repository = SearchRepository()..fail = false;
    final provider = SearchProvider(
      service: SearchService(marketplace: repository),
    );
    await provider.loadFilters();
    expect(provider.brands, ['Friboi']);
    provider.applyFilters(
      category: 'Bovinos',
      brand: 'Friboi',
      minPrice: 30,
      maxPrice: 100,
    );
    await tester.pump(const Duration(milliseconds: 401));
    expect(provider.hasFilters, isTrue);
    expect(provider.isLoading, isFalse);
    expect(repository.searchedCategory, 'Bovinos');
    expect(repository.searchedBrand, 'Friboi');
    expect(repository.searchedMinPrice, 30);
    expect(repository.searchedMaxPrice, 100);
    expect(provider.availableCategories, ['Bovinos']);
    provider.applyFilters();
    expect(provider.hasFilters, isFalse);
    provider.dispose();
  });

  test('brand filters expose a recoverable loading error', () async {
    final repository = SearchRepository()..failBrands = true;
    final provider = SearchProvider(
      service: SearchService(marketplace: repository),
    );

    await provider.loadFilters();
    expect(provider.filterError, isNotNull);
    expect(provider.loadingFilters, isFalse);

    repository.failBrands = false;
    await provider.loadFilters(force: true);
    expect(provider.filterError, isNull);
    expect(provider.brands, ['Friboi']);
    provider.dispose();
  });
}
