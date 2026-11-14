import 'package:meatshop_mobile/ui/screens/account/chat/chat_screen.dart';
import 'package:firebase_auth/firebase_auth.dart' show User;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:meatshop_mobile/core/enums/chat_enums.dart';
import 'package:meatshop_mobile/core/utils/chat_args.dart';
import 'package:meatshop_mobile/data/repositories/chat_repository.dart';
import 'package:meatshop_mobile/data/repositories/delivery_repository.dart';
import 'package:meatshop_mobile/data/repositories/federated_auth_repository.dart';
import 'package:meatshop_mobile/data/repositories/realtime_repository.dart';
import 'package:meatshop_mobile/models/chat_model.dart';
import 'package:meatshop_mobile/models/order_model.dart';
import 'package:meatshop_mobile/providers/auth/auth_provider.dart';
import 'package:meatshop_mobile/ui/widgets/order_contact_actions.dart';

class _Federated extends Fake implements FederatedAuthRepository {}

class _Delivery extends Fake implements DeliveryRepository {}

class _Auth extends AuthProvider {
  _Auth() : super(federatedAuth: _Federated(), delivery: _Delivery());
  @override
  int get backendUserId => 63;
  @override
  User? get currentUser => null;
}

class _Chat extends Fake implements ChatRepository {
  bool fail = false;
  final sent = <ChatMessage>[];
  @override
  Future<List<ChatMessage>> history(
    int orderId,
    ChatChannel channel, {
    required int currentUserId,
    int page = 1,
    int limit = 100,
  }) async => sent;
  @override
  Future<void> markRead(int orderId, ChatChannel channel) async {}
  @override
  Future<ChatMessage> send(
    int orderId,
    ChatChannel channel,
    String message,
  ) async {
    final result = ChatMessage(
      id: '1',
      senderId: '63',
      text: message,
      sentAt: DateTime.now(),
      read: false,
      mine: true,
      orderId: orderId,
      channel: channel,
    );
    sent.add(result);
    return result;
  }

  final channels = <ChatChannel>[];
  @override
  Future<ChatParticipant> participant(int orderId, ChatChannel channel) async {
    expect(orderId, 42);
    channels.add(channel);
    if (fail) throw StateError('Offline');
    return ChatParticipant(
      userId: '777',
      name: 'Contato autorizado',
      type: channel == ChatChannel.unit
          ? ChatParticipantType.unit
          : ChatParticipantType.delivery,
      photoUrl: 'https://example.test/photo.png',
    );
  }
}

OrderModel order({
  bool pickup = false,
  bool courier = false,
  String status = 'READY',
}) => OrderModel.fromApi({
  'id': 42,
  'client_id': 63,
  'unit_id': 9,
  'unit_name': 'Loja',
  'status': status,
  'delivery_type': pickup ? 'PICKUP' : 'DELIVERY',
  'delivery_person_id': courier ? 21 : null,
});
Future<void> _render(
  WidgetTester tester,
  OrderModel order,
  _Chat chat, {
  void Function(ChatArgs)? onOpen,
  double scale = 1,
  bool realChat = false,
}) async {
  await tester.pumpWidget(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>(create: (_) => _Auth()),
        Provider.value(
          value: BackendRealtimeAccess(chat: chat, realtime: _Realtime()),
        ),
      ],
      child: MaterialApp(
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.linear(scale)),
          child: child!,
        ),
        home: Scaffold(
          body: SingleChildScrollView(child: OrderContactActions(order: order)),
        ),
        onGenerateRoute: (settings) {
          onOpen?.call(settings.arguments! as ChatArgs);
          return MaterialPageRoute(
            settings: settings,
            builder: (_) => realChat
                ? const ChatScreen()
                : const Scaffold(body: Text('Conversa aberta')),
          );
        },
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  for (final courier in [false, true]) {
    testWidgets('customer sends first message (courier: $courier)', (
      tester,
    ) async {
      final chat = _Chat();
      await _render(tester, order(courier: courier), chat, realChat: true);
      await tester.tap(
        find.text(courier ? 'Falar com entregador' : 'Falar com açougue'),
      );
      await tester.pumpAndSettle();
      expect(find.text('Comece a conversa'), findsOneWidget);
      await tester.enterText(
        find.byType(TextField),
        'Olá, preciso de ajuda com meu pedido',
      );
      await tester.tap(find.byIcon(Icons.send_rounded));
      await tester.pumpAndSettle();
      expect(chat.sent.single.orderId, 42);
      expect(
        chat.sent.single.channel,
        courier ? ChatChannel.deliveryPerson : ChatChannel.unit,
      );
      expect(find.text('Olá, preciso de ajuda com meu pedido'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
    });
  }

  testWidgets(
    'pickup only offers the unit and starts an order conversation without existing history',
    (tester) async {
      final chat = _Chat();
      ChatArgs? args;
      await _render(
        tester,
        order(pickup: true),
        chat,
        onOpen: (value) => args = value,
      );
      expect(find.text('Falar com entregador'), findsNothing);
      await tester.tap(find.text('Falar com açougue'));
      await tester.pumpAndSettle();
      expect(args!.orderId, 42);
      expect(args!.channel, ChatChannel.unit);
      expect(args!.currentUserType, ChatParticipantType.client);
      expect(args!.otherUserId, '777');
      expect(args!.closed, isFalse);
      expect(args!.otherUserPhoto, 'https://example.test/photo.png');
      expect(find.text('Conversa aberta'), findsOneWidget);
    },
  );
  testWidgets(
    'delivery contact uses the authorized backend user instead of the courier record id',
    (tester) async {
      final chat = _Chat();
      ChatArgs? args;
      await _render(
        tester,
        order(courier: true),
        chat,
        onOpen: (value) => args = value,
      );
      await tester.tap(find.text('Falar com entregador'));
      await tester.pumpAndSettle();
      expect(args!.otherUserId, '777');
      expect(args!.channel, ChatChannel.deliveryPerson);
      expect(args!.currentUserId, '63');
    },
  );
  testWidgets(
    'no assigned courier explains availability and keeps the unit accessible',
    (tester) async {
      await _render(tester, order(), _Chat());
      expect(find.text('Falar com açougue'), findsOneWidget);
      expect(find.text('Falar com entregador'), findsNothing);
      expect(find.textContaining('quando ele aceitar'), findsOneWidget);
    },
  );
  testWidgets('recipient lookup failure stays inline and permits retry', (
    tester,
  ) async {
    final chat = _Chat()..fail = true;
    await _render(tester, order(), chat);
    await tester.tap(find.text('Falar com açougue'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Toque no contato'), findsOneWidget);
    chat.fail = false;
    await tester.tap(find.text('Falar com açougue'));
    await tester.pumpAndSettle();
    expect(chat.channels.length, 2);
    expect(find.text('Conversa aberta'), findsOneWidget);
  });
  testWidgets('finished order opens history as read only and fits large text', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 700);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    ChatArgs? args;
    await _render(
      tester,
      order(pickup: true, status: 'DELIVERED'),
      _Chat(),
      scale: 1.6,
      onOpen: (value) => args = value,
    );
    expect(tester.takeException(), isNull);
    await tester.tap(find.text('Ver conversa com açougue'));
    await tester.pumpAndSettle();
    expect(args!.closed, isTrue);
  });
}

class _Realtime extends Fake implements RealtimeRepository {
  @override
  Stream<Map<String, Object?>> get chatMessages => const Stream.empty();
  @override
  Stream<Map<String, Object?>> get chatReads => const Stream.empty();
  @override
  Stream<Map<String, Object?>> get chatTyping => const Stream.empty();
  @override
  Stream<RealtimeConnectionState> get connection => const Stream.empty();
  @override
  Future<void> joinChat(int orderId, ChatChannel channel) async {}
  @override
  void leaveChat(int orderId, ChatChannel channel) {}
  @override
  void sendTyping(int orderId, ChatChannel channel, bool typing) {}
}
