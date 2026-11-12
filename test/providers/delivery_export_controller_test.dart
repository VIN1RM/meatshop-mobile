import 'dart:async';
import 'dart:ui';
import 'package:flutter_test/flutter_test.dart';
import 'package:meatshop_mobile/core/network/api_failure.dart';
import 'package:meatshop_mobile/models/delivery_export_model.dart';
import 'package:meatshop_mobile/providers/delivery_export_controller.dart';
import 'package:meatshop_mobile/services/report_export_service.dart';
import '../helpers/delivery_export_fakes.dart';

void main() {
  const origin = Rect.fromLTWH(1, 1, 100, 100);
  final request = DeliveryExportRequest(
    report: DeliveryReportType.earnings,
    format: DeliveryExportFormat.pdf,
    from: DateTime(2026, 11, 1),
    to: DateTime(2026, 11, 30),
  );
  test('prevents duplicate requests while generating a file', () async {
    final repo = FakeDeliveryExportRepository()..pending = Completer();
    var shares = 0;
    final controller = DeliveryExportController(
      repository: repo,
      isAllowed: () => true,
      shareFile: (_, _) async {
        shares++;
        return DeliveryShareOutcome.success;
      },
    );
    final running = controller.export(request, origin);
    await controller.export(request, origin);
    expect(repo.calls, 1);
    expect(controller.busy, isTrue);
    repo.pending!.complete(repo.file);
    await running;
    expect(shares, 1);
    expect(controller.busy, isFalse);
    controller.dispose();
  });
  test('does not share a file after switching accounts or profiles', () async {
    for (final changeAccount in [true, false]) {
      final repo = FakeDeliveryExportRepository()..pending = Completer();
      var allowed = true;
      var shares = 0;
      final controller = DeliveryExportController(
        repository: repo,
        isAllowed: () => allowed,
        shareFile: (_, _) async {
          shares++;
          return DeliveryShareOutcome.success;
        },
      );
      final running = controller.export(request, origin);
      if (changeAccount) {
        repo.accountId = '8';
      } else {
        allowed = false;
      }
      repo.pending!.complete(repo.file);
      await running;
      expect(shares, 0);
      controller.dispose();
    }
  });
  test(
    'cancels on disposal and suppresses notifications and sharing',
    () async {
      final repo = FakeDeliveryExportRepository()..pending = Completer();
      var shares = 0;
      final controller = DeliveryExportController(
        repository: repo,
        isAllowed: () => true,
        shareFile: (_, _) async {
          shares++;
          return DeliveryShareOutcome.success;
        },
      );
      final running = controller.export(request, origin);
      controller.dispose();
      expect(repo.lastCancellation!.isCancelled, isTrue);
      repo.pending!.complete(repo.file);
      await running;
      expect(shares, 0);
    },
  );
  test(
    'shows a safe message for native sharing errors and permits retrying',
    () async {
      final repo = FakeDeliveryExportRepository();
      var fail = true;
      final controller = DeliveryExportController(
        repository: repo,
        isAllowed: () => true,
        shareFile: (_, _) async {
          if (fail) throw Exception('/private/device/file.pdf');
          return DeliveryShareOutcome.success;
        },
      );
      await controller.export(request, origin);
      expect(controller.error, contains('Tente novamente'));
      expect(controller.error, isNot(contains('/private')));
      fail = false;
      await controller.export(request, origin);
      expect(controller.error, isNull);
      expect(controller.status, contains('enviado para compartilhamento'));
      controller.dispose();
    },
  );
  test('distinguishes cancelled and unavailable native sharing', () async {
    final repo = FakeDeliveryExportRepository();
    var outcome = DeliveryShareOutcome.dismissed;
    final controller = DeliveryExportController(
      repository: repo,
      isAllowed: () => true,
      shareFile: (_, _) async => outcome,
    );
    await controller.export(request, origin);
    expect(controller.status, contains('cancelado'));
    expect(controller.error, isNull);

    outcome = DeliveryShareOutcome.unavailable;
    await controller.export(request, origin);
    expect(controller.status, isNull);
    expect(controller.error, contains('não está disponível'));
    controller.dispose();
  });
  test(
    'preserves friendly API messages and validates reversed dates before sending',
    () async {
      final repo = FakeDeliveryExportRepository()
        ..failure = const ApiFailure(
          kind: ApiFailureKind.forbidden,
          message: 'Somente entregadores podem exportar.',
          code: 'DELIVERY_EXPORT_FORBIDDEN',
        );
      final controller = DeliveryExportController(
        repository: repo,
        isAllowed: () => true,
      );
      await controller.export(request, origin);
      expect(controller.error, 'Somente entregadores podem exportar.');
      await controller.export(
        DeliveryExportRequest(
          report: DeliveryReportType.earnings,
          format: DeliveryExportFormat.pdf,
          from: DateTime(2026, 11, 30),
          to: DateTime(2026, 11, 1),
        ),
        origin,
      );
      expect(repo.calls, 1);
      expect(controller.error, contains('data inicial'));
      controller.dispose();
    },
  );
}
