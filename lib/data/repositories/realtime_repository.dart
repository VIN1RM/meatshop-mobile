import '../../core/enums/chat_enums.dart';
import 'chat_repository.dart';

enum RealtimeConnectionState { disconnected, connecting, connected }

abstract interface class RealtimeRepository {
  Stream<Map<String, Object?>> get chatMessages;
  Stream<Map<String, Object?>> get chatReads;
  Stream<Map<String, Object?>> get chatTyping;
  Stream<Map<String, Object?>> get deliveryLocations;
  Stream<Map<String, Object?>> get statuses;
  Stream<RealtimeConnectionState> get connection;
  Future<void> connect();
  Future<void> joinChat(int orderId, ChatChannel channel);
  void leaveChat(int orderId, ChatChannel channel);
  void sendTyping(int orderId, ChatChannel channel, bool typing);
  Future<void> subscribeDelivery(int orderId);
  void unsubscribeDelivery(int orderId);
}

final class BackendRealtimeAccess {
  const BackendRealtimeAccess({this.chat, this.realtime});
  final ChatRepository? chat;
  final RealtimeRepository? realtime;
  bool get enabled => chat != null && realtime != null;
}
