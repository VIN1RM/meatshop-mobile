import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:meatshop_mobile/data/repositories/delivery_expense_repository.dart';
import 'package:meatshop_mobile/models/delivery_expense_model.dart';
import 'package:meatshop_mobile/ui/screens/delivery/expenses_screen.dart';

class _Expenses implements DeliveryExpenseRepository {
  int saves = 0;
  double? savedAmount;
  @override
  Future<DeliveryExpensePage> list({
    required String from,
    required String to,
    int page = 1,
  }) async => const DeliveryExpensePage(items: [], total: 0, totalAmount: 0);
  @override
  Future<void> save({
    int? id,
    required String category,
    required String description,
    required double amount,
    required String date,
  }) async {
    saves++;
    savedAmount = amount;
  }

  @override
  Future<void> remove(int id) async {}
}

void main() {
  testWidgets('Expenses form remains accessible with large text and keyboard', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      Provider<DeliveryExpenseRepository>.value(
        value: _Expenses(),
        child: MaterialApp(
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context).copyWith(
              textScaler: TextScaler.linear(1.8),
              viewInsets: const EdgeInsets.only(bottom: 240),
            ),
            child: child!,
          ),
          home: const ExpensesScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Nova despesa'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('Salvar despesa'),
      180,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets('rejects invalid monetary values without sending an expense', (
    tester,
  ) async {
    final repository = _Expenses();
    await tester.pumpWidget(
      Provider<DeliveryExpenseRepository>.value(
        value: repository,
        child: const MaterialApp(home: ExpensesScreen()),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Nova despesa'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).at(0), 'Combustivel');
    for (final value in ['-1', 'NaN', 'Infinity', '1,234']) {
      await tester.enterText(find.byType(TextFormField).at(1), value);
      await tester.ensureVisible(find.text('Salvar despesa'));
      await tester.tap(find.text('Salvar despesa'));
      await tester.pumpAndSettle();
      expect(repository.saves, 0);
      expect(find.textContaining('Informe um valor positivo'), findsOneWidget);
    }
    expect(tester.takeException(), isNull);
  });
  testWidgets(
    'saves a formatted Brazilian amount using the same parser as validation',
    (tester) async {
      final repository = _Expenses();
      await tester.pumpWidget(
        Provider<DeliveryExpenseRepository>.value(
          value: repository,
          child: const MaterialApp(home: ExpensesScreen()),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Nova despesa'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextFormField).at(0), 'Combustível');
      await tester.enterText(find.byType(TextFormField).at(1), '1.234,56');
      await tester.ensureVisible(find.text('Salvar despesa'));
      await tester.tap(find.text('Salvar despesa'));
      await tester.pumpAndSettle();
      expect(repository.saves, 1);
      expect(repository.savedAmount, 1234.56);
      expect(tester.takeException(), isNull);
    },
  );
}
