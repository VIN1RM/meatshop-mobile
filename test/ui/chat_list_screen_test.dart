import 'package:firebase_auth/firebase_auth.dart' as firebase;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meatshop_mobile/core/enums/chat_enums.dart';
import 'package:meatshop_mobile/data/repositories/chat_repository.dart';
import 'package:meatshop_mobile/data/repositories/delivery_repository.dart';
import 'package:meatshop_mobile/data/repositories/federated_auth_repository.dart';
import 'package:meatshop_mobile/data/repositories/realtime_repository.dart';
import 'package:meatshop_mobile/models/chat_model.dart';
import 'package:meatshop_mobile/providers/auth/auth_provider.dart';
import 'package:meatshop_mobile/ui/screens/account/chat/chat_list_screen.dart';
import 'package:provider/provider.dart';

class Federated extends Fake implements FederatedAuthRepository {}

class Delivery extends Fake implements DeliveryRepository {}

class Auth extends AuthProvider {
  Auth() : super(federatedAuth: Federated(), delivery: Delivery());
  @override
  int get backendUserId => 1;
  @override
  firebase.User? get currentUser => null;
}

class Repository extends Fake implements ChatRepository {
  bool fail = true;
  @override
  Future<List<ChatConversation>> conversations({
    required int currentUserId,
    required ChatParticipantType currentUserType,
    int page = 1,
    int limit = 50,
  }) async {
    if (fail) throw StateError('Offline');
    return [];
  }
}

class Realtime extends Fake implements RealtimeRepository {
  @override
  Future<void> connect() async {}
  @override
  Stream<Map<String, Object?>> get chatMessages => const Stream.empty();
  @override
  Stream<RealtimeConnectionState> get connection => const Stream.empty();
}

void main() {
  testWidgets('shows load failure separately from an empty inbox and retries', (
    tester,
  ) async {
    final repository = Repository();
    final auth = Auth();
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<AuthProvider>.value(value: auth),
          Provider.value(
            value: BackendRealtimeAccess(
              chat: repository,
              realtime: Realtime(),
            ),
          ),
        ],
        child: const MaterialApp(home: ChatListScreen()),
      ),
    );
    await tester.pumpAndSettle();
    expect(
      find.text('Não foi possível carregar as conversas.'),
      findsOneWidget,
    );
    expect(find.text('Nenhuma conversa ainda'), findsNothing);
    repository.fail = false;
    await tester.tap(find.text('Tentar novamente'));
    await tester.pumpAndSettle();
    expect(find.text('Nenhuma conversa ainda'), findsOneWidget);
    expect(find.text('Não foi possível carregar as conversas.'), findsNothing);
    await tester.pumpWidget(const SizedBox());
    auth.dispose();
  });
}
