class SupportMessageModel {
  const SupportMessageModel({required this.text, required this.createdAt});
  factory SupportMessageModel.fromJson(Map<String, dynamic> json) =>
      SupportMessageModel(
        text: json['message'] as String? ?? '',
        createdAt: DateTime.parse(json['created_at'] as String),
      );
  final String text;
  final DateTime createdAt;
}

class SupportTicketModel {
  const SupportTicketModel({
    required this.id,
    required this.subject,
    required this.status,
    this.messages = const [],
  });
  factory SupportTicketModel.fromJson(Map<String, dynamic> json) =>
      SupportTicketModel(
        id: (json['id'] as num).toInt(),
        subject: json['subject'] as String,
        status: json['status'] as String,
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
  final List<SupportMessageModel> messages;
}
