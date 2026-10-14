import 'package:flutter_test/flutter_test.dart';
import 'package:meatshop_mobile/core/utils/payment_return_intent.dart';

void main() {
  test(
    'retains the order until authentication and never interprets payment success from a link',
    () {
      final intent = PaymentReturnIntent();
      intent.remember(
        Uri.parse('meatshop://payments?order_id=42&payment=success'),
      );
      expect(intent.pending, isTrue);
      expect(intent.take(), ['42']);
      expect(intent.take(), isNull);
      intent.remember(Uri.parse('meatshop://payments?order_id=invalid'));
      expect(intent.take(), isEmpty);
      intent.remember(
        Uri.parse('https://attacker.invalid/payments?order_id=42'),
      );
      expect(intent.pending, isFalse);
    },
  );
}
