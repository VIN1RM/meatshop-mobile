class SupportMessageModel {
  const SupportMessageModel({
    required this.text,
    required this.createdAt,
    this.senderId,
    this.senderName,
  });
  factory SupportMessageModel.fromJson(Map<String, dynamic> json) =>
      SupportMessageModel(
        text: json['message'] as String? ?? '',
        senderId: (json['sender_id'] as num?)?.toInt(),
        senderName: (json['sender'] as Map?)?['name'] as String?,
        createdAt: DateTime.parse(json['created_at'] as String),
      );
  final String text;
  final int? senderId;
  final String? senderName;
  final DateTime createdAt;
}

class SupportTicketModel {
  const SupportTicketModel({
    required this.id,
    required this.subject,
    required this.status,
    this.contact,
    this.userId,
    this.messages = const [],
  });
  factory SupportTicketModel.fromJson(Map<String, dynamic> json) =>
      SupportTicketModel(
        id: (json['id'] as num).toInt(),
        subject: json['subject'] as String,
        status: json['status'] as String,
        contact: json['contact'] as String?,
        userId: (json['user_id'] as num?)?.toInt(),
        messages: (json['messages'] as List? ?? [])
            .map(
              (item) => SupportMessageModel.fromJson(
                Map<String, dynamic>.from(item as Map),
              ),
            )
            .toList(),
      );
  final int id;
  final String subject;
  final String status;
  final String? contact;
  final int? userId;
  final List<SupportMessageModel> messages;
}
