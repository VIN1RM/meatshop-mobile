import 'package:flutter/foundation.dart';
import 'package:meatshop_mobile/models/product_review_model.dart';
import '../data/repositories/review_repository.dart';

class ProductReviewProvider extends ChangeNotifier {
  ProductReviewProvider({required ReviewRepository repository})
    : _repository = repository;
  final ReviewRepository _repository;

  bool _isLoading = false;
  String? _error;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<bool> hasReviewedProduct({
    required String orderId,
    required String productId,
  }) => _repository
      .getOrderStatus(orderId)
      .then((status) => status.reviewedProductIds.contains(productId));

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
      await _repository.reviewProduct(orderId, productId, rating, comment);
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
      for (final review in reviews) {
        await _repository.reviewProduct(
          review.orderId,
          review.productId,
          review.rating,
          review.comment,
        );
      }
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
      Stream.fromFuture(_repository.listProductReviews(productId));
}
