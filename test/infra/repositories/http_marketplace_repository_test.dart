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
        expect(request.headers.containsKey('authorization'), isFalse);
        return http.Response(
          jsonEncode({
            'data': [
              {
                'id': 3,
                'name': 'Carnes Centro',
                'city': 'Recife',
                'state': 'PE',
                'zip_code': '50000000',
                'street': null,
                'number': null,
                'complement': null,
                'neighborhood': null,
                'image_url': null,
                'cover_url': null,
              },
            ],
            'meta': {'page': 1, 'limit': 50, 'total': 1, 'totalPages': 1},
          }),
          200,
        );
      }),
    );
    final page = await repository.listUnits();
    expect(page.items.single.id, '3');
    expect(page.items.single.name, 'Carnes Centro');
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
                'image_url': null,
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
    expect(page.items.single.stockQuantity, 4);
    expect(page.items.single.unitName, 'Loja');
  });
}

HttpMarketplaceRepository _repository(http.Client client) {
  final transport = JsonHttpTransport(
    config: ApiConfig(
      baseUrl: Uri.parse('http://localhost:3001'),
      environment: AppEnvironment.development,
    ),
    client: client,
  );
  final session = SessionCoordinator(
    store: _EmptyStore(),
    refresher: _NeverRefresh(),
  );
  return HttpMarketplaceRepository(
    ApiClient(transport: transport, session: session),
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
