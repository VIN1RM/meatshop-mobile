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

  factory NotificationModel.fromApi(Map<String, Object?> data) {
    final rawDate = data['created_at'];
    return NotificationModel(
      id: '${data['id'] ?? ''}',
      userId: '',
      message: data['message'] as String? ?? '',
      title: data['title'] as String? ?? 'MeatShop',
      type: _parseType(data['type'] as String? ?? 'SYSTEM'),
      read: data['read'] == true,
      createdAt: rawDate is String
          ? DateTime.tryParse(rawDate)?.toLocal() ?? DateTime.now()
          : DateTime.now(),
      payload: {
        if (data['action_url'] != null) 'action_url': data['action_url'],
        if (data['unit_id'] != null) 'unit_id': data['unit_id'],
      },
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
