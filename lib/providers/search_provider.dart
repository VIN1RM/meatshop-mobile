import 'dart:async';
import 'package:flutter/material.dart';
import 'package:meatshop_mobile/models/search_model.dart';
import 'package:meatshop_mobile/core/enums/search_type_enum.dart';
import 'package:meatshop_mobile/services/search_service.dart';

class SearchProvider extends ChangeNotifier {
  SearchProvider({required SearchService service}) : _service = service;
  final SearchService _service;

  String _query = '';
  String? error;
  bool _isLoading = false;
  List<SearchResultModel> _results = [];
  List<String> _brands = [];
  List<String> _availableCategories = [];
  String? _selectedBrand;
  String? _selectedCategory;
  double? _minPrice;
  double? _maxPrice;
  bool _loadingFilters = false;
  String? _filterError;
  Timer? _debounce;
  int _generation = 0;

  String get query => _query;
  bool get isLoading => _isLoading;
  List<SearchResultModel> get results => _results;
  List<String> get brands => List.unmodifiable(_brands);
  List<String> get availableCategories =>
      List.unmodifiable(_availableCategories);
  String? get selectedBrand => _selectedBrand;
  String? get selectedCategory => _selectedCategory;
  double? get minPrice => _minPrice;
  double? get maxPrice => _maxPrice;
  bool get loadingFilters => _loadingFilters;
  String? get filterError => _filterError;
  bool get hasFilters =>
      _selectedBrand != null ||
      _selectedCategory != null ||
      _minPrice != null ||
      _maxPrice != null;
  bool get hasCriteria => _query.trim().isNotEmpty || hasFilters;

  List<SearchResultModel> get butchers =>
      _results.where((r) => r.type == SearchResultType.butcher).toList();
  List<SearchResultModel> get categories =>
      _results.where((r) => r.type == SearchResultType.category).toList();
  List<SearchResultModel> get products =>
      _results.where((r) => r.type == SearchResultType.product).toList();

  bool get isEmpty => hasCriteria && !_isLoading && _results.isEmpty;

  Future<void> loadFilters({bool force = false}) async {
    if (_loadingFilters ||
        (!force && _brands.isNotEmpty && _availableCategories.isNotEmpty)) {
      return;
    }
    _loadingFilters = true;
    _filterError = null;
    notifyListeners();
    try {
      final filters = await Future.wait([
        _service.listBrands(),
        _service.listCategories(),
      ]);
      _brands = filters[0];
      _availableCategories = filters[1];
    } catch (_) {
      _brands = [];
      _availableCategories = [];
      _filterError = 'Não foi possível carregar as marcas. Tente novamente.';
    } finally {
      _loadingFilters = false;
      notifyListeners();
    }
  }

  void onQueryChanged(String value) {
    final generation = ++_generation;
    _query = value;
    error = null;
    _debounce?.cancel();

    if (value.trim().isEmpty && !hasFilters) {
      _results = [];
      _isLoading = false;
      notifyListeners();
      return;
    }

    _isLoading = true;
    notifyListeners();

    _debounce = Timer(const Duration(milliseconds: 400), () async {
      try {
        final results = await _service.search(
          value,
          category: _selectedCategory,
          minPrice: _minPrice,
          maxPrice: _maxPrice,
          brand: _selectedBrand,
        );
        if (generation != _generation) return;
        _results = results;
      } catch (_) {
        if (generation != _generation) return;
        error = 'Não foi possível buscar. Tente novamente.';
      } finally {
        if (generation == _generation) {
          _isLoading = false;
          notifyListeners();
        }
      }
    });
  }

  void applyFilters({
    String? category,
    String? brand,
    double? minPrice,
    double? maxPrice,
  }) {
    _selectedCategory = _normalize(category);
    _selectedBrand = _normalize(brand);
    _minPrice = minPrice;
    _maxPrice = maxPrice;
    onQueryChanged(_query);
  }

  String? _normalize(String? value) {
    final normalized = value?.trim();
    return normalized == null || normalized.isEmpty ? null : normalized;
  }

  void clear({bool notify = true}) {
    ++_generation;
    _query = '';
    _selectedBrand = null;
    _selectedCategory = null;
    _minPrice = null;
    _maxPrice = null;
    _results = [];
    _isLoading = false;
    _debounce?.cancel();
    if (notify) notifyListeners();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }
}
