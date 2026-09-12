import 'package:flutter_test/flutter_test.dart';
import 'package:meatshop_mobile/models/address_model.dart';

void main() {
  test(
    'only a confirmed pin is serialized as a manually selected coordinate',
    () {
      final approximate = AddressModel.fromApi({
        'latitude': '-23.5',
        'longitude': '-46.6',
        'coordinate_source': 'POSTAL_CODE',
      });
      expect(approximate.toApi().containsKey('latitude'), false);
      final pin = approximate.copyWith(coordinateSource: 'USER_PIN');
      expect(pin.toApi()['latitude'], -23.5);
      expect(pin.toApi()['longitude'], -46.6);
    },
  );
}
