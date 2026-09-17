import 'dart:async';
import 'package:flutter/material.dart';
import 'package:meatshop_mobile/models/search_model.dart';
import 'package:meatshop_mobile/core/enums/search_type_enum.dart';
import 'package:meatshop_mobile/services/search_service.dart';

class SearchProvider extends ChangeNotifier {
  SearchProvider({required SearchService service}) : _service = service;
  final SearchService _service;

  String _query = '';
  bool _isLoading = false;
  List<SearchResultModel> _results = [];
  Timer? _debounce;

  String get query => _query;
  bool get isLoading => _isLoading;
  List<SearchResultModel> get results => _results;

  List<SearchResultModel> get butchers =>
      _results.where((r) => r.type == SearchResultType.butcher).toList();
  List<SearchResultModel> get categories =>
      _results.where((r) => r.type == SearchResultType.category).toList();
  List<SearchResultModel> get products =>
      _results.where((r) => r.type == SearchResultType.product).toList();

  bool get isEmpty => _query.isNotEmpty && !_isLoading && _results.isEmpty;

  void onQueryChanged(String value) {
    _query = value;
    _debounce?.cancel();

    if (value.trim().isEmpty) {
      _results = [];
      _isLoading = false;
      notifyListeners();
      return;
    }

    _isLoading = true;
    notifyListeners();

    _debounce = Timer(const Duration(milliseconds: 400), () async {
      final results = await _service.search(value);
      _results = results;
      _isLoading = false;
      notifyListeners();
    });
  }

  void clear({bool notify = true}) {
    _query = '';
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
