import 'package:flutter_test/flutter_test.dart';
import 'package:meatshop_mobile/core/utils/unit_price_order.dart';
import 'package:meatshop_mobile/models/unit_model.dart';

UnitModel unit(String id, double? price) => UnitModel(
  id: id,
  name: id,
  cnpj: '',
  street: '',
  number: '',
  neighborhood: '',
  city: '',
  state: '',
  zipCode: '',
  adminId: '',
  imageUrl: '',
  createdAt: DateTime(2026),
  averagePricePerKg: price,
);
void main() {
  test(
    'sorts comparable prices with missing values last in both directions',
    () {
      final values = [
        unit('missing', null),
        unit('expensive', 100),
        unit('cheap', 20),
      ];
      values.sort(compareUnitPrice);
      expect(values.map((value) => value.id), [
        'cheap',
        'expensive',
        'missing',
      ]);
      values.sort((a, b) => compareUnitPrice(a, b, descending: true));
      expect(values.map((value) => value.id), [
        'expensive',
        'cheap',
        'missing',
      ]);
    },
  );
}
