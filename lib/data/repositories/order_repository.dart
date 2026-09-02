import '../../models/checkout_summary_model.dart';
import '../../models/order_model.dart';

final class CheckoutQuoteGroup {
  const CheckoutQuoteGroup({
    required this.unitId,
    required this.subtotal,
    required this.discountAmount,
    required this.deliveryFee,
    required this.totalAmount,
  });

  final String unitId;
  final double subtotal;
  final double discountAmount;
  final double deliveryFee;
  final double totalAmount;
}

final class CheckoutQuote {
  const CheckoutQuote({required this.groups, required this.totalAmount});
  final List<CheckoutQuoteGroup> groups;
  final double totalAmount;
}

final class CheckoutResult {
  const CheckoutResult({
    required this.checkoutId,
    required this.orders,
    required this.totalAmount,
  });
  final String checkoutId;
  final List<OrderModel> orders;
  final double totalAmount;
}

abstract interface class OrderRepository {
  Future<CheckoutQuote> quote(CheckoutSummaryModel summary);
  Future<CheckoutResult> create(
    CheckoutSummaryModel summary, {
    required String idempotencyKey,
  });
  Future<String> createPayment(String checkoutId);
  Future<List<OrderModel>> list();
  Future<OrderModel> get(String orderId);
  Future<OrderModel> cancel(String orderId, String reason);
  Future<OrderModel> schedule(String orderId, DateTime date);
  Future<CheckoutResult> repeat(String orderId);
}
