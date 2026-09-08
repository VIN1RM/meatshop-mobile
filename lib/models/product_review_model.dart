class ProductReviewModel {
  final String id;
  final String orderId;
  final String clientId;
  final String productId;
  final String productName;
  final String productImageUrl;
  final String unitId;
  final int rating;
  final String comment;
  final DateTime createdAt;

  const ProductReviewModel({
    required this.id,
    required this.orderId,
    required this.clientId,
    required this.productId,
    required this.productName,
    required this.productImageUrl,
    required this.unitId,
    required this.rating,
    required this.comment,
    required this.createdAt,
  });

  bool get hasComment => comment.trim().isNotEmpty;
}
