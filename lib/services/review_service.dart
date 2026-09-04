import '../data/repositories/marketplace_repository.dart';
import '../models/review_model.dart';

/// Adaptador de apresentação para telas que consomem avaliações como stream.
/// A fonte é exclusivamente a API MeatShop.
final class ReviewService {
  ReviewService({required MarketplaceRepository marketplace})
    : _marketplace = marketplace;

  final MarketplaceRepository _marketplace;

  Stream<List<ReviewModel>> watchUnitReviews(String unitId, {int? limit}) =>
      Stream.fromFuture(
        _marketplace
            .listReviews(unitId: unitId, limit: limit ?? 20)
            .then((page) => page.items),
      );

  Stream<List<ReviewModel>> watchProductReviews(
    String productId, {
    int? limit,
  }) => Stream.fromFuture(
    _marketplace
        .listReviews(productId: productId, limit: limit ?? 20)
        .then((page) => page.items),
  );
}
