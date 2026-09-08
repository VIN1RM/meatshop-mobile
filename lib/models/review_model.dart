class ReviewModel {
  final String id;
  final String orderId;
  final String clientId;
  final String clientName;
  final String unitId;
  final int rating;
  final String comment;
  final DateTime createdAt;

  const ReviewModel({
    required this.id,
    required this.orderId,
    required this.clientId,
    required this.clientName,
    required this.unitId,
    required this.rating,
    required this.comment,
    required this.createdAt,
  });
}

class DeliveryReviewModel {
  final String id;
  final String orderId;
  final String clientId;
  final String deliveryPersonId;
  final int rating;
  final String comment;
  final DateTime createdAt;

  const DeliveryReviewModel({
    required this.id,
    required this.orderId,
    required this.clientId,
    required this.deliveryPersonId,
    required this.rating,
    required this.comment,
    required this.createdAt,
  });
}
