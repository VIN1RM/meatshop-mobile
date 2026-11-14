import 'package:flutter_test/flutter_test.dart';
import 'package:meatshop_mobile/providers/product_provider.dart';
import 'package:meatshop_mobile/services/product_service.dart';
import 'package:meatshop_mobile/services/category_service.dart';
import 'package:meatshop_mobile/services/unit_service.dart';
import 'package:meatshop_mobile/data/repositories/marketplace_repository.dart';
import 'package:meatshop_mobile/models/product_model.dart';

void main() {
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
      expect(service.categories, ['Bovinos']);
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
  Future<List<String>> fetchCategoryIdsByName(String name) async => ['1'];
}

class _Products extends ProductService {
  _Products() : super(marketplace: _Marketplace());
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
    categories.add(category);
    pages.add(page);
    return ProductPage(
      items: [
        ProductModel(
          id: page.toString(),
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
