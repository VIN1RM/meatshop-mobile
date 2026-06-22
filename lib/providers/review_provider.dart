import 'package:flutter/foundation.dart';
import 'package:meatshop_mobile/services/review_service.dart';

class ReviewProvider extends ChangeNotifier {
  ReviewProvider({ReviewService? service})
    : _service = service ?? ReviewService();

  final ReviewService _service;

  bool _isLoading = false;
  String? _error;
  bool _submitted = false;

  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get submitted => _submitted;

  Future<bool> hasReviewed(String orderId) => _service.hasReviewed(orderId);

  Future<bool> submit({
    required String orderId,
    required String unitId,
    required int unitRating,
    required String unitComment,
    String? deliveryPersonId,
    int? deliveryRating,
    String? deliveryComment,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _service.submitReviews(
        orderId: orderId,
        unitId: unitId,
        unitRating: unitRating,
        unitComment: unitComment,
        deliveryPersonId: deliveryPersonId,
        deliveryRating: deliveryRating,
        deliveryComment: deliveryComment,
      );
      _submitted = true;
      return true;
    } catch (e) {
      _error = 'Erro ao enviar avaliação: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void reset() {
    _submitted = false;
    _error = null;
    _isLoading = false;
    notifyListeners();
  }
}
