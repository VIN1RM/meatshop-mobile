import '../../core/enums/chat_enums.dart';
import '../../models/chat_model.dart';

abstract interface class ChatRepository {
  Future<List<ChatConversation>> conversations({
    required int currentUserId,
    required ChatParticipantType currentUserType,
    int page = 1,
    int limit = 50,
  });
  Future<int> unreadCount();
  Future<List<ChatMessage>> history(
    int orderId,
    ChatChannel channel, {
    required int currentUserId,
  });
  Future<ChatMessage> send(int orderId, ChatChannel channel, String message);
  Future<void> markRead(int orderId, ChatChannel channel);
}
