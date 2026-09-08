import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:meatshop_mobile/core/config/api_config.dart';
import 'package:meatshop_mobile/core/network/api_failure.dart';
import 'package:meatshop_mobile/core/network/cancellation_token.dart';
import 'package:meatshop_mobile/infra/http/json_http_transport.dart';

void main() {
  group('JsonHttpTransport', () {
    test('consulta endpoint público e decodifica JSON', () async {
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

    test('normaliza erro NestJS e respeita Retry-After', () async {
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

    test('distingue cancelamento de timeout', () async {
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
