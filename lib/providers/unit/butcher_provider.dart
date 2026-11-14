import 'package:flutter/foundation.dart';
import '../../models/product_model.dart';
import '../../models/category_model.dart';
import '../../models/promotion_model.dart';
import '../../models/business_hours_model.dart';
import '../../models/review_model.dart';
import '../../services/product_service.dart';
import '../../services/promotion_service.dart';
import '../../services/business_hours_service.dart';
import '../../services/review_service.dart';

class ButcherProvider extends ChangeNotifier {
  ButcherProvider({
    required this.unitId,
    required ProductService productService,
    required ReviewService reviewService,
    required PromotionService promotionService,
    required BusinessHoursService hoursService,
  }) : _productService = productService,
       _reviewService = reviewService,
       _promotionService = promotionService,
       _hoursService = hoursService;
  final String unitId;
  final ProductService _productService;
  final ReviewService _reviewService;
  final PromotionService _promotionService;
  final BusinessHoursService _hoursService;
  List<ProductModel> _catalog = [];
  List<CategoryModel> _categories = [];
  List<PromotionModel> _promotions = [];
  List<ReviewModel> _reviews = [];
  BusinessHoursModel? _todayHours;
  bool _isLoading = false;
  bool _disposed = false;
  int _generation = 0;
  String? _error;
  String? _warning;
  String nameFilter = '';
  String brandFilter = '';
  String categoryFilter = '';
  double? maxPriceFilter;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get warning => _warning;
  BusinessHoursModel? get todayHours => _todayHours;
  bool get isOpenNow => _todayHours?.isOpenNow ?? true;
  List<ReviewModel> get reviews => List.unmodifiable(_reviews);
  List<PromotionModel> get promotions => List.unmodifiable(_promotions);
  bool get hasCatalog => _catalog.isNotEmpty;
  int get catalogCount => _catalog.length;
  int get advancedFilterCount =>
      (brandFilter.isEmpty ? 0 : 1) +
      (categoryFilter.isEmpty ? 0 : 1) +
      (maxPriceFilter == null ? 0 : 1);
  bool get hasFilters =>
      nameFilter.trim().isNotEmpty || advancedFilterCount > 0;

  static String _normalize(String text) {
    var value = text.trim().toLowerCase();
    const original = 'áàâãäéèêëíìîïóòôõöúùûüç';
    const plain = 'aaaaaeeeeiiiiooooouuuuc';
    for (var i = 0; i < original.length; i++) {
      value = value.replaceAll(original[i], plain[i]);
    }
    return value;
  }

  String _categoryId(ProductModel product) =>
      _categories.any((category) => category.id == product.categoryId)
      ? product.categoryId
      : '__other__';
  List<CategoryModel> get categories {
    final ids = _catalog.map(_categoryId).toSet();
    final result =
        _categories.where((category) => ids.contains(category.id)).toList()
          ..sort((a, b) => _normalize(a.name).compareTo(_normalize(b.name)));
    if (ids.contains('__other__')) {
      result.add(
        CategoryModel(
          id: '__other__',
          name: 'Outros produtos',
          description: '',
          active: true,
          unitId: unitId,
        ),
      );
    }
    return result;
  }

  List<String> get brands =>
      _catalog
          .map((product) => product.brand.trim())
          .where((brand) => brand.isNotEmpty)
          .toSet()
          .toList()
        ..sort((a, b) => _normalize(a).compareTo(_normalize(b)));
  List<ProductModel> get items =>
      _catalog
          .where(
            (product) =>
                (nameFilter.isEmpty ||
                    _normalize(
                      product.name,
                    ).contains(_normalize(nameFilter))) &&
                (brandFilter.isEmpty ||
                    _normalize(product.brand) == _normalize(brandFilter)) &&
                (categoryFilter.isEmpty ||
                    _categoryId(product) == categoryFilter) &&
                (maxPriceFilter == null || product.price <= maxPriceFilter!),
          )
          .toList()
        ..sort((a, b) => _normalize(a.name).compareTo(_normalize(b.name)));
  Map<String, List<ProductModel>> get groupedProducts {
    final visible = items;
    final groups = <String, List<ProductModel>>{};
    for (final category in categories) {
      final products = visible
          .where((product) => _categoryId(product) == category.id)
          .toList();
      if (products.isNotEmpty) {
        groups.putIfAbsent(category.name, () => []).addAll(products);
      }
    }
    return groups;
  }

  Future<void> applyFilters({
    String name = '',
    String brand = '',
    String category = '',
    double? maxPrice,
  }) async {
    if (_disposed) return;
    nameFilter = name;
    brandFilter = brand.trim();
    categoryFilter = category.trim();
    maxPriceFilter = maxPrice;
    notifyListeners();
  }

  Future<List<ProductModel>> _loadCatalog() async {
    final products = <String, ProductModel>{};
    Object? cursor;
    do {
      final page = await _productService.fetchByUnitId(
        unitId: unitId,
        startAfter: cursor,
      );
      for (final product in page.items) {
        products[product.id] = product;
      }
      if (!page.hasMore) break;
      cursor = page.lastDoc;
      if (cursor == null) throw StateError('Paginação de produtos inválida.');
    } while (true);
    return products.values.toList();
  }

  Future<void> loadProducts() async {
    final generation = ++_generation;
    _isLoading = true;
    _error = null;
    _warning = null;
    notifyListeners();
    var supplementalFailure = false;
    Future<T> optional<T>(Future<T> request, T fallback) async {
      try {
        return await request;
      } catch (_) {
        supplementalFailure = true;
        return fallback;
      }
    }

    try {
      final values = await Future.wait<Object?>([
        _loadCatalog(),
        optional(_productService.categoriesForUnit(unitId), <CategoryModel>[]),
        optional(
          _promotionService.fetchActivePromotionsByUnit(unitId: unitId),
          <PromotionModel>[],
        ),
        optional(_hoursService.fetchToday(unitId), null),
        optional(
          _reviewService.watchUnitReviews(unitId, limit: 3).first,
          <ReviewModel>[],
        ),
      ]);
      if (_disposed || generation != _generation) return;
      _catalog = values[0] as List<ProductModel>;
      _categories = values[1] as List<CategoryModel>;
      _promotions = values[2] as List<PromotionModel>;
      _todayHours = values[3] as BusinessHoursModel?;
      _reviews = values[4] as List<ReviewModel>;
      if (!categories.any((category) => category.id == categoryFilter)) {
        categoryFilter = '';
      }
      if (!brands.contains(brandFilter)) brandFilter = '';
      if (supplementalFailure) {
        _warning = 'Algumas informações não foram carregadas.';
      }
    } catch (_) {
      if (!_disposed && generation == _generation) {
        _error = 'Não foi possível carregar o catálogo. Tente novamente.';
      }
    } finally {
      if (!_disposed && generation == _generation) {
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  @override
  void dispose() {
    _disposed = true;
    _generation++;
    super.dispose();
  }
}
