import 'package:cloud_firestore/cloud_firestore.dart';

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

  Map<String, dynamic> toFirestore() => {
    'order_id': orderId,
    'client_id': clientId,
    'client_name': clientName,
    'unit_id': unitId,
    'rating': rating,
    'comment': comment,
    'created_at': FieldValue.serverTimestamp(),
  };

  factory ReviewModel.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return ReviewModel(
      id: doc.id,
      orderId: d['order_id'] as String? ?? '',
      clientId: d['client_id'] as String? ?? '',
      clientName: d['client_name'] as String? ?? 'Cliente',
      unitId: d['unit_id'] as String? ?? '',
      rating: (d['rating'] as num?)?.toInt() ?? 0,
      comment: d['comment'] as String? ?? '',
      createdAt: (d['created_at'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
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
