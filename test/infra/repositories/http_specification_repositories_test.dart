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
import 'package:meatshop_mobile/infra/repositories/http_support_repository.dart';
import 'package:meatshop_mobile/infra/repositories/http_delivery_expense_repository.dart';
import 'package:meatshop_mobile/infra/repositories/http_personal_data_repository.dart';

ApiClient _client(Future<http.Response> Function(http.Request) respond) =>
    ApiClient(
      transport: JsonHttpTransport(
        config: ApiConfig(
          baseUrl: Uri.parse('http://localhost:3001'),
          environment: AppEnvironment.development,
        ),
        client: MockClient((request) {
          expect(request.headers['authorization'], 'Bearer access');
          return respond(request);
        }),
      ),
      session: SessionCoordinator(store: _Store(), refresher: _Refresh()),
    );

class _Store implements SessionStore {
  @override
  Future<void> clear() async {}
  @override
  Future<SessionTokens?> read() async =>
      const SessionTokens(accessToken: 'access', refreshToken: 'refresh');
  @override
  Future<void> write(SessionTokens tokens) async {}
}

class _Refresh implements SessionRefresher {
  @override
  Future<SessionTokens> refresh(String token) =>
      throw StateError('unexpected refresh');
}

void main() {
  test(
    'persists support messages using the authenticated ticket API',
    () async {
      final repo = HttpSupportRepository(
        _client((request) async {
          expect(request.method, 'POST');
          expect(request.url.path, '/support-tickets/7/messages');
          expect(jsonDecode(request.body), {'message': 'Preciso de ajuda'});
          return http.Response('{}', 201);
        }),
      );
      await repo.send(7, ' Preciso de ajuda ');
    },
  );
  test(
    'loads expense dates and server totals independently from the page sum',
    () async {
      final repo = HttpDeliveryExpenseRepository(
        _client((request) async {
          expect(request.url.queryParameters['from'], '2026-10-01');
          expect(request.url.queryParameters['to'], '2026-10-31');
          return http.Response(
            jsonEncode({
              'data': [
                {
                  'id': 1,
                  'category': 'FUEL',
                  'description': 'Teste',
                  'amount': '10.50',
                  'incurred_on': '2026-10-01',
                },
              ],
              'total': 2,
              'total_amount': '30.50',
            }),
            200,
          );
        }),
      );
      final result = await repo.list(from: '2026-10-01', to: '2026-10-31');
      expect(result.totalAmount, 30.5);
      expect(result.items.single.amount, 10.5);
      expect(result.total, 2);
    },
  );
  test(
    'exports only the current account without accepting a user identifier',
    () async {
      final repo = HttpPersonalDataRepository(
        _client((request) async {
          expect(request.url.path, '/users/me/export');
          expect(request.url.query, isEmpty);
          return http.Response(
            jsonEncode({
              'version': 1,
              'data': {
                'profile': [
                  {'email': 'own@example.invalid'},
                ],
              },
            }),
            200,
          );
        }),
      );
      expect(
        jsonDecode(await repo.export())['data']['profile'][0]['email'],
        'own@example.invalid',
      );
    },
  );
}
