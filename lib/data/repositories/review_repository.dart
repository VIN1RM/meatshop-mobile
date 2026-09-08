import '../../models/product_review_model.dart';
import '../../models/review_model.dart';

final class OrderReviewStatus {
  const OrderReviewStatus({
    required this.unitReviewed,
    required this.deliveryReviewed,
    required this.reviewedProductIds,
  });

  final bool unitReviewed;
  final bool deliveryReviewed;
  final Set<String> reviewedProductIds;
}

abstract interface class ReviewRepository {
  Future<OrderReviewStatus> getOrderStatus(String orderId);
  Future<void> reviewUnit(String orderId, int rating, String comment);
  Future<void> reviewProduct(
    String orderId,
    String productId,
    int rating,
    String comment,
  );
  Future<void> reviewDelivery(String orderId, int rating, String comment);
  Future<List<ReviewModel>> listUnitReviews(String unitId, {int limit = 20});
  Future<List<ProductReviewModel>> listProductReviews(
    String productId, {
    int limit = 20,
  });
}
