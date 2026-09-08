import 'package:flutter/foundation.dart';
import '../models/promotion_model.dart';
import '../services/promotion_service.dart';
import '../services/unit_service.dart';

class PromotionProvider extends ChangeNotifier {
  final PromotionService _service;
  final UnitService _unitService;

  PromotionProvider({
    required PromotionService service,
    required UnitService unitService,
  }) : _service = service,
       _unitService = unitService;

  List<PromotionModel> _promotions = [];
  List<PromotionModel> get promotions => _promotions;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  Future<void> loadPromotions() async {
    if (_isLoading) return;
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final raw = await _service.fetchActivePromotions();
      _promotions = await _resolveUnitNames(raw);
    } catch (e) {
      _error = 'Não foi possível carregar as promoções.';
      debugPrint('[PromotionProvider] erro: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<List<PromotionModel>> _resolveUnitNames(
    List<PromotionModel> items,
  ) async {
    final ids = items.map((p) => p.unitId).where((id) => id.isNotEmpty).toSet();
    final Map<String, String> cache = {};
    for (final id in ids) {
      try {
        final unit = await _unitService.getUnitById(id);
        if (unit != null) cache[id] = unit.name;
      } catch (_) {}
    }
    return items
        .map((p) => p.copyWith(unitName: cache[p.unitId] ?? ''))
        .toList();
  }
}
