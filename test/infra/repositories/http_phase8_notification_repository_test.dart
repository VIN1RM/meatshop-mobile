import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:meatshop_mobile/core/auth/session_coordinator.dart';
import 'package:meatshop_mobile/core/auth/session_refresher.dart';
import 'package:meatshop_mobile/core/auth/session_store.dart';
import 'package:meatshop_mobile/core/auth/session_tokens.dart';
import 'package:meatshop_mobile/core/config/api_config.dart';
import 'package:meatshop_mobile/infra/http/api_client.dart';
import 'package:meatshop_mobile/infra/http/json_http_transport.dart';
import 'package:meatshop_mobile/infra/realtime/backend_realtime_client.dart';
import 'package:meatshop_mobile/infra/repositories/http_notification_repository.dart';

void main() {
  test(
    'registers and removes the FCM token only through the backend',
    () async {
      var call = 0;
      final repository = _repository(
        MockClient((request) async {
          call++;
          expect(request.url.path, '/notifications/device-tokens');
          expect(request.headers['authorization'], 'Bearer access');
          expect(request.headers['x-firebase-appcheck'], 'attestation');
          if (call == 1) {
            expect(request.method, 'POST');
            expect(jsonDecode(request.body), {
              'fcm_token': 'fcm-value',
              'platform': 'ANDROID',
              'app_version': '3.0.0',
            });
          } else {
            expect(request.method, 'DELETE');
            expect(jsonDecode(request.body), {'fcm_token': 'fcm-value'});
          }
          return http.Response('', 204);
        }),
      );

      await repository.registerDeviceToken(
        token: 'fcm-value',
        platform: 'ANDROID',
        appVersion: '3.0.0',
      );
      await repository.unregisterDeviceToken('fcm-value');
      expect(call, 2);
    },
  );

  test('reloads notification state from PostgreSQL contract', () async {
    final repository = _repository(
      MockClient((request) async {
        expect(request.url.path, '/notifications');
        return http.Response(
          jsonEncode([
            {
              'id': 31,
              'title': 'Pedido atualizado',
              'message': 'Consulte o pedido',
              'type': 'ORDER',
              'read': false,
              'action_url': '/orders/42',
              'unit_id': 2,
              'created_at': '2026-09-03T12:00:00.000Z',
            },
          ]),
          200,
        );
      }),
    );

    final notification = (await repository.list()).single;
    expect(notification.id, '31');
    expect(notification.payload?['action_url'], '/orders/42');
    expect(notification.read, isFalse);
  });

  test('classifies server disconnect authentication failures for recovery', () {
    expect(isRealtimeAuthenticationFailure('Unauthorized'), isTrue);
    expect(isRealtimeAuthenticationFailure('network unavailable'), isFalse);
  });
}

HttpNotificationRepository _repository(http.Client httpClient) {
  final transport = JsonHttpTransport(
    config: ApiConfig(
      baseUrl: Uri.parse('http://localhost:3001'),
      environment: AppEnvironment.development,
    ),
    client: httpClient,
    requestHeaders: () async => const {
      'x-meatshop-client': 'mobile',
      'x-firebase-appcheck': 'attestation',
    },
  );
  final session = SessionCoordinator(store: _Store(), refresher: _Refresh());
  return HttpNotificationRepository(
    ApiClient(transport: transport, session: session),
  );
}

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
