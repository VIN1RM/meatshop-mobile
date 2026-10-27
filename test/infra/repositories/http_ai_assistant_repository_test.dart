import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:meatshop_mobile/core/auth/session_coordinator.dart';
import 'package:meatshop_mobile/core/auth/session_refresher.dart';
import 'package:meatshop_mobile/core/auth/session_store.dart';
import 'package:meatshop_mobile/core/auth/session_tokens.dart';
import 'package:meatshop_mobile/core/config/api_config.dart';
import 'package:meatshop_mobile/core/network/api_failure.dart';
import 'package:meatshop_mobile/infra/http/api_client.dart';
import 'package:meatshop_mobile/infra/http/json_http_transport.dart';
import 'package:meatshop_mobile/infra/auth/secure_key_value_store.dart';
import 'package:meatshop_mobile/infra/repositories/http_ai_assistant_repository.dart';

void main() {
  test('renders SSE deltas and stores the completed conversation', () async {
    final storage = _MemoryKeyValueStore();
    final repository = _repository(
      MockClient((request) async {
        expect(request.url.path, '/ai/chat/stream');
        expect(request.headers['x-client-platform'], 'mobile');
        return http.Response(
          'data: {"delta":"Use "}\r\n\r\ndata: {"delta":"sal."}\n\ndata: {"done":true,"conversation_id":"stream-id"}\n\n',
          200,
          headers: {'content-type': 'text/event-stream'},
        );
      }),
      storage,
    );
    final deltas = <String>[];
    final reply = await repository.sendStreaming(
      'picanha',
      onDelta: deltas.add,
    );
    expect(deltas, ['Use ', 'Use sal.']);
    expect(reply.text, 'Use sal.');
    expect(await storage.read('meatshop.ai.conversation_id.v1'), 'stream-id');
  });

  test('falls back only before the first delta', () async {
    var calls = 0;
    final repository = _repository(
      MockClient((request) async {
        calls++;
        if (request.url.path.endsWith('/stream')) {
          return http.Response('data: {"error":"unavailable"}\n\n', 200);
        }
        return http.Response(
          '{"response":"Fallback","conversation_id":"fallback-id"}',
          200,
        );
      }),
      _MemoryKeyValueStore(),
    );
    expect(
      (await repository.sendStreaming('picanha', onDelta: (_) {})).text,
      'Fallback',
    );
    expect(calls, 2);
    calls = 0;
    final partial = _repository(
      MockClient((request) async {
        calls++;
        return http.Response(
          'data: {"delta":"Partial"}\n\ndata: {"error":"unavailable"}\n\n',
          200,
        );
      }),
      _MemoryKeyValueStore(),
    );
    await expectLater(
      partial.sendStreaming('picanha', onDelta: (_) {}),
      throwsA(isA<ApiFailure>()),
    );
    expect(calls, 1);
  });

  test('sends the prompt through the authenticated MeatShop backend', () async {
    final storage = _MemoryKeyValueStore();
    final repository = _repository(
      MockClient((request) async {
        expect(request.url.path, '/ai/chat');
        expect(request.headers['authorization'], 'Bearer access-token');
        expect(request.body, contains('picanha'));
        return http.Response(
          '{"response":"Resposta segura","request_id":"req-1","conversation_id":"11111111-1111-4111-8111-111111111111","expires_at":"2026-10-16T12:00:00.000Z"}',
          201,
          headers: {'content-type': 'application/json'},
        );
      }),
      storage,
    );

    final reply = await repository.send('Como preparar picanha?');

    expect(reply.text, 'Resposta segura');
    expect(reply.requestId, 'req-1');
    expect(
      await storage.read('meatshop.ai.conversation_id.v1'),
      '11111111-1111-4111-8111-111111111111',
    );
  });

  test('rejects malformed successful responses', () async {
    final repository = _repository(
      MockClient(
        (_) async => http.Response(
          '{"unexpected":true}',
          200,
          headers: {'content-type': 'application/json'},
        ),
      ),
      _MemoryKeyValueStore(),
    );

    await expectLater(
      repository.send('picanha'),
      throwsA(
        isA<ApiFailure>().having(
          (failure) => failure.code,
          'code',
          'AI_INVALID_RESPONSE',
        ),
      ),
    );
  });

  test('restores and deletes the server-side conversation', () async {
    final storage = _MemoryKeyValueStore()
      ..values['meatshop.ai.conversation_id.v1'] =
          '11111111-1111-4111-8111-111111111111';
    var deleted = false;
    final repository = _repository(
      MockClient((request) async {
        expect(request.headers['authorization'], 'Bearer access-token');
        if (request.method == 'GET') {
          return http.Response(
            '{"conversation_id":"11111111-1111-4111-8111-111111111111","expires_at":"2026-10-16T12:00:00.000Z","messages":[{"role":"user","content":"Oi","created_at":"2026-10-09T12:00:00.000Z"},{"role":"assistant","content":"Olá","created_at":"2026-10-09T12:00:01.000Z"}]}',
            200,
            headers: {'content-type': 'application/json'},
          );
        }
        expect(request.method, 'DELETE');
        deleted = true;
        return http.Response('', 204);
      }),
      storage,
    );

    final history = await repository.loadHistory();
    expect(history.map((message) => message.text), ['Oi', 'Olá']);
    expect(history.map((message) => message.isUser), [true, false]);

    await repository.clearHistory();
    expect(deleted, isTrue);
    expect(await storage.read('meatshop.ai.conversation_id.v1'), isNull);
  });
}

HttpAiAssistantRepository _repository(
  http.Client httpClient,
  SecureKeyValueStore storage,
) {
  final transport = JsonHttpTransport(
    config: ApiConfig(
      baseUrl: Uri.parse('http://localhost:3001'),
      environment: AppEnvironment.development,
    ),
    client: httpClient,
  );
  final session = SessionCoordinator(
    store: _MemorySessionStore(),
    refresher: _FailingRefresher(),
  );
  return HttpAiAssistantRepository(
    ApiClient(transport: transport, session: session),
    storage,
  );
}

final class _MemoryKeyValueStore implements SecureKeyValueStore {
  final Map<String, String> values = {};

  @override
  Future<void> delete(String key) async => values.remove(key);

  @override
  Future<String?> read(String key) async => values[key];

  @override
  Future<void> write(String key, String value) async => values[key] = value;
}

final class _MemorySessionStore implements SessionStore {
  SessionTokens? tokens = const SessionTokens(
    accessToken: 'access-token',
    refreshToken: 'refresh-token',
  );

  @override
  Future<void> clear() async => tokens = null;
  @override
  Future<SessionTokens?> read() async => tokens;
  @override
  Future<void> write(SessionTokens value) async => tokens = value;
}

final class _FailingRefresher implements SessionRefresher {
  @override
  Future<SessionTokens> refresh(String refreshToken) =>
      throw StateError('unused');
}
