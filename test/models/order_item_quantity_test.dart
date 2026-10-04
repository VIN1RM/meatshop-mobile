import 'package:flutter_test/flutter_test.dart';
import 'package:meatshop_mobile/models/order_model.dart';

void main() {
  for (final sample in <(String, double, String)>[
    ('KG', 0.1, '100 g'),
    ('kg', 0.05, '50 g'),
    (' Kg ', 0.5, '500 g'),
    ('KG', 1, '1 kg'),
    ('kg', 1.5, '1,5 kg'),
    ('KG', 1.125, '1,125 kg'),
    ('G', 150, '150 g'),
    ('g', 1000, '1000 g'),
    ('UN', 2, '2 un'),
    ('L', 1.5, '1,5 l'),
    ('kg', 0, '0 kg'),
  ]) {
    test('${sample.$2} ${sample.$1} displays ${sample.$3}', () {
      final order = OrderModel.fromApi({
        'items': [
          {
            'product_id': 1,
            'product_name': 'Produto',
            'unit_of_measure': sample.$1,
            'quantity': sample.$2.toString(),
            'unit_price': '15.00',
          },
        ],
      });
      expect(order.items.single.quantityLabel, sample.$3);
    });
  }
}
