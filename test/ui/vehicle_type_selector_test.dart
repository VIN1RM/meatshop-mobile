import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meatshop_mobile/ui/widgets/vehicle_type_selector.dart';

void main() {
  testWidgets('aligns all three choices and emits the canonical type on tap', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(400, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    String? selected;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Padding(
            padding: const EdgeInsets.all(24),
            child: VehicleTypeSelector(
              selectedValue: 'CAR',
              onSelected: (value) => selected = value,
            ),
          ),
        ),
      ),
    );
    final moto = tester.getCenter(find.text('Moto'));
    final car = tester.getCenter(find.text('Carro'));
    final bike = tester.getCenter(find.text('Bicicleta'));
    expect(moto.dy, car.dy);
    expect(car.dy, bike.dy);
    expect(moto.dx, lessThan(car.dx));
    expect(car.dx, lessThan(bike.dx));
    await tester.tap(find.text('Bicicleta'));
    expect(selected, 'BIKE');
    expect(tester.takeException(), isNull);
  });

  testWidgets('keeps all options visible with large text on a narrow screen', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(
        home: MediaQuery(
          data: const MediaQueryData(textScaler: TextScaler.linear(2)),
          child: Scaffold(
            body: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: VehicleTypeSelector(
                  selectedValue: null,
                  onSelected: (_) {},
                ),
              ),
            ),
          ),
        ),
      ),
    );
    expect(
      tester.getCenter(find.text('Moto')).dy,
      lessThan(tester.getCenter(find.text('Carro')).dy),
    );
    expect(
      tester.getCenter(find.text('Carro')).dy,
      lessThan(tester.getCenter(find.text('Bicicleta')).dy),
    );
    await tester.tap(find.text('Bicicleta'));
    expect(tester.takeException(), isNull);
  });
}
