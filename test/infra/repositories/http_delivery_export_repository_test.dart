import 'dart:async';
import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:meatshop_mobile/core/network/api_failure.dart';
import 'package:meatshop_mobile/core/network/cancellation_token.dart';
import 'package:meatshop_mobile/infra/repositories/http_delivery_export_repository.dart';
import 'package:meatshop_mobile/models/delivery_export_model.dart';
import '../../helpers/export_api_fixture.dart';

void main() {
  final request = DeliveryExportRequest(
    report: DeliveryReportType.earnings,
    format: DeliveryExportFormat.pdf,
    from: DateTime(2026, 11, 1),
    to: DateTime(2026, 11, 30),
  );
  test(
    'downloads a PDF using session ownership, without user, unit or pagination parameters',
    () async {
      final fixture = ExportApiFixture(
        MockClient((call) async {
          expect(call.url.path, '/delivery/me/exports');
          expect(call.url.queryParameters, {
            'report': 'earnings',
            'format': 'pdf',
            'from': '2026-11-01',
            'to': '2026-11-30',
            'payment': 'all',
          });
          expect(call.headers['authorization'], contains('Bearer '));
          expect(call.headers['x-client-platform'], 'mobile');
          return http.Response.bytes(
            utf8.encode('%PDF-test'),
            200,
            headers: {'content-type': 'application/pdf'},
          );
        }),
      );
      final file = await HttpDeliveryExportRepository(
        fixture.client,
      ).export(request);
      expect(utf8.decode(file.bytes), '%PDF-test');
      expect(file.fileName, 'meatshop-entregador-ganhos.pdf');
    },
  );
  test(
    'refreshes an expired session and retries the binary download once',
    () async {
      var calls = 0;
      final fixture = ExportApiFixture(
        MockClient((call) async {
          calls++;
          if (call.headers['authorization']!.endsWith('.original')) {
            return http.Response('{"message":"Unauthorized"}', 401);
          }
          return http.Response.bytes([80, 75, 3, 4, 0, 0], 200);
        }),
      );
      final file = await HttpDeliveryExportRepository(fixture.client).export(
        const DeliveryExportRequest(
          report: DeliveryReportType.personal,
          format: DeliveryExportFormat.xlsx,
        ),
      );
      expect(file.fileName, 'meatshop-entregador-dados-pessoais.xlsx');
      expect(fixture.refresher.calls, 1);
      expect(calls, 2);
    },
  );
  test(
    'localizes server export errors without treating them as files',
    () async {
      final fixture = ExportApiFixture(
        MockClient(
          (_) async => http.Response(
            '{"code":"EXPORT_TOO_LARGE","message":"database detail"}',
            413,
          ),
        ),
      );
      await expectLater(
        HttpDeliveryExportRepository(fixture.client).export(request),
        throwsA(
          isA<ApiFailure>().having(
            (failure) => failure.message,
            'friendly message',
            contains('Reduza o período'),
          ),
        ),
      );
    },
  );
  test('rejects invalid binary files and pre-cancelled requests', () async {
    var calls = 0;
    final fixture = ExportApiFixture(
      MockClient((_) async {
        calls++;
        return http.Response('<html>error</html>', 200);
      }),
    );
    final repo = HttpDeliveryExportRepository(fixture.client);
    await expectLater(
      repo.export(request),
      throwsA(
        isA<ApiFailure>().having(
          (failure) => failure.code,
          'code',
          'MALFORMED_EXPORT',
        ),
      ),
    );
    final cancellation = CancellationToken()..cancel();
    await expectLater(
      repo.export(request, cancellationToken: cancellation),
      throwsA(
        isA<ApiFailure>().having(
          (failure) => failure.kind,
          'kind',
          ApiFailureKind.cancelled,
        ),
      ),
    );
    expect(calls, 1);
  });
  test('does not return a pending file after the session changes', () async {
    final started = Completer<void>(), response = Completer<http.Response>();
    final fixture = ExportApiFixture(
      MockClient((_) {
        started.complete();
        return response.future;
      }),
    );
    final pending = HttpDeliveryExportRepository(
      fixture.client,
    ).export(request);
    await started.future;
    await fixture.session.clear();
    response.complete(http.Response('%PDF-test', 200));
    await expectLater(
      pending,
      throwsA(
        isA<ApiFailure>().having(
          (failure) => failure.code,
          'code',
          'SESSION_CHANGED',
        ),
      ),
    );
  });
}
