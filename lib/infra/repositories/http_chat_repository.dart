import '../../core/enums/chat_enums.dart';
import '../../core/network/api_failure.dart';
import '../../data/repositories/chat_repository.dart';
import '../../models/chat_model.dart';
import '../http/api_client.dart';

final class HttpChatRepository implements ChatRepository {
  HttpChatRepository(this._client);
  final ApiClient _client;

  @override
  Future<List<ChatConversation>> conversations({
    required int currentUserId,
    required ChatParticipantType currentUserType,
    int page = 1,
    int limit = 50,
  }) => _client.get(
    '/chats',
    query: {'page': page, 'limit': limit},
    decode: (value) {
      final items = _map(value)['items'];
      if (items is! List<Object?>) throw _malformed();
      return items
          .map(
            (item) => ChatConversation.fromApi(
              _map(item),
              currentUserId: currentUserId,
              currentUserType: currentUserType,
            ),
          )
          .toList(growable: false);
    },
  );

  @override
  Future<int> unreadCount() => _client.get(
    '/chats/unread-count',
    decode: (value) {
      final count = _map(value)['count'];
      if (count is! num) throw _malformed();
      return count.toInt();
    },
  );

  @override
  Future<List<ChatMessage>> history(
    int orderId,
    ChatChannel channel, {
    required int currentUserId,
  }) => _client.get(
    '/orders/$orderId/chat',
    query: {'participant_type': channel.apiValue, 'page': 1, 'limit': 100},
    decode: (value) {
      if (value is! List<Object?>) throw _malformed();
      return value
          .map(
            (item) =>
                ChatMessage.fromApi(_map(item), currentUserId: currentUserId),
          )
          .toList(growable: false);
    },
  );

  @override
  Future<ChatMessage> send(int orderId, ChatChannel channel, String message) =>
      _client.post(
        '/orders/$orderId/chat',
        body: {'participant_type': channel.apiValue, 'message': message},
        decode: (value) => ChatMessage.fromApi(_map(value), isMine: true),
      );

  @override
  Future<void> markRead(int orderId, ChatChannel channel) => _client.patch(
    '/orders/$orderId/chat/read',
    query: {'participant_type': channel.apiValue},
    decode: (_) {},
  );

  static Map<String, Object?> _map(Object? value) =>
      value is Map<String, Object?> ? value : throw _malformed();

  static ApiFailure _malformed() => const ApiFailure(
    kind: ApiFailureKind.malformedResponse,
    message: 'O servidor retornou dados de chat inválidos.',
    code: 'MALFORMED_CHAT_RESPONSE',
  );
}
