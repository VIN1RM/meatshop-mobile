import '../data/repositories/marketplace_repository.dart';
import '../models/product_model.dart';

class ProductPage {
  const ProductPage({
    required this.items,
    required this.lastDoc,
    required this.hasMore,
  });
  final List<ProductModel> items;
  final Object? lastDoc;
  final bool hasMore;
}

class ProductService {
  ProductService({required MarketplaceRepository marketplace})
    : _marketplace = marketplace;
  static const int _pageSize = 10;
  final MarketplaceRepository _marketplace;

  Future<ProductPage> fetchByCategory({
    required String categoryId,
    Object? startAfter,
    String searchQuery = '',
  }) => _page(
    categoryIds: [categoryId],
    startAfter: startAfter,
    searchQuery: searchQuery,
  );

  Future<ProductPage> fetchByCategoryIds({
    required List<String> categoryIds,
    Object? startAfter,
    String searchQuery = '',
  }) => _page(
    categoryIds: categoryIds,
    startAfter: startAfter,
    searchQuery: searchQuery,
  );

  Future<ProductPage> _page({
    required List<String> categoryIds,
    Object? startAfter,
    required String searchQuery,
  }) async {
    if (categoryIds.isEmpty)
      return const ProductPage(items: [], lastDoc: null, hasMore: false);
    final pageNumber = startAfter is int ? startAfter : 1;
    final pages = await Future.wait(
      categoryIds.map(
        (id) => _marketplace.listProducts(
          categoryId: id,
          page: pageNumber,
          limit: _pageSize,
        ),
      ),
    );
    var items = pages.expand((page) => page.items).toList();
    if (searchQuery.isNotEmpty) {
      final query = searchQuery.toLowerCase();
      items = items
          .where((product) => product.name.toLowerCase().contains(query))
          .toList();
    }
    final hasMore = pages.any((page) => page.meta.hasNextPage);
    return ProductPage(
      items: items,
      lastDoc: hasMore ? pageNumber + 1 : null,
      hasMore: hasMore,
    );
  }

  Future<ProductPage> fetchByUnitId({
    required String unitId,
    Object? startAfter,
  }) async {
    final pageNumber = startAfter is int ? startAfter : 1;
    final page = await _marketplace.listProducts(
      unitId: unitId,
      page: pageNumber,
      limit: 50,
    );
    return ProductPage(
      items: page.items,
      lastDoc: page.meta.hasNextPage ? pageNumber + 1 : null,
      hasMore: page.meta.hasNextPage,
    );
  }
}
