import 'dart:convert';

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
import 'package:meatshop_mobile/infra/repositories/http_federated_auth_repository.dart';

void main() {
  test('exchanges Firebase token and persists the MeatShop session', () async {
    final store = _MemorySessionStore();
    final repository = _repository(
      store,
      MockClient((request) async {
        expect(request.url.path, '/auth/firebase/exchange');
        expect(request.headers['authorization'], 'Bearer firebase-secret');
        expect(jsonDecode(request.body), isEmpty);
        return http.Response(
          jsonEncode({
            'access_token': 'access-secret',
            'refresh_token': 'refresh-secret',
            'user': {
              'id': 7,
              'email': 'client@example.com',
              'name': null,
              'app_profile': null,
              'profile_complete': false,
            },
          }),
          200,
        );
      }),
    );

    final user = await repository.exchangeFirebaseToken('firebase-secret');

    expect(user.id, 7);
    expect(user.profileComplete, isFalse);
    expect(store.tokens?.accessToken, 'access-secret');
    expect(store.tokens?.refreshToken, 'refresh-secret');
  });

  test('sends the local password only for the first link', () async {
    final repository = _repository(
      _MemorySessionStore(),
      MockClient((request) async {
        expect(jsonDecode(request.body), {'password': 'local-password'});
        return http.Response(
          jsonEncode({
            'access_token': 'access',
            'refresh_token': 'refresh',
            'user': {
              'id': 1,
              'email': 'linked@example.com',
              'name': 'Linked',
              'app_profile': 'BOTH',
              'profile_complete': true,
            },
          }),
          200,
        );
      }),
    );

    final user = await repository.exchangeFirebaseToken(
      'firebase-token',
      accountPassword: 'local-password',
    );

    expect(user.profileComplete, isTrue);
    expect(user.appProfile?.name, 'both');
  });
}

HttpFederatedAuthRepository _repository(
  _MemorySessionStore store,
  http.Client httpClient,
) {
  final transport = JsonHttpTransport(
    config: ApiConfig(
      baseUrl: Uri.parse('http://localhost:3001'),
      environment: AppEnvironment.development,
    ),
    client: httpClient,
  );
  final session = SessionCoordinator(store: store, refresher: _NeverRefresh());
  return HttpFederatedAuthRepository(
    transport: transport,
    client: ApiClient(transport: transport, session: session),
    session: session,
  );
}

final class _MemorySessionStore implements SessionStore {
  SessionTokens? tokens;

  @override
  Future<void> clear() async => tokens = null;
  @override
  Future<SessionTokens?> read() async => tokens;
  @override
  Future<void> write(SessionTokens tokens) async => this.tokens = tokens;
}

final class _NeverRefresh implements SessionRefresher {
  @override
  Future<SessionTokens> refresh(String refreshToken) async {
    throw const ApiFailure(
      kind: ApiFailureKind.unauthorized,
      message: 'Not expected.',
    );
  }
}
