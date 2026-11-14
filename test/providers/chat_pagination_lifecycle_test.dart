import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:meatshop_mobile/core/enums/chat_enums.dart';
import 'package:meatshop_mobile/data/repositories/chat_repository.dart';
import 'package:meatshop_mobile/data/repositories/realtime_repository.dart';
import 'package:meatshop_mobile/models/chat_model.dart';
import 'package:meatshop_mobile/providers/chat_provider.dart';

ChatMessage message(int id) => ChatMessage(
  id: '$id',
  senderId: '2',
  text: 'Message $id',
  sentAt: DateTime(2026, 1, 1).add(Duration(seconds: id)),
  read: false,
);
ChatConversation conversation(int id) => ChatConversation(
  id: '$id',
  participantIds: const ['1', '2'],
  participants: const {},
  unreadCount: const {},
  createdAt: DateTime(2026).add(Duration(seconds: id)),
);

class Repository extends Fake implements ChatRepository {
  final historyPages = <int>[];
  final inboxPages = <int>[];
  Completer<List<ChatMessage>>? pendingHistory;
  Completer<ChatMessage>? pendingSend;
  Completer<int>? pendingUnread;
  bool fail = false;
  int reads = 0;
  bool photoFails = false;
  Completer<ChatParticipant>? pendingParticipant;
  @override
  Future<ChatParticipant> participant(int orderId, ChatChannel channel) async {
    if (fail || photoFails) throw StateError('Offline');
    return pendingParticipant == null
        ? const ChatParticipant(
            userId: '2',
            name: 'Açougue atualizado',
            photoUrl: 'https://example.com/unit.png',
            type: ChatParticipantType.unit,
          )
        : pendingParticipant!.future;
  }

  @override
  Future<List<ChatMessage>> history(
    int orderId,
    ChatChannel channel, {
    required int currentUserId,
    int page = 1,
    int limit = 100,
  }) async {
    historyPages.add(page);
    if (fail) throw StateError('Offline');
    if (pendingHistory != null) return pendingHistory!.future;
    return page == 1
        ? List.generate(100, (i) => message(100 + i))
        : [message(99), message(100)];
  }

  @override
  Future<ChatMessage> send(int orderId, ChatChannel channel, String text) =>
      pendingSend!.future;
  @override
  Future<void> markRead(int orderId, ChatChannel channel) async {
    reads++;
  }

  @override
  Future<int> unreadCount() async {
    if (fail) throw StateError('Offline');
    return pendingUnread == null ? 3 : pendingUnread!.future;
  }

  @override
  Future<List<ChatConversation>> conversations({
    required int currentUserId,
    required ChatParticipantType currentUserType,
    int page = 1,
    int limit = 50,
  }) async {
    inboxPages.add(page);
    if (fail) throw StateError('Offline');
    return page == 1
        ? List.generate(50, conversation)
        : [conversation(50), conversation(49)];
  }
}

class Realtime extends Fake implements RealtimeRepository {
  final events = StreamController<Map<String, Object?>>.broadcast();
  final states = StreamController<RealtimeConnectionState>.broadcast();
  @override
  Stream<Map<String, Object?>> get chatInboxUpdates => const Stream.empty();
  @override
  Stream<Map<String, Object?>> get chatMessages => events.stream;
  @override
  Stream<Map<String, Object?>> get chatReads => const Stream.empty();
  @override
  Stream<Map<String, Object?>> get chatTyping => const Stream.empty();
  @override
  Stream<RealtimeConnectionState> get connection => states.stream;
  @override
  Future<void> connect() async {}
  @override
  Future<void> joinChat(int orderId, ChatChannel channel) async {}
  @override
  void leaveChat(int orderId, ChatChannel channel) {}
}

ChatProvider room(
  Repository repository,
  Realtime realtime, {
  bool closed = false,
}) => ChatProvider(
  closed: closed,
  repository: repository,
  realtime: realtime,
  currentUserId: '1',
  backendUserId: 1,
  currentUserName: 'Client',
  currentUserType: ChatParticipantType.client,
  conversationId: '10:UNIT',
  receiverId: '2',
  receiverName: 'Unit',
  receiverType: ChatParticipantType.unit,
  orderId: 10,
  channel: ChatChannel.unit,
);

void main() {
  testWidgets('a profile image failure does not block the message history', (
    tester,
  ) async {
    final repository = Repository()..photoFails = true;
    final provider = room(repository, Realtime());
    await tester.pump();
    expect(provider.participant, isNull);
    expect(provider.messages, isNotEmpty);
    expect(provider.error, isNull);
    provider.dispose();
  });

  testWidgets(
    'loads the current participant photo even when navigation passed none',
    (tester) async {
      final repository = Repository();
      final provider = room(repository, Realtime());
      await tester.pump();
      expect(provider.participant?.photoUrl, 'https://example.com/unit.png');
      expect(provider.participant?.name, 'Açougue atualizado');
      expect(provider.messages, isNotEmpty);
      provider.dispose();
    },
  );
  testWidgets(
    'does not publish a profile response after leaving the conversation',
    (tester) async {
      final repository = Repository()..pendingParticipant = Completer();
      final provider = room(repository, Realtime());
      await tester.pump();
      provider.dispose();
      repository.pendingParticipant!.complete(
        const ChatParticipant(
          userId: '2',
          name: 'Contato',
          type: ChatParticipantType.unit,
        ),
      );
      await tester.pump();
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'background chats remain unread and closed history is read after returning',
    (tester) async {
      final repository = Repository();
      final provider = room(repository, Realtime(), closed: true);
      provider.setVisible(false);
      await tester.pump();
      expect(repository.reads, 0);
      provider.setVisible(true);
      await tester.pump();
      expect(repository.reads, 1);
      provider.dispose();
    },
  );

  testWidgets(
    'loads older history once, deduplicates and keeps chronological order',
    (tester) async {
      final repository = Repository();
      final realtime = Realtime();
      final provider = room(repository, realtime);
      addTearDown(provider.dispose);
      await tester.pump();
      expect(provider.hasOlder, isTrue);
      final first = provider.loadOlder();
      final duplicate = provider.loadOlder();
      await Future.wait([first, duplicate]);
      expect(repository.historyPages, [1, 2]);
      expect(provider.messages.length, 101);
      expect(provider.messages.first.id, '99');
      expect(provider.messages.last.id, '199');
      expect(provider.hasOlder, isFalse);
      realtime.states.add(RealtimeConnectionState.connected);
      await tester.pump();
      expect(repository.historyPages, [1, 2, 1, 2]);
      expect(provider.messages.length, 101);
    },
  );

  testWidgets(
    'retains history after pagination failure and retries the same page',
    (tester) async {
      final repository = Repository();
      final provider = room(repository, Realtime());
      addTearDown(provider.dispose);
      await tester.pump();
      repository.fail = true;
      await provider.loadOlder();
      expect(provider.messages.length, 100);
      expect(provider.error, isNotNull);
      expect(provider.hasOlder, isTrue);
      repository.fail = false;
      await provider.loadOlder();
      expect(repository.historyPages, [1, 2, 2]);
      expect(provider.error, isNull);
      expect(provider.messages.length, 101);
    },
  );

  for (final fails in [false, true]) {
    testWidgets(
      'ignores history ${fails ? 'failure' : 'success'} after disposal',
      (tester) async {
        final repository = Repository()..pendingHistory = Completer();
        final provider = room(repository, Realtime());
        await tester.pump();
        provider.dispose();
        if (fails) {
          repository.pendingHistory!.completeError(StateError('Offline'));
        } else {
          repository.pendingHistory!.complete([message(1)]);
        }
        await tester.pump();
        expect(repository.reads, 0);
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets('ignores send and unread responses after disposal', (
    tester,
  ) async {
    final repository = Repository()
      ..pendingSend = Completer()
      ..pendingUnread = Completer();
    final realtime = Realtime();
    final provider = room(repository, realtime);
    final unread = ChatUnreadProvider(
      repository: repository,
      realtime: realtime,
      currentUserId: '1',
    );
    await tester.pump();
    final sending = provider.sendMessage('Hello');
    provider.dispose();
    unread.dispose();
    repository.pendingSend!.complete(message(200));
    repository.pendingUnread!.complete(5);
    await sending;
    await tester.pump();
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'paginates inbox and preserves loaded pages across refresh and failure',
    (tester) async {
      final repository = Repository();
      final provider = ChatListProvider(
        repository: repository,
        realtime: Realtime(),
        currentUserId: '1',
        backendUserId: 1,
        activeType: ChatParticipantType.client,
      );
      await tester.pump();
      expect(provider.hasMore, isTrue);
      await provider.loadMore();
      expect(provider.conversations.length, 51);
      expect(provider.hasMore, isFalse);
      repository.fail = true;
      await provider.refresh();
      expect(provider.conversations.length, 51);
      expect(provider.error, isNotNull);
      repository.fail = false;
      await provider.refresh();
      expect(repository.inboxPages, [1, 2, 1, 1, 2]);
      expect(provider.conversations.length, 51);
      expect(provider.error, isNull);
      provider.dispose();
    },
  );

  testWidgets(
    'retries the failed inbox page without discarding earlier conversations',
    (tester) async {
      final repository = Repository();
      final provider = ChatListProvider(
        repository: repository,
        realtime: Realtime(),
        currentUserId: '1',
        backendUserId: 1,
        activeType: ChatParticipantType.client,
      );
      await tester.pump();
      repository.fail = true;
      await provider.loadMore();
      expect(provider.conversations.length, 50);
      expect(provider.error, isNotNull);
      repository.fail = false;
      await provider.retry();
      expect(repository.inboxPages, [1, 2, 2]);
      expect(provider.conversations.length, 51);
      expect(provider.error, isNull);
      provider.dispose();
    },
  );

  testWidgets('unread network failures do not escape background callbacks', (
    tester,
  ) async {
    final repository = Repository()..fail = true;
    final realtime = Realtime();
    final provider = ChatUnreadProvider(
      repository: repository,
      realtime: realtime,
      currentUserId: '1',
    );

    await tester.pump();
    expect(tester.takeException(), isNull);
    repository.fail = false;
    realtime.events.add({});
    await tester.pump();
    expect(provider.total, 3);
    provider.dispose();
  });
}
