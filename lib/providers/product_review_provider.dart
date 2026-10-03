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

  Future<Set<String>> reviewedProductIds(String orderId) async =>
      (await _repository.getOrderStatus(orderId)).reviewedProductIds;

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
    if (_isLoading) return false;
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      if (await hasReviewedProduct(orderId: orderId, productId: productId)) {
        return true;
      }
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
    if (_isLoading) return false;
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final reviewedByOrder = <String, Set<String>>{};
      for (final review in reviews) {
        final reviewed = reviewedByOrder[review.orderId] ??= Set.of(
          (await _repository.getOrderStatus(review.orderId)).reviewedProductIds,
        );
        if (reviewed.contains(review.productId)) continue;
        await _repository.reviewProduct(
          review.orderId,
          review.productId,
          review.rating,
          review.comment,
        );
        reviewed.add(review.productId);
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

  void reset() {
    _isLoading = false;
    _error = null;
    notifyListeners();
  }
}
