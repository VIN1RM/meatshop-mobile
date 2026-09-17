import 'dart:convert';
import 'dart:typed_data';

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
import 'package:meatshop_mobile/infra/repositories/http_address_repository.dart';
import 'package:meatshop_mobile/infra/repositories/http_cart_repository.dart';
import 'package:meatshop_mobile/infra/repositories/http_profile_repository.dart';

void main() {
  test('maps authenticated profile and resolves relative avatar URL', () async {
    final client = _apiClient(
      MockClient((request) async {
        expect(request.url.path, '/users/me');
        expect(request.headers['authorization'], 'Bearer access');
        return _json({
          'ok': true,
          'user': {
            'id': 8,
            'name': 'Ana',
            'email': 'ana@teste.com',
            'cpf': '12345678901',
            'phone': '62999999999',
            'avatar_url': '/uploads/avatars/ana.jpg',
          },
        });
      }),
    );
    final repository = HttpProfileRepository(client, _config);

    final profile = await repository.getProfile();

    expect(profile.uid, '8');
    expect(profile.photoUrl, 'http://localhost:3001/uploads/avatars/ana.jpg');
  });

  test('uploads avatar as authenticated multipart bytes', () async {
    final repository = HttpProfileRepository(
      _apiClient(
        MockClient((request) async {
          expect(request.url.path, '/users/me/avatar');
          expect(request.headers['authorization'], 'Bearer access');
          expect(
            request.headers['content-type'],
            startsWith('multipart/form-data; boundary='),
          );
          expect(latin1.decode(request.bodyBytes), contains('avatar.png'));
          return _json({
            'avatar_url': '/uploads/avatars/new.png',
          }, statusCode: 201);
        }),
      ),
      _config,
    );

    final url = await repository.uploadAvatar(
      bytes: Uint8List.fromList([137, 80, 78, 71]),
      fileName: 'avatar.png',
      contentType: 'image/png',
    );

    expect(url, 'http://localhost:3001/uploads/avatars/new.png');
  });

  test('resolves CEP through backend with coordinates', () async {
    final repository = HttpAddressRepository(
      _apiClient(
        MockClient((request) async {
          expect(request.url.path, '/geocoding/resolve');
          expect(jsonDecode(request.body), {'zip_code': '75113300'});
          return _json({
            'zip_code': '75113-300',
            'street': 'Angelo Teles',
            'neighborhood': 'Vila Santa Maria de Nazareth',
            'city': 'Anápolis',
            'state': 'GO',
            'latitude': -16.32,
            'longitude': -48.95,
          });
        }),
      ),
    );

    final address = await repository.resolveZipCode('75113300');

    expect(address.city, 'Anápolis');
    expect(address.lat, -16.32);
    expect(address.lng, -48.95);
  });

  test('keeps products from multiple units in one cart response', () async {
    final repository = HttpCartRepository(
      _apiClient(
        MockClient((request) async {
          expect(request.url.path, '/cart/items');
          expect(jsonDecode(request.body), {'product_id': 11, 'quantity': 0.5});
          return _json({
            'id': 1,
            'items': [
              _cartItem(id: 1, productId: 11, unitId: 4),
              _cartItem(id: 2, productId: 22, unitId: 9),
            ],
            'groups': [],
            'total': 59.85,
          }, statusCode: 201);
        }),
      ),
    );

    final items = await repository.addItem('11', 0.5);

    expect(items, hasLength(2));
    expect(items.map((item) => item.unitId).toSet(), {'4', '9'});
    expect(items.first.quantity, 0.5);
  });
}

Map<String, Object?> _cartItem({
  required int id,
  required int productId,
  required int unitId,
}) => {
  'id': id,
  'product_id': productId,
  'product_name': 'Produto $productId',
  'product_image_url': null,
  'unit_of_measure': 'KG',
  'unit_id': unitId,
  'unit_name': 'Unidade $unitId',
  'unit_image_url': null,
  'quantity': 0.5,
  'available_stock': 5,
  'unit_price': 59.85,
  'subtotal': 29.93,
};

final _config = ApiConfig(
  baseUrl: Uri.parse('http://localhost:3001'),
  environment: AppEnvironment.development,
);

ApiClient _apiClient(http.Client client) => ApiClient(
  transport: JsonHttpTransport(config: _config, client: client),
  session: SessionCoordinator(store: _TokenStore(), refresher: _NeverRefresh()),
);

http.Response _json(Object body, {int statusCode = 200}) => http.Response(
  jsonEncode(body),
  statusCode,
  headers: {'content-type': 'application/json'},
);

final class _TokenStore implements SessionStore {
  @override
  Future<void> clear() async {}
  @override
  Future<SessionTokens?> read() async =>
      const SessionTokens(accessToken: 'access', refreshToken: 'refresh');
  @override
  Future<void> write(SessionTokens tokens) async {}
}

final class _NeverRefresh implements SessionRefresher {
  @override
  Future<SessionTokens> refresh(String refreshToken) =>
      throw StateError('not expected');
}
