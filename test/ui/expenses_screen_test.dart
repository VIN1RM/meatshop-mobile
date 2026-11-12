import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:meatshop_mobile/data/repositories/delivery_expense_repository.dart';
import 'package:meatshop_mobile/models/delivery_expense_model.dart';
import 'package:meatshop_mobile/ui/screens/delivery/expenses_screen.dart';

class _Expenses implements DeliveryExpenseRepository {
  int saves = 0;
  final List<DeliveryExpenseModel> items = [];
  int removes = 0;
  double? savedAmount;
  @override
  Future<DeliveryExpensePage> list({
    required String from,
    required String to,
    int page = 1,
  }) async => DeliveryExpensePage(
    items: List.of(items),
    total: items.length,
    totalAmount: items.fold<double>(0, (sum, item) => sum + item.amount),
  );
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
  Future<void> remove(int id) async {
    removes++;
    items.removeWhere((item) => item.id == id);
  }
}

void main() {
  setUpAll(() => initializeDateFormatting('pt_BR'));
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
  testWidgets(
    'populated expenses remain usable on a narrow screen and require confirmation to delete',
    (tester) async {
      tester.view.physicalSize = const Size(320, 640);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final repository = _Expenses()
        ..items.add(
          DeliveryExpenseModel(
            id: 1,
            category: 'FUEL',
            description: 'Abastecimento para entregas da semana',
            amount: 123.45,
            date: DateTime(2026, 11, 1),
          ),
        );
      await tester.pumpWidget(
        Provider<DeliveryExpenseRepository>.value(
          value: repository,
          child: MaterialApp(
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(
                context,
              ).copyWith(textScaler: TextScaler.linear(1.5)),
              child: child!,
            ),
            home: const ExpensesScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        find.widgetWithIcon(IconButton, Icons.delete_outline),
        160,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithIcon(IconButton, Icons.delete_outline));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Cancelar'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cancelar'));
      await tester.pumpAndSettle();
      expect(repository.removes, 0);
      await tester.tap(find.widgetWithIcon(IconButton, Icons.delete_outline));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Excluir despesa').last);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Excluir despesa').last);
      await tester.pumpAndSettle();
      expect(repository.removes, 1);
      expect(find.text('Nenhuma despesa neste mês'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}
