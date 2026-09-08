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
import 'package:meatshop_mobile/infra/repositories/http_order_repository.dart';
import 'package:meatshop_mobile/infra/repositories/http_payment_repository.dart';
import 'package:meatshop_mobile/models/checkout_summary_model.dart';

void main() {
  const summary = CheckoutSummaryModel(
    addressId: '12',
    isScheduled: false,
    paymentMethod: 'pix',
  );

  test(
    'quotes server values and creates two orders with an idempotency key',
    () async {
      var call = 0;
      final repository = HttpOrderRepository(
        _apiClient(
          MockClient((request) async {
            call++;
            expect(request.headers['authorization'], 'Bearer access');
            if (call == 1) {
              expect(request.url.path, '/cart/quote');
              expect(jsonDecode(request.body), {
                'delivery_type': 'DELIVERY',
                'address_id': 12,
                'payment_method': 'Pix',
              });
              return _json({
                'groups': [
                  {
                    'unit_id': 4,
                    'subtotal': 25,
                    'discount_amount': 0,
                    'delivery_fee': 8.5,
                    'total_amount': 33.5,
                  },
                  {
                    'unit_id': 9,
                    'subtotal': 40,
                    'discount_amount': 5,
                    'delivery_fee': 8.5,
                    'total_amount': 43.5,
                  },
                ],
                'total_amount': 77,
              }, statusCode: 201);
            }

            expect(request.url.path, '/orders');
            expect(
              request.headers['idempotency-key'],
              '123e4567-e89b-42d3-a456-426614174000',
            );
            return _json({
              'checkout_id': '123e4567-e89b-42d3-a456-426614174000',
              'orders': [_order(101, 4, 33.5), _order(102, 9, 43.5)],
              'total_amount': 77,
            }, statusCode: 201);
          }),
        ),
      );

      final quote = await repository.quote(summary);
      final checkout = await repository.create(
        summary,
        idempotencyKey: '123e4567-e89b-42d3-a456-426614174000',
      );

      expect(quote.groups.map((group) => group.unitId), ['4', '9']);
      expect(quote.totalAmount, 77);
      expect(checkout.orders.map((order) => order.id), ['101', '102']);
      expect(checkout.orders.first.deliveryCode, '654321');
    },
  );

  test('creates one Mercado Pago checkout for the entire order batch', () async {
    final repository = HttpOrderRepository(
      _apiClient(
        MockClient((request) async {
          expect(
            request.url.path,
            '/mercadopago/checkouts/123e4567-e89b-42d3-a456-426614174000/checkout',
          );
          return _json({
            'ok': true,
            'checkoutId': '123e4567-e89b-42d3-a456-426614174000',
            'checkoutUrl': 'https://mercadopago.test/checkout',
          }, statusCode: 201);
        }),
      ),
    );

    expect(
      await repository.createPayment('123e4567-e89b-42d3-a456-426614174000'),
      'https://mercadopago.test/checkout',
    );
  });

  test('maps only safe saved-card metadata from the backend', () async {
    final repository = HttpPaymentRepository(
      _apiClient(
        MockClient(
          (request) async => _json([
            {
              'id': 7,
              'brand': 'visa',
              'last_four': '4242',
              'holder_name': 'ANA',
              'expiration_month': '08',
              'expiration_year': '2030',
              'is_default': true,
              'created_at': '2026-09-02T12:00:00.000Z',
            },
          ]),
        ),
      ),
    );

    final methods = await repository.list();
    expect(methods.single.lastFour, '4242');
    expect(methods.single.mpCardId, isEmpty);
    expect(methods.single.mpCustomerId, isEmpty);
  });
}

Map<String, Object?> _order(int id, int unitId, double total) => {
  'id': id,
  'client_id': 8,
  'unit_id': unitId,
  'unit_name': 'Unidade $unitId',
  'unit_logo_url': '',
  'order_date': '2026-09-02T12:00:00.000Z',
  'status': 'PENDING',
  'delivery_status': 'WAITING_DELIVERY_PERSON',
  'delivery_type': 'DELIVERY',
  'payment_status': 'PENDING',
  'subtotal': total - 8.5,
  'discount_amount': 0,
  'delivery_fee': 8.5,
  'total_amount': total,
  'address_id': 12,
  'is_scheduled': false,
  'scheduled_delivery_date': null,
  'items': [
    {
      'id': id,
      'product_id': id,
      'product_name': 'Produto',
      'unit_of_measure': 'kg',
      'product_image_url': null,
      'quantity': 0.5,
      'unit_price': 50,
    },
  ],
  'payment': {'method': 'Pix', 'status': 'PENDING', 'payment_date': null},
  'delivery_code': '654321',
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
