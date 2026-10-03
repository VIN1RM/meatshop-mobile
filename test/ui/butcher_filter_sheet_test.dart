import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meatshop_mobile/ui/components/sheets/butcher_filter_sheet.dart';

void main() {
  for (final size in [const Size(390, 844), const Size(320, 480)]) {
    testWidgets('filter sheet lays out, scrolls and applies on $size', (
      tester,
    ) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      ButcherFilter? result;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => TextButton(
                onPressed: () async {
                  result = await ButcherFilterSheet.show(
                    context,
                    const ButcherFilter(),
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
      expect(tester.takeException(), isNull);
      await tester.tap(find.text('Apenas abertos agora'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Mais próximos'));
      await tester.tap(find.text('Mais próximos'));
      await tester.ensureVisible(find.text('Aplicar Filtro'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Aplicar Filtro'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(result?.openNowOnly, isTrue);
      expect(result?.sortOrder, ButcherSortOrder.distanceAscending);
    });
  }
}
