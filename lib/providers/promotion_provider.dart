import 'package:flutter/foundation.dart';
import '../models/promotion_model.dart';
import '../services/promotion_service.dart';

class PromotionProvider extends ChangeNotifier {
  final PromotionService _service;

  PromotionProvider({PromotionService? service})
    : _service = service ?? PromotionService();

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
      _promotions = await _service.fetchActivePromotions();
    } catch (e) {
      _error = 'Não foi possível carregar as promoções.';
      debugPrint('[PromotionProvider] erro: $e');
    }

    _isLoading = false;
    notifyListeners();
  }
}
