import 'package:flutter_test/flutter_test.dart';
import 'package:meatshop_mobile/providers/product_provider.dart';
import 'package:meatshop_mobile/services/product_service.dart';
import 'package:meatshop_mobile/services/category_service.dart';
import 'package:meatshop_mobile/services/unit_service.dart';
import 'package:meatshop_mobile/data/repositories/marketplace_repository.dart';
import 'package:meatshop_mobile/models/product_model.dart';

void main() {
  test('filters every category ID in the group before pagination', () async {
    final service = _Products();
    final page = await service.filteredByCategoryIds(
      categoryIds: ['1', '2'],
      name: 'Picanha',
      brand: 'Marca',
      minPrice: 20,
      maxPrice: 50,
      page: 2,
    );
    expect(service.categories, ['1', '2']);
    expect(service.names, ['Picanha', 'Picanha']);
    expect(service.brands, ['Marca', 'Marca']);
    expect(service.minPrices, [20, 20]);
    expect(service.maxPrices, [50, 50]);
    expect(service.pages, [2, 2]);
    expect(page.items.length, 2);
    expect(page.hasMore, isFalse);
  });

  test('an empty group never falls back to all marketplace products', () async {
    final service = _Products();
    final page = await service.filteredByCategoryIds(
      categoryIds: [],
      name: 'Picanha',
    );
    expect(page.items, isEmpty);
    expect(service.categories, isEmpty);
  });

  test(
    'a category search result keeps its exact ID and skips name resolution',
    () async {
      final service = _Products();
      final categories = _Categories();
      final provider = ProductsProvider(
        categoryName: 'Linha premium',
        categoryId: '99',
        service: service,
        categoryService: categories,
        unitService: UnitService(marketplace: _Marketplace()),
      );
      await provider.loadFirstPage();
      await provider.updateSearch('Picanha');
      expect(categories.calls, 0);
      expect(service.categories, ['99']);
      provider.dispose();
    },
  );

  test(
    'name search queries all server products before pagination and retains filters',
    () async {
      final service = _Products();
      final provider = ProductsProvider(
        categoryName: 'Bovinos',
        service: service,
        categoryService: _Categories(),
        unitService: UnitService(marketplace: _Marketplace()),
      );
      await provider.loadFirstPage();
      expect(provider.items, isEmpty);
      await provider.updateSearch('Picanha');
      expect(service.names, ['Picanha']);
      expect(service.categories, ['1']);
      expect(provider.items.single.name, 'Picanha fora da primeira página');
      expect(provider.hasMore, isTrue);
      await provider.loadMore();
      expect(service.pages, [1, 2]);
      expect(provider.items.length, 2);
      expect(provider.hasMore, isFalse);
      provider.dispose();
    },
  );
}

class _Marketplace implements MarketplaceRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Categories extends CategoryService {
  _Categories() : super(marketplace: _Marketplace());
  @override
  Future<List<String>> fetchCategoryIdsByName(String name) async {
    calls++;
    return ['1'];
  }

  int calls = 0;
}

class _Products extends ProductService {
  _Products() : super(marketplace: _Marketplace());
  final brands = <String>[];
  final minPrices = <double>[];
  final maxPrices = <double?>[];
  final names = <String>[];
  final categories = <String?>[];
  final pages = <int>[];
  @override
  Future<ProductPage> fetchByCategoryIds({
    required List<String> categoryIds,
    Object? startAfter,
    String searchQuery = '',
  }) async => const ProductPage(items: [], lastDoc: null, hasMore: false);
  @override
  Future<ProductPage> filtered({
    String? unitId,
    String? categoryId,
    String? category,
    String name = '',
    String brand = '',
    double minPrice = 0,
    double? maxPrice,
    int page = 1,
  }) async {
    names.add(name);
    brands.add(brand);
    minPrices.add(minPrice);
    maxPrices.add(maxPrice);
    categories.add(categoryId);
    pages.add(page);
    return ProductPage(
      items: [
        ProductModel(
          id: '$categoryId:$page',
          name: 'Picanha fora da primeira página',
          description: '',
          price: 50,
          unitOfMeasure: 'kg',
          active: true,
          brand: '',
          imageUrl: '',
          unitId: '',
          unitName: '',
          categoryId: '1',
          stockQuantity: 5,
        ),
      ],
      lastDoc: page == 1 ? 2 : null,
      hasMore: page == 1,
    );
  }
}
