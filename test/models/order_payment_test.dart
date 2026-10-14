import 'package:flutter_test/flutter_test.dart';
import 'package:meatshop_mobile/models/order_model.dart';

Map<String, dynamic> data({
  String status = 'PENDING',
  String payment = 'PENDING',
  String method = 'Pix',
  DateTime? deadline,
}) => {
  'id': 1,
  'client_id': 2,
  'unit_id': 3,
  'address_id': 4,
  'status': status,
  'payment_status': payment,
  'payment': {'method': method},
  'payment_due_at':
      (deadline ?? DateTime.now().add(const Duration(minutes: 15)))
          .toIso8601String(),
  'items': <Object?>[],
};
void main() {
  test('only an unexpired online pending order offers another payment', () {
    expect(OrderModel.fromApi(data()).canPay, isTrue);
    expect(OrderModel.fromApi(data(payment: 'REJECTED')).canPay, isTrue);
    for (final state in [
      'PAID',
      'REFUNDED',
      'PARTIALLY_REFUNDED',
      'CHARGED_BACK',
    ]) {
      expect(OrderModel.fromApi(data(payment: state)).canPay, isFalse);
    }
    expect(OrderModel.fromApi(data(status: 'CANCELLED')).canPay, isFalse);
    expect(OrderModel.fromApi(data(deadline: DateTime(2000))).canPay, isFalse);
    expect(OrderModel.fromApi(data(method: 'Cash')).canPay, isFalse);
    expect(
      OrderModel.fromApi(data(method: 'Card on Delivery')).canPay,
      isFalse,
    );
  });
  test(
    'pending offline receipts and requested refunds are never described as paid',
    () {
      expect(
        OrderModel.fromApi(data(method: 'Cash')).paymentStatusLabel,
        'A pagar na entrega',
      );
      final refund = data(payment: 'PAID');
      refund['payment'] = {
        'method': 'Pix',
        'refund_status': 'PENDING',
        'refunded_amount': 0,
      };
      expect(
        OrderModel.fromApi(refund).paymentStatusLabel,
        'Estorno solicitado',
      );
    },
  );
}
