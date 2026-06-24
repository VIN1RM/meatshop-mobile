import 'package:flutter/foundation.dart';
import 'package:meatshop_mobile/models/product_review_model.dart';
import 'package:meatshop_mobile/services/product_review_service.dart';

class ProductReviewProvider extends ChangeNotifier {
  ProductReviewProvider({ProductReviewService? service})
    : _service = service ?? ProductReviewService();

  final ProductReviewService _service;

  bool _isLoading = false;
  String? _error;
  final Map<String, List<ProductReviewModel>> _reviewsCache = {};

  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<bool> hasReviewedProduct({
    required String orderId,
    required String productId,
  }) =>
      _service.hasReviewedProduct(orderId: orderId, productId: productId);

  Future<bool> submitProductReview({
    required String orderId,
    required String productId,
    required String productName,
    required String productImageUrl,
    required String unitId,
    required int rating,
    required String comment,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _service.submitProductReview(
        orderId: orderId,
        productId: productId,
        productName: productName,
        productImageUrl: productImageUrl,
        unitId: unitId,
        rating: rating,
        comment: comment,
      );
      return true;
    } catch (e) {
      _error = 'Erro ao enviar avaliação: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> submitMultiple(List<ProductReviewModel> reviews) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _service.submitMultipleProductReviews(reviews: reviews);
      return true;
    } catch (e) {
      _error = 'Erro ao enviar avaliações: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Stream<List<ProductReviewModel>> watchProductReviews(String productId) =>
      _service.watchProductReviews(productId);
}