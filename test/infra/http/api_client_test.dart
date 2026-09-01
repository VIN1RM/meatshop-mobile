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

void main() {
  group('ApiClient', () {
    test('não exige sessão em endpoint público', () async {
      final fixture = _fixture(
        MockClient((_) async => http.Response('{"ok":true}', 200)),
      );

      final result = await fixture.client.get<bool>(
        '/health',
        authenticated: false,
        decode: (json) => (json! as Map<String, Object?>)['ok']! as bool,
      );

      expect(result, isTrue);
    });

    test('envia Bearer token em endpoint protegido', () async {
      final fixture = _fixture(
        MockClient((request) async {
          expect(request.headers['authorization'], 'Bearer access-token');
          return http.Response('{"ok":true}', 200);
        }),
        tokens: const SessionTokens(
          accessToken: 'access-token',
          refreshToken: 'refresh-token',
        ),
      );

      await fixture.client.get<void>('/users/me', decode: (_) {});
    });

    test('uma única renovação atende requisições 401 concorrentes', () async {
      final refresher = _DelayedRefresher();
      final fixture = _fixture(
        MockClient((request) async {
          final authorization = request.headers['authorization'];
          if (authorization == 'Bearer old-access') {
            return http.Response('{"message":"Unauthorized"}', 401);
          }
          expect(authorization, 'Bearer new-access');
          return http.Response('{"ok":true}', 200);
        }),
        tokens: const SessionTokens(
          accessToken: 'old-access',
          refreshToken: 'old-refresh',
        ),
        refresher: refresher,
      );

      final results = await Future.wait([
        fixture.client.get<bool>(
          '/users/me',
          decode: (json) => (json! as Map<String, Object?>)['ok']! as bool,
        ),
        fixture.client.get<bool>(
          '/users/me',
          decode: (json) => (json! as Map<String, Object?>)['ok']! as bool,
        ),
      ]);

      expect(results, [isTrue, isTrue]);
      expect(refresher.calls, 1);
    });

    test('falha protegida sem sessão não chega à rede', () async {
      var networkCalls = 0;
      final fixture = _fixture(
        MockClient((_) async {
          networkCalls++;
          return http.Response('{}', 200);
        }),
      );

      await expectLater(
        fixture.client.get<void>('/users/me', decode: (_) {}),
        throwsA(
          isA<ApiFailure>().having(
            (failure) => failure.code,
            'code',
            'SESSION_REQUIRED',
          ),
        ),
      );
      expect(networkCalls, 0);
    });
  });
}

_ApiFixture _fixture(
  http.Client httpClient, {
  SessionTokens? tokens,
  SessionRefresher? refresher,
}) {
  final store = _MemorySessionStore(tokens);
  final coordinator = SessionCoordinator(
    store: store,
    refresher: refresher ?? _FailingRefresher(),
  );
  final transport = JsonHttpTransport(
    config: ApiConfig(
      baseUrl: Uri.parse('http://localhost:3001'),
      environment: AppEnvironment.development,
    ),
    client: httpClient,
  );
  return _ApiFixture(ApiClient(transport: transport, session: coordinator));
}

final class _ApiFixture {
  const _ApiFixture(this.client);
  final ApiClient client;
}

final class _MemorySessionStore implements SessionStore {
  _MemorySessionStore(this.tokens);
  SessionTokens? tokens;

  @override
  Future<void> clear() async => tokens = null;
  @override
  Future<SessionTokens?> read() async => tokens;
  @override
  Future<void> write(SessionTokens tokens) async => this.tokens = tokens;
}

final class _DelayedRefresher implements SessionRefresher {
  int calls = 0;

  @override
  Future<SessionTokens> refresh(String refreshToken) async {
    calls++;
    await Future<void>.delayed(const Duration(milliseconds: 10));
    return const SessionTokens(
      accessToken: 'new-access',
      refreshToken: 'new-refresh',
    );
  }
}

final class _FailingRefresher implements SessionRefresher {
  @override
  Future<SessionTokens> refresh(String refreshToken) async {
    throw const ApiFailure(
      kind: ApiFailureKind.unauthorized,
      message: 'Sessão ausente.',
      code: 'SESSION_EXPIRED',
    );
  }
}
