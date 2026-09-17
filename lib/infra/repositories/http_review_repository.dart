import '../../core/network/api_failure.dart';
import '../../data/repositories/marketplace_repository.dart';
import '../../data/repositories/review_repository.dart';
import '../../models/product_review_model.dart';
import '../../models/review_model.dart';
import '../http/api_client.dart';

final class HttpReviewRepository implements ReviewRepository {
  HttpReviewRepository(this._client, this._marketplace);
  final ApiClient _client;
  final MarketplaceRepository _marketplace;

  @override
  Future<OrderReviewStatus> getOrderStatus(String orderId) => _client.get(
    '/orders/$orderId/reviews/status',
    decode: (json) {
      final map = _map(json);
      final ids = map['reviewed_product_ids'];
      return OrderReviewStatus(
        unitReviewed: map['unit_reviewed'] == true,
        deliveryReviewed: map['delivery_reviewed'] == true,
        reviewedProductIds: ids is List
            ? ids.map((id) => '$id').toSet()
            : const {},
      );
    },
  );

  @override
  Future<void> reviewUnit(String orderId, int rating, String comment) =>
      _post('/orders/$orderId/reviews/unit', rating, comment);

  @override
  Future<void> reviewProduct(
    String orderId,
    String productId,
    int rating,
    String comment,
  ) => _post('/orders/$orderId/reviews/products/$productId', rating, comment);

  @override
  Future<void> reviewDelivery(String orderId, int rating, String comment) =>
      _post('/orders/$orderId/delivery-review', rating, comment);

  Future<void> _post(String path, int rating, String comment) => _client.post(
    path,
    body: {
      'rating': rating,
      if (comment.trim().isNotEmpty) 'comment': comment.trim(),
    },
    decode: (_) {},
  );

  @override
  Future<List<ReviewModel>> listUnitReviews(
    String unitId, {
    int limit = 20,
  }) async =>
      (await _marketplace.listReviews(unitId: unitId, limit: limit)).items;

  @override
  Future<List<ProductReviewModel>> listProductReviews(
    String productId, {
    int limit = 20,
  }) async {
    final page = await _marketplace.listReviews(
      productId: productId,
      limit: limit,
    );
    return page.items
        .map(
          (review) => ProductReviewModel(
            id: review.id,
            orderId: review.orderId,
            clientId: review.clientId,
            productId: productId,
            productName: '',
            productImageUrl: '',
            unitId: review.unitId,
            rating: review.rating,
            comment: review.comment,
            createdAt: review.createdAt,
          ),
        )
        .toList(growable: false);
  }

  static Map<String, Object?> _map(Object? value) {
    if (value is! Map) {
      throw const ApiFailure(
        kind: ApiFailureKind.malformedResponse,
        message: 'Resposta de avaliações inválida.',
      );
    }
    return value.map((key, item) => MapEntry(key.toString(), item));
  }
}
