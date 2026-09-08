class DeliveryReview {
  const DeliveryReview({
    required this.id,
    required this.orderId,
    required this.clientId,
    required this.deliveryPersonId,
    required this.rating,
    required this.comment,
    required this.createdAt,
  });

  final String id;
  final String orderId;
  final String clientId;
  final String deliveryPersonId;
  final int rating;
  final String comment;
  final DateTime createdAt;
}
