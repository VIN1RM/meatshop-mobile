import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/product_model.dart';
import '../services/product_service.dart';
import '../services/category_service.dart';

enum ProductSortOrder { nameAZ, nameZA, priceAsc, priceDesc }

enum ProductPriceRange { all, upTo20, from20to50, above50 }

class ProductsProvider extends ChangeNotifier {
  final ProductService _service;
  final CategoryService _categoryService;

  final String categoryName;

  ProductsProvider({
    required this.categoryName,
    ProductService? service,
    CategoryService? categoryService,
  }) : _service = service ?? ProductService(),
       _categoryService = categoryService ?? CategoryService();

  final List<ProductModel> _items = [];
  List<ProductModel> get items => _filteredAndSorted;

  List<String> _categoryIds = [];

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isLoadingMore = false;
  bool get isLoadingMore => _isLoadingMore;

  bool _hasMore = true;
  bool get hasMore => _hasMore;

  String? _error;
  String? get error => _error;

  DocumentSnapshot? _lastDoc;

  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  ProductSortOrder _sortOrder = ProductSortOrder.nameAZ;
  ProductSortOrder get sortOrder => _sortOrder;

  ProductPriceRange _priceRange = ProductPriceRange.all;
  ProductPriceRange get priceRange => _priceRange;

  List<ProductModel> get _filteredAndSorted {
    var list = _items.where((p) => p.stockQuantity > 0).toList();

    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      list = list.where((p) => p.name.toLowerCase().contains(q)).toList();
    }

    switch (_priceRange) {
      case ProductPriceRange.upTo20:
        list = list.where((p) => p.price <= 20).toList();
      case ProductPriceRange.from20to50:
        list = list.where((p) => p.price > 20 && p.price <= 50).toList();
      case ProductPriceRange.above50:
        list = list.where((p) => p.price > 50).toList();
      case ProductPriceRange.all:
        break;
    }

    switch (_sortOrder) {
      case ProductSortOrder.nameAZ:
        list.sort((a, b) => a.name.compareTo(b.name));
      case ProductSortOrder.nameZA:
        list.sort((a, b) => b.name.compareTo(a.name));
      case ProductSortOrder.priceAsc:
        list.sort((a, b) => a.price.compareTo(b.price));
      case ProductSortOrder.priceDesc:
        list.sort((a, b) => b.price.compareTo(a.price));
    }

    return list;
  }

  Future<void> loadFirstPage() async {
    _items.clear();
    _lastDoc = null;
    _hasMore = true;
    _error = null;
    _isLoading = true;
    notifyListeners();

    try {
      _categoryIds = await _categoryService.fetchCategoryIdsByName(
        categoryName,
      );
    } catch (e) {
      _error = 'Não foi possível carregar as categorias. Tente novamente.';
      debugPrint('[ProductsProvider] erro ao buscar categorias: $e');
      _isLoading = false;
      notifyListeners();
      return;
    }

    await _fetchNextPage();

    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadMore() async {
    if (_isLoadingMore || !_hasMore) return;
    _isLoadingMore = true;
    notifyListeners();
    await _fetchNextPage();
    _isLoadingMore = false;
    notifyListeners();
  }

  Future<void> _fetchNextPage() async {
    try {
      final page = await _service.fetchByCategoryIds(
        categoryIds: _categoryIds,
        startAfter: _lastDoc,
        searchQuery: _searchQuery,
      );
      _items.addAll(page.items);
      _lastDoc = page.lastDoc;
      _hasMore = page.hasMore;
      _error = null;
    } catch (e) {
      _error = 'Não foi possível carregar os produtos. Tente novamente.';
      debugPrint('[ProductsProvider] erro: $e');
    }
  }

  Future<void> updateSearch(String query) async {
    if (_searchQuery == query) return;
    _searchQuery = query;
    await loadFirstPage();
  }

  void updateSort(ProductSortOrder order) {
    _sortOrder = order;
    notifyListeners();
  }

  void updatePriceRange(ProductPriceRange range) {
    _priceRange = range;
    notifyListeners();
  }

  void updateFilters({
    required ProductSortOrder order,
    required ProductPriceRange range,
  }) {
    _sortOrder = order;
    _priceRange = range;
    notifyListeners();
  }
}
