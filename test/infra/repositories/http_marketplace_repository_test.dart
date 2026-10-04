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
import 'package:meatshop_mobile/infra/repositories/http_marketplace_repository.dart';

void main() {
  test('loads public units without an authenticated session', () async {
    final repository = _repository(
      MockClient((request) async {
        expect(request.url.path, '/units');
        expect(request.url.queryParameters['lat'], '-8.05');
        expect(request.url.queryParameters['lng'], '-34.9');
        expect(request.url.queryParameters['radius_km'], '25.0');
        expect(request.headers.containsKey('authorization'), isFalse);
        return http.Response(
          jsonEncode({
            'data': [
              {
                'id': 3,
                'name': 'Carnes Centro',
                'latitude': '-8.05',
                'longitude': -34.9,
                'distance_km': 1.25,
                'city': 'Recife',
                'state': 'PE',
                'zip_code': '50000000',
                'street': null,
                'number': null,
                'complement': null,
                'neighborhood': null,
                'image_url': '/uploads/test.png',
                'cover_url': 'https://cdn.example.com/cover.png',
              },
            ],
            'meta': {'page': 1, 'limit': 50, 'total': 1, 'totalPages': 1},
          }),
          200,
        );
      }),
    );
    final page = await repository.listUnits(
      latitude: -8.05,
      longitude: -34.9,
      radiusKm: 25,
    );
    expect(page.items.single.imageUrl, 'http://10.0.2.2:3001/uploads/test.png');
    expect(page.items.single.coverUrl, 'https://cdn.example.com/cover.png');
    expect(page.items.single.id, '3');
    expect(page.items.single.name, 'Carnes Centro');
    expect(page.items.single.latitude, -8.05);
    expect(page.items.single.longitude, -34.9);
    expect(page.items.single.distanceKm, 1.25);
    expect(page.items.single.distanceLabel, '1,3 km de distância');
  });

  test('requests only sellable products and parses stock pagination', () async {
    final repository = _repository(
      MockClient((request) async {
        expect(request.url.queryParameters['available'], 'true');
        expect(request.url.queryParameters['unit_id'], '7');
        return http.Response(
          jsonEncode({
            'data': [
              {
                'id': 9,
                'name': 'Picanha',
                'description': 'Corte',
                'unit_id': 7,
                'unit_name': 'Loja',
                'category_id': 2,
                'brand': null,
                'image_url': '/uploads/test.png',
                'unit_of_measure': 'KG',
                'price': 79.9,
                'active': true,
                'stock_quantity': 4,
              },
            ],
            'meta': {'page': 1, 'limit': 10, 'total': 1, 'totalPages': 1},
          }),
          200,
        );
      }),
    );
    final page = await repository.listProducts(unitId: '7');
    expect(page.items.single.imageUrl, 'http://10.0.2.2:3001/uploads/test.png');
    expect(page.items.single.stockQuantity, 4);
    expect(page.items.single.unitName, 'Loja');
  });
}

HttpMarketplaceRepository _repository(http.Client client) {
  final config = ApiConfig(
    baseUrl: Uri.parse('http://10.0.2.2:3001'),
    environment: AppEnvironment.development,
  );
  final transport = JsonHttpTransport(config: config, client: client);
  final session = SessionCoordinator(
    store: _EmptyStore(),
    refresher: _NeverRefresh(),
  );
  return HttpMarketplaceRepository(
    ApiClient(transport: transport, session: session),
    config,
  );
}

final class _EmptyStore implements SessionStore {
  @override
  Future<void> clear() async {}
  @override
  Future<SessionTokens?> read() async => null;
  @override
  Future<void> write(SessionTokens tokens) async {}
}

final class _NeverRefresh implements SessionRefresher {
  @override
  Future<SessionTokens> refresh(String refreshToken) =>
      throw StateError('not expected');
}
