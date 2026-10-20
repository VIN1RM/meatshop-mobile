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
import 'package:meatshop_mobile/infra/auth/secure_key_value_store.dart';
import 'package:meatshop_mobile/infra/http/api_client.dart';
import 'package:meatshop_mobile/infra/http/json_http_transport.dart';
import 'package:meatshop_mobile/infra/repositories/http_order_repository.dart';
import 'package:meatshop_mobile/models/checkout_summary_model.dart';

const summary = CheckoutSummaryModel(
  addressId: '7',
  isScheduled: false,
  paymentMethod: 'pix',
  expectedTotal: 50,
  quoteToken: '1.digest.signature',
);
final result = jsonEncode({
  'checkout_id': 'original-key',
  'orders': [
    {'id': 42, 'payment_status': 'PENDING'},
  ],
  'total_amount': 50,
});

void main() {
  Future<ApiClient> client(
    Future<http.Response> Function(http.Request) handler,
  ) async {
    final session = SessionCoordinator(
      store: _Session(),
      refresher: _Refresher(),
    );
    await session.save(
      SessionTokens(
        accessToken:
            'header.${base64Url.encode(utf8.encode('{"sub":7}'))}.signature',
        refreshToken: 'refresh',
      ),
    );
    final transport = JsonHttpTransport(
      config: ApiConfig(
        baseUrl: Uri.parse('http://localhost:3001'),
        environment: AppEnvironment.development,
      ),
      client: MockClient(handler),
    );
    addTearDown(transport.close);
    return ApiClient(transport: transport, session: session);
  }

  test(
    'restarting after a lost response recovers the original order without another POST',
    () async {
      final storage = _Storage();
      final first = HttpOrderRepository(
        await client((_) async => throw http.ClientException('lost response')),
        pendingStorage: storage,
      );
      await expectLater(
        first.create(summary, idempotencyKey: 'original-key'),
        throwsA(isA<ApiFailure>()),
      );
      expect(storage.data, isNotEmpty);
      var posts = 0;
      final restarted = HttpOrderRepository(
        await client((request) async {
          if (request.method == 'POST') posts++;
          expect(request.url.path, '/orders/checkouts/original-key');
          return http.Response(result, 200);
        }),
        pendingStorage: storage,
      );
      final recovered = await restarted.create(
        summary.copyWith(total: 60),
        idempotencyKey: 'new-key',
      );
      expect(recovered.recovered, isTrue);
      expect(recovered.orders.single.id, '42');
      expect(posts, 0);
      expect(storage.data, isEmpty);
    },
  );

  test(
    'an unresolved attempt retains its original body and key when the intended purchase changes',
    () async {
      final storage = _Storage();
      final first = HttpOrderRepository(
        await client((_) async => http.Response('{}', 500)),
        pendingStorage: storage,
      );
      await expectLater(
        first.create(summary, idempotencyKey: 'original-key'),
        throwsA(isA<ApiFailure>()),
      );
      final restarted = HttpOrderRepository(
        await client((request) async {
          if (request.method == 'GET') return http.Response('null', 200);
          expect(request.headers['idempotency-key'], 'original-key');
          expect(jsonDecode(request.body)['expected_total'], 50);
          return http.Response(result, 201);
        }),
        pendingStorage: storage,
      );
      final recovered = await restarted.create(
        summary.copyWith(total: 60),
        idempotencyKey: 'new-key',
      );
      expect(recovered.recovered, isTrue);
      expect(storage.data, isEmpty);
    },
  );

  test(
    'a definitive quote validation failure releases the stored attempt for a revised purchase',
    () async {
      final storage = _Storage();
      final repository = HttpOrderRepository(
        await client(
          (_) async => http.Response('{"code":"QUOTE_CHANGED"}', 400),
        ),
        pendingStorage: storage,
      );
      await expectLater(
        repository.create(summary, idempotencyKey: 'original-key'),
        throwsA(isA<ApiFailure>()),
      );
      expect(storage.data, isEmpty);
    },
  );
}

class _Storage implements SecureKeyValueStore {
  final data = <String, String>{};
  @override
  Future<String?> read(String key) async => data[key];
  @override
  Future<void> write(String key, String value) async {
    data[key] = value;
  }

  @override
  Future<void> delete(String key) async {
    data.remove(key);
  }
}

class _Session implements SessionStore {
  SessionTokens? value;
  @override
  Future<SessionTokens?> read() async => value;
  @override
  Future<void> write(SessionTokens tokens) async {
    value = tokens;
  }

  @override
  Future<void> clear() async {
    value = null;
  }
}

class _Refresher implements SessionRefresher {
  @override
  Future<SessionTokens> refresh(String token) async =>
      throw StateError('Unexpected refresh');
}
