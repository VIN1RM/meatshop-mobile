import 'package:flutter/foundation.dart';
import '../data/repositories/review_repository.dart';

class ReviewProvider extends ChangeNotifier {
  ReviewProvider({required ReviewRepository repository})
    : _repository = repository;
  final ReviewRepository _repository;

  bool _isLoading = false;
  String? _error;
  bool _submitted = false;

  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get submitted => _submitted;

  Future<bool> hasReviewed(String orderId) async =>
      (await _repository.getOrderStatus(orderId)).unitReviewed;

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
      await _repository.reviewUnit(orderId, unitRating, unitComment);
      if (deliveryPersonId != null && deliveryRating != null) {
        await _repository.reviewDelivery(
          orderId,
          deliveryRating,
          deliveryComment ?? '',
        );
      }
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
