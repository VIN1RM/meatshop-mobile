import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meatshop_mobile/data/repositories/delivery_repository.dart';
import 'package:meatshop_mobile/models/delivery_earnings_model.dart';
import 'package:meatshop_mobile/models/delivery_goal_model.dart';
import 'package:meatshop_mobile/providers/delivery_earnings_provider.dart';
import 'package:meatshop_mobile/ui/components/tabs/reports_tab.dart';

class _EmptyEarnings extends Fake implements DeliveryRepository {
  @override
  Future<List<DeliveryEarningModel>> earnings() async => [];

  @override
  Future<List<DeliveryGoalModel>> goals() async => [];
}

void main() {
  testWidgets(
    'shows a friendly message without technical details when PDF export fails',
    (tester) async {
      const technicalDetail =
          'FileSystemException: Cannot open file, path = /data/user/0/report.pdf';
      final provider = DeliveryEarningsProvider(repository: _EmptyEarnings());
      Future<void> failingExport({
        required String period,
        required List<DeliveryEarningModel> earnings,
        required Map<String, String> summary,
      }) => Future<void>.error(const FileSystemFailure(technicalDetail));

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ReportsTab(
              period: 'Mensal',
              onPeriodChanged: (_) {},
              earningsProvider: provider,
              exportPdf: failingExport,
            ),
          ),
        ),
      );
      await tester.tap(find.text('Exportar relatório'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Exportar como PDF'));
      await tester.pumpAndSettle();

      expect(find.text(ReportsTab.pdfExportFailureMessage), findsOneWidget);
      expect(find.textContaining('FileSystemException'), findsNothing);
      provider.dispose();
    },
  );
}

class FileSystemFailure implements Exception {
  const FileSystemFailure(this.message);

  final String message;

  @override
  String toString() => message;
}
