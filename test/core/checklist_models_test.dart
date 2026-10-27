import 'package:flutter_test/flutter_test.dart';
import 'package:meatshop_mobile/models/checkout_summary_model.dart';
import 'package:meatshop_mobile/models/product_model.dart';
import 'package:meatshop_mobile/models/support_ticket_model.dart';

void main() {
  test(
    'pickup selections survive quote copies and mixed orders require delivery',
    () {
      const pickup = CheckoutSummaryModel(
        addressId: '',
        isScheduled: false,
        paymentMethod: 'cash',
        unitDeliveryTypes: {'1': 'PICKUP'},
      );
      expect(pickup.copyWith(total: 10).pickupOnly, isTrue);
      const mixed = CheckoutSummaryModel(
        addressId: '1',
        isScheduled: false,
        paymentMethod: 'cash',
        unitDeliveryTypes: {'1': 'PICKUP', '2': 'DELIVERY'},
      );
      expect(mixed.pickupOnly, isFalse);
    },
  );
  test('stock retains fractions and optional contact is returned', () {
    expect(
      ProductModel.fromMap({
        'stock': {'quantity': 0.5},
      }, '1').stockQuantity,
      0.5,
    );
    final ticket = SupportTicketModel.fromJson({
      'id': 1,
      'subject': 'Support',
      'status': 'OPEN',
      'contact': 'phone',
    });
    expect(ticket.contact, 'phone');
  });
}
