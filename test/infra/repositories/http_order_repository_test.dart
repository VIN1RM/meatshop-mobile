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
          expect(path, '/orders/mobile');
          return http.Response(
            jsonEncode({
              'has_more': false,
              'data': [
                for (final id in [1, 2])
                  {
                    'id': id,
                    'status': 'DELIVERED',
                    'items': [
                      {'product_id': 10, 'quantity': 1},
                      {'product_id': 20, 'quantity': 1},
                    ],
                    'review_status': {
                      'unit_reviewed': true,
                      'reviewed_product_ids': id == 1 ? [10, 20] : [10],
                    },
                  },
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

  test(
    'loads only the requested finished history page and keeps older orders',
    () async {
      final requested = <int>[];
      final transport = JsonHttpTransport(
        config: ApiConfig(
          baseUrl: Uri.parse('http://localhost:3001'),
          environment: AppEnvironment.development,
        ),
        client: MockClient((request) async {
          final page = int.parse(request.url.queryParameters['page']!);
          requested.add(page);
          expect(request.url.queryParameters, {
            'page': '$page',
            'finished': 'true',
          });
          return http.Response(
            jsonEncode({
              'has_more': page == 0,
              'data': [
                {
                  'id': page + 1,
                  'status': 'DELIVERED',
                  'order_date': '2020-01-01T12:00:00Z',
                  'items': [],
                },
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
      final repository = HttpOrderRepository(
        ApiClient(transport: transport, session: session),
      );
      final first = await repository.historyPage(0);
      expect(requested, [0]);
      expect(first.hasMore, isTrue);
      expect(first.orders.single.orderDate!.year, 2020);
      final last = await repository.historyPage(1);
      expect(requested, [0, 1]);
      expect(last.orders.single.id, '2');
      expect(last.hasMore, isFalse);
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
