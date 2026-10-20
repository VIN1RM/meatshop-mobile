import 'package:flutter_test/flutter_test.dart';
import 'package:meatshop_mobile/core/utils/product_quantity.dart';

void main() {
  test(
    'converts weights to the catalog unit without changing unit products',
    () {
      expect(ProductQuantity.inUnit(300, 'KG', grams: true), .3);
      expect(ProductQuantity.inUnit(.3, 'G', grams: false), 300);
      expect(ProductQuantity.inUnit(2, 'UN', grams: true), 2);
      expect(ProductQuantity.inUnit(3, 'PCT', grams: false), 3);
    },
  );
  test('counts packages and units as integers and accepts decimal weights', () {
    expect(ProductQuantity.valid(.5, 'UN'), false);
    expect(ProductQuantity.valid(.5, 'PCT'), false);
    expect(ProductQuantity.valid(.05, 'kg'), true);
    expect(ProductQuantity.valid(double.infinity, 'KG'), false);
    expect(ProductQuantity.valid(0, 'G'), false);
  });
  test('normalizes units and Brazilian decimal input', () {
    expect(ProductQuantity.step(' KG '), .05);
    expect(ProductQuantity.step('g'), 50);
    expect(ProductQuantity.step('un'), 1);
    expect(ProductQuantity.parse('0,25'), .25);
  });
}
