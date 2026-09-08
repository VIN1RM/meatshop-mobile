import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:meatshop_mobile/core/auth/session_coordinator.dart';
import 'package:meatshop_mobile/core/auth/session_refresher.dart';
import 'package:meatshop_mobile/core/auth/session_store.dart';
import 'package:meatshop_mobile/core/auth/session_tokens.dart';
import 'package:meatshop_mobile/core/config/api_config.dart';
import 'package:meatshop_mobile/core/enums/chat_enums.dart';
import 'package:meatshop_mobile/infra/http/api_client.dart';
import 'package:meatshop_mobile/infra/http/json_http_transport.dart';
import 'package:meatshop_mobile/infra/repositories/http_chat_repository.dart';

void main() {
  test('lista conversas e preserva pedido, canal e não lidas', () async {
    final repository = HttpChatRepository(
      _client(
        MockClient((request) async {
          expect(request.url.path, '/chats');
          expect(request.url.queryParameters, {'page': '1', 'limit': '50'});
          expect(request.headers['authorization'], 'Bearer access');
          return _json({
            'items': [
              {
                'id': '42:DELIVERY_PERSON',
                'order_id': 42,
                'participant_type': 'DELIVERY_PERSON',
                'participant': {'id': 9, 'name': 'João', 'avatar_url': null},
                'last_message': 'Estou chegando',
                'last_message_at': '2026-09-03T12:00:00.000Z',
                'unread_count': 2,
                'closed': false,
              },
            ],
            'page': 1,
            'limit': 50,
            'total': 1,
          });
        }),
      ),
    );

    final conversations = await repository.conversations(
      currentUserId: 7,
      currentUserType: ChatParticipantType.client,
    );

    expect(conversations.single.orderId, 42);
    expect(conversations.single.channel, ChatChannel.deliveryPerson);
    expect(conversations.single.unreadFor('7'), 2);
    expect(
      conversations.single.otherParticipant('7')?.type,
      ChatParticipantType.delivery,
    );
  });

  test(
    'carrega histórico, envia e marca leitura no canal autorizado',
    () async {
      var call = 0;
      final repository = HttpChatRepository(
        _client(
          MockClient((request) async {
            call++;
            expect(
              request.url.path,
              call == 3 ? '/orders/42/chat/read' : '/orders/42/chat',
            );
            if (call == 1) {
              expect(request.method, 'GET');
              expect(
                request.url.queryParameters['participant_type'],
                'DELIVERY_PERSON',
              );
            } else if (call == 2) {
              expect(request.method, 'POST');
              expect(jsonDecode(request.body), {
                'participant_type': 'DELIVERY_PERSON',
                'message': 'Olá',
              });
            } else {
              expect(request.method, 'PATCH');
              expect(
                request.url.queryParameters['participant_type'],
                'DELIVERY_PERSON',
              );
              return _json({});
            }
            return _json(call == 1 ? [_message] : _message);
          }),
        ),
      );

      final history = await repository.history(
        42,
        ChatChannel.deliveryPerson,
        currentUserId: 7,
      );
      final sent = await repository.send(42, ChatChannel.deliveryPerson, 'Olá');
      await repository.markRead(42, ChatChannel.deliveryPerson);

      expect(history.single.mine, isTrue);
      expect(sent.mine, isTrue);
      expect(call, 3);
    },
  );
}

const _message = <String, Object?>{
  'id': 1,
  'order_id': 42,
  'sender_id': 7,
  'receiver_id': 9,
  'sender_name': 'Cliente',
  'receiver_name': 'Entregador',
  'participant_type': 'DELIVERY_PERSON',
  'message': 'Olá',
  'sent_at': '2026-09-03T12:00:00.000Z',
  'read_at': null,
};

final _config = ApiConfig(
  baseUrl: Uri.parse('http://localhost:3001'),
  environment: AppEnvironment.development,
);
ApiClient _client(http.Client client) => ApiClient(
  transport: JsonHttpTransport(config: _config, client: client),
  session: SessionCoordinator(store: _Store(), refresher: _Refresh()),
);
http.Response _json(Object value) => http.Response(
  jsonEncode(value),
  200,
  headers: {'content-type': 'application/json'},
);

final class _Store implements SessionStore {
  @override
  Future<void> clear() async {}
  @override
  Future<SessionTokens?> read() async =>
      const SessionTokens(accessToken: 'access', refreshToken: 'refresh');
  @override
  Future<void> write(SessionTokens tokens) async {}
}

final class _Refresh implements SessionRefresher {
  @override
  Future<SessionTokens> refresh(String refreshToken) =>
      throw StateError('not expected');
}
