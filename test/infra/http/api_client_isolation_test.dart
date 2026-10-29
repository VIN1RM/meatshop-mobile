import 'dart:async';
import 'dart:typed_data';
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

class Store implements SessionStore {
  SessionTokens? tokens = const SessionTokens(
    accessToken: 'a',
    refreshToken: 'ra',
  );
  @override
  Future<SessionTokens?> read() async => tokens;
  @override
  Future<void> write(SessionTokens value) async {
    tokens = value;
  }

  @override
  Future<void> clear() async {
    tokens = null;
  }
}

class Refresher implements SessionRefresher {
  int calls = 0;
  @override
  Future<SessionTokens> refresh(String token) async {
    calls++;
    return const SessionTokens(accessToken: 'refreshed', refreshToken: 'rr');
  }
}

void main() {
  for (final multipart in [false, true]) {
    for (final status in [200, 401]) {
      test(
        'rejects stale ${multipart ? 'upload' : 'request'} response $status without replaying on another account',
        () async {
          final pending = Completer<http.Response>();
          final sent = Completer<void>();
          final refresher = Refresher();
          final session = SessionCoordinator(
            store: Store(),
            refresher: refresher,
          );
          var calls = 0;
          final transport = JsonHttpTransport(
            config: ApiConfig(
              baseUrl: Uri.parse('http://localhost:3001'),
              environment: AppEnvironment.development,
            ),
            client: MockClient((request) {
              calls++;
              expect(request.headers['authorization'], 'Bearer a');
              sent.complete();
              return pending.future;
            }),
          );
          addTearDown(transport.close);
          final client = ApiClient(transport: transport, session: session);
          final request = multipart
              ? client.postMultipart(
                  '/avatar',
                  bytes: Uint8List.fromList([1]),
                  fileName: 'photo.jpg',
                  contentType: 'image/jpeg',
                  decode: (value) => value,
                )
              : client.get('/users/me', decode: (value) => value);
          final failure = expectLater(
            request,
            throwsA(
              isA<ApiFailure>().having(
                (e) => e.code,
                'code',
                'SESSION_CHANGED',
              ),
            ),
          );
          await sent.future;
          await session.save(
            const SessionTokens(accessToken: 'b', refreshToken: 'rb'),
          );
          pending.complete(http.Response('{}', status));
          await failure;
          expect(calls, 1);
          expect(refresher.calls, 0);
          expect(session.current!.accessToken, 'b');
        },
      );
    }
  }
}
