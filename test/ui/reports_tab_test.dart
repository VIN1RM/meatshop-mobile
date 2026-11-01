import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:meatshop_mobile/models/delivery_export_model.dart';
import 'package:meatshop_mobile/providers/auth/auth_provider.dart';
import 'package:meatshop_mobile/ui/dialogs/delivery_export/delivery_export_dialog.dart';
import '../helpers/delivery_export_fakes.dart';

void main() {
  testWidgets('offers only Excel/PDF without user or unit selection', (
    tester,
  ) async {
    final repo = FakeDeliveryExportRepository();
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: DeliveryExportDialog(repository: repo, isAllowed: () => true),
        ),
      ),
    );
    await tester.tap(find.text('Excel (.xlsx)'));
    await tester.pumpAndSettle();
    expect(find.text('PDF (.pdf)'), findsOneWidget);
    expect(find.textContaining('JSON'), findsNothing);
    expect(find.textContaining('CSV'), findsNothing);
    expect(find.text('Unidade'), findsNothing);
  });
  testWidgets('shows a safe failure and enables retry for download errors', (
    tester,
  ) async {
    final repo = FakeDeliveryExportRepository()
      ..failure = Exception('FileSystemException: /private/report.pdf');
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: DeliveryExportDialog(
            repository: repo,
            isAllowed: () => true,
            from: DateTime(2026, 11, 1),
            to: DateTime(2026, 11, 30),
          ),
        ),
      ),
    );
    await tester.ensureVisible(find.text('Gerar e compartilhar'));
    await tester.tap(find.text('Gerar e compartilhar'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Tente novamente'), findsOneWidget);
    expect(find.textContaining('FileSystemException'), findsNothing);
    await tester.ensureVisible(find.text('Gerar e compartilhar'));
    await tester.tap(find.text('Gerar e compartilhar'));
    await tester.pumpAndSettle();
    expect(repo.calls, 2);
  });
  testWidgets(
    'personal export has no date filter and uses the personal report',
    (tester) async {
      final repo = FakeDeliveryExportRepository();
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DeliveryExportDialog(
              repository: repo,
              isAllowed: () => true,
              report: DeliveryReportType.personal,
              shareFile: (_, _) async => true,
            ),
          ),
        ),
      );
      expect(find.textContaining('De:'), findsNothing);
      expect(find.textContaining('Até:'), findsNothing);
      await tester.tap(find.text('Gerar e compartilhar'));
      await tester.pumpAndSettle();
      expect(repo.lastRequest!.toQuery(), {
        'report': 'personal',
        'format': 'xlsx',
      });
    },
  );
  testWidgets('does not open the export dialog for a client profile', (
    tester,
  ) async {
    await tester.pumpWidget(
      ChangeNotifierProvider<AuthProvider>.value(
        value: _ClientAuth(),
        child: MaterialApp(
          home: Builder(
            builder: (context) => TextButton(
              onPressed: () => DeliveryExportDialog.show(context),
              child: const Text('Abrir'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Abrir'));
    await tester.pumpAndSettle();
    expect(find.text('Exportar relatório pessoal'), findsNothing);
  });
}

class _ClientAuth extends ChangeNotifier implements AuthProvider {
  @override
  bool get isDelivery => false;
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
