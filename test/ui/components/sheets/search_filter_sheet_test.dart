import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meatshop_mobile/ui/components/sheets/search_filter_sheet.dart';

void main() {
  testWidgets('rejects NaN, infinite and negative prices', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SearchFilterSheet(
            categories: [],
            brands: [],
            selectedCategory: null,
            selectedBrand: null,
            minPrice: null,
            maxPrice: null,
          ),
        ),
      ),
    );
    for (final value in ['NaN', 'Infinity', '-1']) {
      await tester.enterText(find.byType(TextField).first, value);
      await tester.tap(find.text('Aplicar filtros'));
      await tester.pump();
      expect(find.byType(SearchFilterSheet), findsOneWidget);
      expect(
        find.text('Informe valores v\u00e1lidos e positivos.'),
        findsOneWidget,
      );
    }
  });

  testWidgets('fits a small screen with large text and the keyboard open', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => MediaQuery(
            data: MediaQuery.of(context).copyWith(
              textScaler: TextScaler.linear(1.8),
              viewInsets: const EdgeInsets.only(bottom: 180),
            ),
            child: const Scaffold(
              body: SearchFilterSheet(
                categories: ['Bovinos', 'Aves'],
                brands: ['Swift', 'Friboi'],
                selectedCategory: null,
                selectedBrand: null,
                minPrice: null,
                maxPrice: null,
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.text('Aplicar filtros'), findsOneWidget);
  });

  testWidgets('returns category, brand, and price filters together', (
    tester,
  ) async {
    SearchFilterSelection? result;
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(splashFactory: NoSplash.splashFactory),
        home: Scaffold(
          body: Builder(
            builder: (context) => FilledButton(
              onPressed: () async {
                result = await SearchFilterSheet.show(
                  context,
                  categories: const ['Bovinos'],
                  brands: const ['Friboi'],
                  selectedCategory: null,
                  selectedBrand: null,
                  minPrice: null,
                  maxPrice: null,
                );
              },
              child: const Text('Abrir'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Abrir'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilterChip, 'Bovinos'));
    await tester.tap(find.widgetWithText(FilterChip, 'Friboi'));
    await tester.enterText(find.byType(TextField).at(0), '30,50');
    await tester.enterText(find.byType(TextField).at(1), '100');
    await tester.tap(find.text('Aplicar filtros'));
    await tester.pumpAndSettle();

    expect(result?.category, 'Bovinos');
    expect(result?.brand, 'Friboi');
    expect(result?.minPrice, 30.5);
    expect(result?.maxPrice, 100);
  });

  testWidgets('does not apply an inverted price range', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(splashFactory: NoSplash.splashFactory),
        home: Scaffold(
          body: Builder(
            builder: (context) => FilledButton(
              onPressed: () => SearchFilterSheet.show(
                context,
                categories: const [],
                brands: const [],
                selectedCategory: null,
                selectedBrand: null,
                minPrice: null,
                maxPrice: null,
              ),
              child: const Text('Abrir'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Abrir'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).at(0), '101');
    await tester.enterText(find.byType(TextField).at(1), '100');
    await tester.tap(find.text('Aplicar filtros'));
    await tester.pump();

    expect(
      find.text('O preço mínimo não pode superar o máximo.'),
      findsOneWidget,
    );
    expect(find.byType(SearchFilterSheet), findsOneWidget);
  });
}
