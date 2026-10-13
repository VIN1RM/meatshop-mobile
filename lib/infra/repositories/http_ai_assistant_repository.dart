import '../../core/network/api_failure.dart';
import '../../core/network/cancellation_token.dart';
import '../../data/repositories/ai_assistant_repository.dart';
import '../auth/secure_key_value_store.dart';
import '../http/api_client.dart';

final class HttpAiAssistantRepository implements AiAssistantRepository {
  HttpAiAssistantRepository(this._client, this._storage);

  static const _conversationIdKey = 'meatshop.ai.conversation_id.v1';
  final ApiClient _client;
  final SecureKeyValueStore _storage;

  @override
  Future<List<AiConversationMessage>> loadHistory() async {
    final conversationId = await _storage.read(_conversationIdKey);
    if (conversationId == null) return const [];
    try {
      return await _client.get(
        '/ai/conversations/$conversationId',
        decode: (json) {
          if (json is! Map) throw _malformed();
          final data = json.map(
            (key, value) => MapEntry(key.toString(), value),
          );
          final messages = data['messages'];
          if (messages is! List) throw _malformed();
          return messages
              .map((value) {
                if (value is! Map) throw _malformed();
                final message = value.map(
                  (key, item) => MapEntry(key.toString(), item),
                );
                final role = message['role'];
                final content = message['content'];
                if ((role != 'user' && role != 'assistant') ||
                    content is! String ||
                    content.trim().isEmpty) {
                  throw _malformed();
                }
                return AiConversationMessage(
                  text: content,
                  isUser: role == 'user',
                );
              })
              .toList(growable: false);
        },
      );
    } on ApiFailure catch (failure) {
      if (failure.kind != ApiFailureKind.notFound) rethrow;
      await _storage.delete(_conversationIdKey);
      return const [];
    }
  }

  @override
  Future<AiChatReply> send(
    String message, {
    CancellationToken? cancellationToken,
  }) async {
    final conversationId = await _storage.read(_conversationIdKey);
    final body = <String, Object>{'message': message};
    if (conversationId != null) {
      body['conversation_id'] = conversationId;
    }
    late String returnedConversationId;
    final reply = await _client.post(
      '/ai/chat',
      body: body,
      timeout: const Duration(seconds: 55),
      cancellationToken: cancellationToken,
      decode: (json) {
        if (json is! Map) throw _malformed();
        final data = json.map((key, value) => MapEntry(key.toString(), value));
        final response = data['response'];
        final responseConversationId = data['conversation_id'];
        if (response is! String ||
            response.trim().isEmpty ||
            responseConversationId is! String ||
            responseConversationId.isEmpty) {
          throw _malformed();
        }
        returnedConversationId = responseConversationId;
        return AiChatReply(
          text: response,
          requestId: data['request_id']?.toString(),
        );
      },
    );
    await _storage.write(_conversationIdKey, returnedConversationId);
    return reply;
  }

  @override
  Future<void> clearHistory() async {
    final conversationId = await _storage.read(_conversationIdKey);
    if (conversationId == null) return;
    await _client.delete('/ai/conversations/$conversationId', decode: (_) {});
    await _storage.delete(_conversationIdKey);
  }

  static ApiFailure _malformed() => const ApiFailure(
    kind: ApiFailureKind.malformedResponse,
    message: 'O assistente retornou uma resposta inválida.',
    code: 'AI_INVALID_RESPONSE',
  );
}
