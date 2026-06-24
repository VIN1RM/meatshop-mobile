import 'package:cloud_firestore/cloud_firestore.dart';

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

  Map<String, dynamic> toFirestore() => {
    'order_id': orderId,
    'client_id': clientId,
    'unit_id': unitId,
    'product_id': productId,
    'rating': rating,
    'comment': comment.trim(),
    'created_at': FieldValue.serverTimestamp(),
  };

  factory ProductReviewModel.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>? ?? {};
    return ProductReviewModel(
      id: doc.id,
      orderId: d['order_id'] as String? ?? '',
      clientId: d['client_id'] as String? ?? '',
      productId: d['product_id'] as String? ?? '',
      productName: d['product_name'] as String? ?? '',
      productImageUrl: d['product_image_url'] as String? ?? '',
      unitId: d['unit_id'] as String? ?? '',
      rating: d['rating'] as int? ?? 0,
      comment: d['comment'] as String? ?? '',
      createdAt: (d['created_at'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}