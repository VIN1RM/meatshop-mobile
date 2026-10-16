import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meatshop_mobile/ui/components/sheets/vehicle_edit_sheet.dart';

void main() {
  testWidgets(
    'opens API vehicles with an integer year and handles the keyboard on a small screen',
    (tester) async {
      tester.view.physicalSize = const Size(320, 640);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MediaQuery(
              data: const MediaQueryData(
                size: Size(320, 640),
                viewInsets: EdgeInsets.only(bottom: 280),
              ),
              child: const VehicleEditModal(
                vehicleType: 'CAR',
                persistChanges: false,
                initialData: {
                  'model': 'Carro',
                  'plate': 'ABC1234',
                  'color': 'Preto',
                  'year': 2026,
                },
              ),
            ),
          ),
        ),
      );
      await tester.pump();
      expect(find.text('2026'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}
