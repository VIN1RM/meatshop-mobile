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
import 'package:meatshop_mobile/infra/repositories/http_delivery_repository.dart';

void main() {
  test('loads available delivery offers exclusively from backend', () async {
    final repository = HttpDeliveryRepository(
      _client(
        MockClient((request) async {
          expect(request.url.path, '/delivery/me/orders/available');
          expect(request.headers['authorization'], 'Bearer access');
          return _json([_order]);
        }),
      ),
    );

    final orders = await repository.availableOrders();
    expect(orders.single.id, 42);
    expect(orders.single.unitName, 'Unidade Centro');
    expect(orders.single.deliveryFee, 9.5);
  });

  test('sends availability and rejection without personal data', () async {
    var call = 0;
    final repository = HttpDeliveryRepository(
      _client(
        MockClient((request) async {
          call++;
          if (call == 1) {
            expect(request.url.path, '/delivery/me/availability');
            expect(jsonDecode(request.body), {'is_online': true});
          } else {
            expect(request.url.path, '/delivery/orders/42/reject');
            expect(jsonDecode(request.body), {
              'reasons': ['Distância'],
            });
          }
          return _json({});
        }),
      ),
    );
    await repository.setAvailability(true);
    await repository.reject(42, ['Distância']);
    expect(call, 2);
  });

  test(
    'maps pickup code and sends location accuracy only to assigned order',
    () async {
      var call = 0;
      final repository = HttpDeliveryRepository(
        _client(
          MockClient((request) async {
            call++;
            if (call == 1) {
              expect(request.url.path, '/delivery/orders/42/accept');
              return _json({'pickup_code': '482193', 'order': _order});
            }
            expect(request.url.path, '/delivery/orders/42/location');
            expect(jsonDecode(request.body), {
              'latitude': -23.55,
              'longitude': -46.63,
              'accuracy': 12.5,
            });
            return _json({});
          }),
        ),
      );

      expect(await repository.accept(42), '482193');
      await repository.sendLocation(42, -23.55, -46.63, accuracy: 12.5);
      expect(call, 2);
    },
  );
}

const _order = <String, Object?>{
  'id': 42,
  'client_id': '8',
  'client_name': 'Cliente',
  'unit_id': '3',
  'unit_name': 'Unidade Centro',
  'items': '1x Produto',
  'total_amount': 59.5,
  'delivery_fee': 9.5,
  'delivery_status': 'WAITING_DELIVERY_PERSON',
  'delivery_step': 'PICKUP',
  'unit_address': <String, Object?>{},
  'delivery_address': <String, Object?>{},
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
