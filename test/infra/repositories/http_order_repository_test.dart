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
import 'package:meatshop_mobile/infra/repositories/http_order_repository.dart';
import 'package:meatshop_mobile/models/checkout_summary_model.dart';

void main() {
  test(
    'completed orders load persisted review status and partial product reviews remain available',
    () async {
      final transport = JsonHttpTransport(
        config: ApiConfig(
          baseUrl: Uri.parse('http://localhost:3001'),
          environment: AppEnvironment.development,
        ),
        client: MockClient((request) async {
          final path = request.url.path;
          if (path == '/orders')
            return http.Response('[{"id":1},{"id":2}]', 200);
          if (path.endsWith('/reviews/status')) {
            return http.Response(
              jsonEncode({
                'unit_reviewed': true,
                'delivery_reviewed': false,
                'reviewed_product_ids': path.contains('/1/') ? [10, 20] : [10],
              }),
              200,
            );
          }
          return http.Response(
            jsonEncode({
              'id': path.split('/').last,
              'status': 'DELIVERED',
              'items': [
                {'product_id': 10, 'quantity': 1},
                {'product_id': 20, 'quantity': 1},
              ],
            }),
            200,
          );
        }),
      );
      addTearDown(transport.close);
      final session = SessionCoordinator(
        store: _MemorySessionStore(),
        refresher: _NeverRefresh(),
      );
      await session.save(
        const SessionTokens(accessToken: 'access', refreshToken: 'refresh'),
      );
      final orders = await HttpOrderRepository(
        ApiClient(transport: transport, session: session),
      ).list();
      expect(orders.first.reviewed, isTrue);
      expect(orders.first.productsReviewed, isTrue);
      expect(orders.last.reviewed, isTrue);
      expect(orders.last.productsReviewed, isFalse);
    },
  );

  for (final entry in {
    'cash': 'Cash',
    'credit': 'Credit',
    'debit': 'Debit',
    'pix': 'Pix',
  }.entries) {
    test(
      '${entry.key} uses the API payment enum in quotes and orders',
      () async {
        final requests = <String>[];
        final transport = JsonHttpTransport(
          config: ApiConfig(
            baseUrl: Uri.parse('http://localhost:3001'),
            environment: AppEnvironment.development,
          ),
          client: MockClient((request) async {
            requests.add(request.url.path);
            expect(jsonDecode(request.body), {
              'delivery_type': 'DELIVERY',
              'address_id': 7,
              'payment_method': entry.value,
            });
            if (request.url.path == '/cart/quote') {
              return http.Response(
                jsonEncode({
                  'groups': [
                    {
                      'unit_id': 1,
                      'subtotal': 1.5,
                      'discount_amount': 0,
                      'delivery_fee': 4.3,
                      'total_amount': 5.8,
                    },
                  ],
                  'total_amount': 5.8,
                }),
                200,
              );
            }
            expect(request.headers['idempotency-key'], 'test-key');
            return http.Response(
              jsonEncode({
                'checkout_id': 'checkout',
                'orders': [],
                'total_amount': 5.8,
              }),
              201,
            );
          }),
        );
        addTearDown(transport.close);
        final session = SessionCoordinator(
          store: _MemorySessionStore(),
          refresher: _NeverRefresh(),
        );
        await session.save(
          const SessionTokens(accessToken: 'access', refreshToken: 'refresh'),
        );
        final repository = HttpOrderRepository(
          ApiClient(transport: transport, session: session),
        );
        final summary = CheckoutSummaryModel(
          addressId: '7',
          isScheduled: false,
          paymentMethod: entry.key,
        );
        final quote = await repository.quote(summary);
        expect(quote.groups.single.deliveryFee, 4.3);
        expect(quote.totalAmount, 5.8);
        await repository.create(summary, idempotencyKey: 'test-key');
        expect(requests, ['/cart/quote', '/orders']);
      },
    );
  }
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
