import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meatshop_mobile/ui/widgets/checkout_coupon_field.dart';

void main() {
  testWidgets(
    'editing an applied coupon hides stale success and requires explicit application',
    (tester) async {
      String? submitted;
      bool dirty = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CheckoutCouponField(
              code: 'BEMVINDO10',
              busy: false,
              discount: 10,
              onApply: (value) => submitted = value,
              onDraftChanged: (value) => dirty = value,
            ),
          ),
        ),
      );
      expect(find.textContaining('Cupom aplicado!'), findsOneWidget);
      await tester.enterText(find.byType(TextField), ' OUTRO ');
      await tester.pump();
      expect(dirty, isTrue);
      expect(submitted, isNull);
      expect(find.textContaining('Cupom aplicado!'), findsNothing);
      await tester.tap(find.text('Aplicar cupom'));
      expect(submitted, 'OUTRO');
      expect(dirty, isFalse);
    },
  );

  testWidgets('removing an applied coupon submits an empty code', (
    tester,
  ) async {
    String? submitted;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: CheckoutCouponField(
            code: 'BEMVINDO10',
            busy: false,
            discount: 10,
            onApply: (value) => submitted = value,
            onDraftChanged: (_) {},
          ),
        ),
      ),
    );
    await tester.enterText(find.byType(TextField), '');
    await tester.pump();
    await tester.tap(find.text('Remover cupom'));
    expect(submitted, '');
    expect(find.textContaining('Cupom aplicado!'), findsNothing);
  });
}
