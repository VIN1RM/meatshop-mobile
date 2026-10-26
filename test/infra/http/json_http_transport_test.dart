import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:meatshop_mobile/core/config/api_config.dart';
import 'package:meatshop_mobile/core/network/api_failure.dart';
import 'package:meatshop_mobile/core/network/cancellation_token.dart';
import 'package:meatshop_mobile/infra/auth/backend_session_refresher.dart';
import 'package:meatshop_mobile/infra/http/json_http_transport.dart';

void main() {
  group('JsonHttpTransport', () {
    test('requests a public endpoint and decodes JSON', () async {
      final transport = _transport(
        MockClient((request) async {
          expect(request.url.path, '/health');
          expect(request.headers['accept'], 'application/json');
          return http.Response('{"status":"ok"}', 200);
        }),
      );

      expect(await transport.send(method: 'GET', path: '/health'), {
        'status': 'ok',
      });
    });

    test('identifies the mobile client on every JSON request', () async {
      final transport = _transport(
        MockClient((request) async {
          expect(request.headers['x-client-platform'], 'mobile');
          return http.Response('{}', 200);
        }),
      );

      await transport.send(
        method: 'POST',
        path: '/auth/login',
        body: const {'email': 'a@b.c'},
        headers: const {'x-client-platform': 'web'},
      );
    });

    test('identifies the mobile client on multipart uploads', () async {
      final transport = _transport(
        MockClient((request) async {
          expect(request.headers['x-client-platform'], 'mobile');
          return http.Response('{}', 200);
        }),
      );

      await transport.sendMultipart(
        path: '/users/me/avatar',
        bytes: Uint8List.fromList(const [1, 2, 3]),
        fileName: 'avatar.png',
        contentType: 'image/png',
      );
    });

    test('identifies the mobile client on session refresh', () async {
      final transport = _transport(
        MockClient((request) async {
          expect(request.url.path, '/auth/refresh');
          expect(request.headers['x-client-platform'], 'mobile');
          return http.Response(
            '{"access_token":"access","refresh_token":"refresh"}',
            200,
          );
        }),
      );

      final tokens = await BackendSessionRefresher(transport).refresh('old');

      expect(tokens.accessToken, 'access');
    });

    test('normalizes NestJS errors and respects Retry-After', () async {
      final transport = _transport(
        MockClient(
          (_) async => http.Response(
            '{"statusCode":429,"message":"Muitas tentativas"}',
            429,
            headers: {'retry-after': '30', 'x-request-id': 'request-1'},
          ),
        ),
      );

      await expectLater(
        transport.send(method: 'GET', path: '/limited'),
        throwsA(
          isA<ApiFailure>()
              .having(
                (failure) => failure.kind,
                'kind',
                ApiFailureKind.rateLimited,
              )
              .having(
                (failure) => failure.retryAfter,
                'retryAfter',
                const Duration(seconds: 30),
              )
              .having((failure) => failure.requestId, 'requestId', 'request-1'),
        ),
      );
    });

    test('distinguishes cancellation from timeout', () async {
      final cancellation = CancellationToken();
      final cancelledTransport = _transport(_AbortAwareClient());
      final pending = cancelledTransport.send(
        method: 'GET',
        path: '/slow',
        cancellationToken: cancellation,
      );
      cancellation.cancel();

      await expectLater(
        pending,
        throwsA(
          isA<ApiFailure>().having(
            (failure) => failure.kind,
            'kind',
            ApiFailureKind.cancelled,
          ),
        ),
      );

      final timeoutTransport = _transport(
        _AbortAwareClient(),
        timeout: const Duration(milliseconds: 5),
      );
      await expectLater(
        timeoutTransport.send(method: 'GET', path: '/slow'),
        throwsA(
          isA<ApiFailure>().having(
            (failure) => failure.kind,
            'kind',
            ApiFailureKind.timeout,
          ),
        ),
      );
    });
  });
}

JsonHttpTransport _transport(
  http.Client client, {
  Duration timeout = const Duration(seconds: 1),
}) => JsonHttpTransport(
  config: ApiConfig(
    baseUrl: Uri.parse('http://localhost:3001'),
    environment: AppEnvironment.development,
    requestTimeout: timeout,
  ),
  client: client,
);

final class _AbortAwareClient extends http.BaseClient {
  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    final abortable = request as http.AbortableRequest;
    await abortable.abortTrigger;
    throw http.RequestAbortedException(request.url);
  }
}
