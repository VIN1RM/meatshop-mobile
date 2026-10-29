import 'package:flutter_test/flutter_test.dart';
import 'package:meatshop_mobile/core/enums/vehicle_type.dart';
import 'package:meatshop_mobile/services/vehicle_registration_service.dart';

void main() {
  test('exposes only Moto, Carro and Bicicleta in the API contract', () {
    expect(VehicleType.values.map((value) => value.apiValue), [
      'MOTORCYCLE',
      'CAR',
      'BIKE',
    ]);
    expect(VehicleType.values.map((value) => value.label), [
      'Moto',
      'Carro',
      'Bicicleta',
    ]);
    for (final type in VehicleType.values) {
      expect(VehicleRegistrationService.type(type.label), type.apiValue);
      expect(VehicleRegistrationService.type(type.apiValue), type.apiValue);
    }
  });
  for (final value in [
    'SCOOTER',
    'Patinete',
    'ON_FOOT',
    'A pé',
    'CARPET',
    '',
  ]) {
    test(
      'rejects unsupported type $value without silently converting it to Moto',
      () {
        expect(VehicleType.tryParse(value), isNull);
        expect(
          () => VehicleRegistrationService.type(value),
          throwsArgumentError,
        );
      },
    );
  }
}
