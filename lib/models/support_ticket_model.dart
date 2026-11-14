class SupportMessageModel {
  const SupportMessageModel({
    this.id,
    required this.text,
    required this.createdAt,
    this.senderId,
    this.senderName,
  });
  factory SupportMessageModel.fromJson(Map<String, dynamic> json) =>
      SupportMessageModel(
        id: (json['id'] as num?)?.toInt(),
        text: json['message'] as String? ?? '',
        senderId: (json['sender_id'] as num?)?.toInt(),
        senderName: (json['sender'] as Map?)?['name'] as String?,
        createdAt: DateTime.parse(json['created_at'] as String),
      );
  final int? id;
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
    this.messagesHasMore = false,
    this.messagesNextBeforeId,
  });
  factory SupportTicketModel.fromJson(Map<String, dynamic> json) =>
      SupportTicketModel(
        id: (json['id'] as num).toInt(),
        subject: json['subject'] as String,
        status: json['status'] as String,
        contact: json['contact'] as String?,
        userId: (json['user_id'] as num?)?.toInt(),
        messagesHasMore: json['messages_has_more'] == true,
        messagesNextBeforeId: (json['messages_next_before_id'] as num?)
            ?.toInt(),
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
  final bool messagesHasMore;
  final int? messagesNextBeforeId;
}

class SupportMessagesPage {
  const SupportMessagesPage(
    this.items, {
    required this.hasMore,
    this.nextBeforeId,
  });
  final List<SupportMessageModel> items;
  final bool hasMore;
  final int? nextBeforeId;
}
