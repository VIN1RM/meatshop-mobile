import '../../core/network/cancellation_token.dart';

final class AiChatReply {
  const AiChatReply({required this.text, this.requestId});

  final String text;
  final String? requestId;
}

final class AiConversationMessage {
  const AiConversationMessage({required this.text, required this.isUser});

  final String text;
  final bool isUser;
}

abstract interface class AiAssistantRepository {
  Future<List<AiConversationMessage>> loadHistory();

  Future<AiChatReply> send(
    String message, {
    CancellationToken? cancellationToken,
  });

  Future<void> clearHistory();
}
