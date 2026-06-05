import 'package:cloud_firestore/cloud_firestore.dart';

enum NotificationType { order, delivery, promotion, system }

class NotificationModel {
  final String id;
  final String userId;
  final String message;
  final String title;
  final NotificationType type;
  final bool read;
  final DateTime createdAt;
  final Map<String, dynamic>? payload;

  const NotificationModel({
    required this.id,
    required this.userId,
    required this.message,
    required this.title,
    required this.type,
    required this.read,
    required this.createdAt,
    this.payload,
  });

  factory NotificationModel.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return NotificationModel(
      id: doc.id,
      userId: data['user_id'] as String? ?? '',
      message: data['message'] as String? ?? '',
      title: data['title'] as String? ?? 'MeatShop',
      type: _parseType(data['type'] as String? ?? 'SYSTEM'),
      read: data['read'] as bool? ?? false,
      createdAt: (data['created_at'] as Timestamp?)?.toDate() ?? DateTime.now(),
      payload: data['payload'] as Map<String, dynamic>?,
    );
  }

  static NotificationType _parseType(String value) {
    return switch (value.toUpperCase()) {
      'ORDER' => NotificationType.order,
      'DELIVERY' => NotificationType.delivery,
      'PROMOTION' => NotificationType.promotion,
      _ => NotificationType.system,
    };
  }
}
