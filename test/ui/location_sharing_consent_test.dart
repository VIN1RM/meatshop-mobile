import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meatshop_mobile/ui/screens/delivery/location_sharing_consent.dart';

void main() {
  for (final allow in [false, true]) {
    testWidgets(
      'consent remains readable and returns $allow on a small screen',
      (tester) async {
        tester.view.physicalSize = const Size(320, 480);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        bool? result;
        await tester.pumpWidget(
          MaterialApp(
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(
                context,
              ).copyWith(textScaler: const TextScaler.linear(1.5)),
              child: child!,
            ),
            home: Scaffold(
              body: Builder(
                builder: (context) => TextButton(
                  onPressed: () async {
                    result = await showDialog<bool>(
                      context: context,
                      builder: (_) =>
                          const LocationSharingConsentDialog(retentionDays: 30),
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
        expect(find.textContaining('30 dias'), findsOneWidget);
        expect(find.textContaining('Sem conex'), findsOneWidget);
        final action = find.text(
          allow ? 'Permitir compartilhamento' : 'Agora não',
        );
        await tester.ensureVisible(action);
        await tester.tap(action);
        await tester.pumpAndSettle();
        expect(result, allow);
        expect(tester.takeException(), isNull);
      },
    );
  }
}
