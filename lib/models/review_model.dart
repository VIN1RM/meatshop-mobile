import 'package:cloud_firestore/cloud_firestore.dart';

class ReviewModel {
  final String id;
  final String orderId;
  final String clientId;
  final String unitId;
  final int rating;
  final String comment;
  final DateTime createdAt;

  const ReviewModel({
    required this.id,
    required this.orderId,
    required this.clientId,
    required this.unitId,
    required this.rating,
    required this.comment,
    required this.createdAt,
  });

  Map<String, dynamic> toFirestore() => {
    'order_id': orderId,
    'client_id': clientId,
    'unit_id': unitId,
    'rating': rating,
    'comment': comment,
    'created_at': FieldValue.serverTimestamp(),
  };
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

  Map<String, dynamic> toFirestore() => {
    'order_id': orderId,
    'client_id': clientId,
    'delivery_person_id': deliveryPersonId,
    'rating': rating,
    'comment': comment,
    'created_at': FieldValue.serverTimestamp(),
  };
}
