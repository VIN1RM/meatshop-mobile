import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:meatshop_mobile/core/enums/chat_enums.dart';
import 'package:meatshop_mobile/data/repositories/chat_repository.dart';
import 'package:meatshop_mobile/data/repositories/realtime_repository.dart';
import 'package:meatshop_mobile/models/chat_model.dart';
import 'package:meatshop_mobile/providers/chat_provider.dart';

class InboxRepository extends Fake implements ChatRepository {
  int calls = 0;
  Completer<List<ChatConversation>>? pending;
  @override
  Future<List<ChatConversation>> conversations({
    required int currentUserId,
    required ChatParticipantType currentUserType,
    int page = 1,
    int limit = 50,
  }) async {
    calls++;
    expect(currentUserId, 13);
    expect(currentUserType, ChatParticipantType.delivery);
    return pending == null ? [] : pending!.future;
  }
}

class InboxRealtime extends Fake implements RealtimeRepository {
  @override
  Future<void> connect() async {}
  @override
  Stream<Map<String, Object?>> get chatMessages => const Stream.empty();
  @override
  Stream<RealtimeConnectionState> get connection => const Stream.empty();
}

void main() {
  testWidgets(
    'refreshes conversations outside the room and stops after leaving the screen',
    (tester) async {
      final repository = InboxRepository();
      final provider = ChatListProvider(
        repository: repository,
        realtime: InboxRealtime(),
        currentUserId: '13',
        backendUserId: 13,
        activeType: ChatParticipantType.delivery,
      );
      await tester.pump();
      expect(repository.calls, 1);
      await tester.pump(const Duration(seconds: 10));
      expect(repository.calls, 2);
      repository.pending = Completer();
      await tester.pump(const Duration(seconds: 10));
      provider.dispose();
      repository.pending!.complete([]);
      await tester.pump(const Duration(seconds: 20));
      expect(repository.calls, 3);
      expect(tester.takeException(), isNull);
    },
  );
}
