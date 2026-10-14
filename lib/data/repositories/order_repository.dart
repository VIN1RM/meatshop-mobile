import '../../models/checkout_summary_model.dart';
import '../../models/order_model.dart';
import '../../models/cart_item_model.dart';

final class CheckoutQuoteGroup {
  const CheckoutQuoteGroup({
    required this.unitId,
    required this.subtotal,
    required this.discountAmount,
    required this.deliveryFee,
    required this.totalAmount,
    this.items = const [],
  });

  final List<CartItemModel> items;
  final String unitId;
  final double subtotal;
  final double discountAmount;
  final double deliveryFee;
  final double totalAmount;
}

final class CheckoutQuote {
  const CheckoutQuote({
    required this.groups,
    required this.totalAmount,
    this.token,
    this.expiresAt,
  });
  final String? token;
  final DateTime? expiresAt;
  final List<CheckoutQuoteGroup> groups;
  final double totalAmount;
}

final class CheckoutResult {
  const CheckoutResult({
    required this.checkoutId,
    required this.orders,
    required this.totalAmount,
    this.recovered = false,
  });
  final bool recovered;
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
  Future<String> createPayment(String orderId);
  Future<bool> onlinePaymentsAvailable();
  Future<void> reconcilePayment(String orderId);
  Future<List<OrderModel>> list();
  Future<OrderModel> get(String orderId);
  Future<OrderModel> cancel(String orderId, String reason);
  Future<OrderModel> schedule(String orderId, DateTime date);
  Future<List<String>> repeat(String orderId);
}

abstract interface class CheckoutRecovery {
  Future<CheckoutResult?> recoverPending();
}

abstract interface class CheckoutCapabilities {
  Future<Map<String, bool>> paymentAvailability(List<String> units);
}
