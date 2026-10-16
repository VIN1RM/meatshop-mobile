import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meatshop_mobile/ui/screens/account/saved_payments_screen.dart';

void main() {
  testWidgets(
    'payment information fits a small screen with large text and uses the app design',
    (tester) async {
      tester.view.physicalSize = const Size(320, 640);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        MaterialApp(
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: const TextScaler.linear(1.4)),
            child: child!,
          ),
          home: const SavedPaymentsScreen(),
        ),
      );
      expect(find.text('FORMAS DE PAGAMENTO'), findsOneWidget);
      expect(find.text('Pagamento seguro'), findsOneWidget);
      expect(
        tester.widget<Scaffold>(find.byType(Scaffold)).backgroundColor,
        const Color(0xFF2E2E2E),
      );
      expect(tester.takeException(), isNull);
    },
  );
}
