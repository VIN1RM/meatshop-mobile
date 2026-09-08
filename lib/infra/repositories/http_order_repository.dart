import '../../core/network/api_failure.dart';
import '../../data/repositories/order_repository.dart';
import '../../models/checkout_summary_model.dart';
import '../../models/order_model.dart';
import '../http/api_client.dart';

final class HttpOrderRepository implements OrderRepository {
  HttpOrderRepository(this._client);
  final ApiClient _client;

  @override
  Future<CheckoutQuote> quote(CheckoutSummaryModel summary) => _client.post(
    '/cart/quote',
    body: _checkoutBody(summary),
    decode: _decodeQuote,
  );

  @override
  Future<CheckoutResult> create(
    CheckoutSummaryModel summary, {
    required String idempotencyKey,
  }) => _client.post(
    '/orders',
    body: _checkoutBody(summary),
    headers: {'idempotency-key': idempotencyKey},
    decode: _decodeCheckout,
  );

  @override
  Future<String> createPayment(String checkoutId) => _client.post(
    '/mercadopago/checkouts/$checkoutId/checkout',
    decode: (value) {
      final map = _map(value);
      final url = map['checkoutUrl'] ?? map['checkout_url'];
      if (url is! String || url.isEmpty) {
        throw _malformed('MALFORMED_PAYMENT_RESPONSE');
      }
      return url;
    },
  );

  @override
  Future<List<OrderModel>> list() async {
    final summaries = await _client.get<List<Object?>>(
      '/orders',
      decode: (value) =>
          value is List<Object?> ? value : throw _malformed('MALFORMED_ORDERS'),
    );
    return Future.wait(
      summaries.map((value) {
        final id = _map(value)['id'];
        if (id is! num) throw _malformed('MALFORMED_ORDER_ID');
        return get(id.toInt().toString());
      }),
    );
  }

  @override
  Future<OrderModel> get(String orderId) => _client.get(
    '/orders/$orderId',
    decode: (value) => OrderModel.fromApi(_map(value)),
  );

  @override
  Future<OrderModel> cancel(String orderId, String reason) async {
    await _client.patch<Object?>(
      '/orders/$orderId/cancel',
      body: {'reason': reason},
      decode: (value) => value,
    );
    return get(orderId);
  }

  @override
  Future<OrderModel> schedule(String orderId, DateTime date) async {
    await _client.patch<Object?>(
      '/orders/$orderId/schedule',
      body: {'scheduled_delivery_date': date.toUtc().toIso8601String()},
      decode: (value) => value,
    );
    return get(orderId);
  }

  @override
  Future<CheckoutResult> repeat(String orderId) => _client.post(
    '/orders/$orderId/repeat',
    decode: (value) {
      final map = _map(value);
      final orders = _list(map['orders']);
      return CheckoutResult(
        checkoutId: '${map['checkout_id'] ?? ''}',
        orders: orders
            .map((item) => OrderModel.fromApi(_map(item)))
            .toList(growable: false),
        totalAmount: orders.fold(
          0,
          (sum, item) => sum + _number(_map(item)['total_amount']),
        ),
      );
    },
  );

  static Map<String, Object?> _checkoutBody(CheckoutSummaryModel summary) {
    final scheduled = _scheduledDate(summary);
    final paymentMethod = switch (summary.paymentMethod) {
      'pix' => 'Pix',
      'credit' => 'Crédito',
      'debit' => 'Débito',
      'cash' => 'Dinheiro',
      _ => null,
    };
    final body = <String, Object?>{
      'delivery_type': 'DELIVERY',
      'address_id': int.parse(summary.addressId),
      if (scheduled != null)
        'scheduled_delivery_date': scheduled.toUtc().toIso8601String(),
    };
    switch (paymentMethod) {
      case final String method:
        body['payment_method'] = method;
      case null:
        break;
    }
    return body;
  }

  static DateTime? _scheduledDate(CheckoutSummaryModel summary) {
    final date = summary.scheduledDate;
    if (!summary.isScheduled || date == null) return null;
    final parts = summary.scheduledTime?.split(':') ?? const [];
    final hour = parts.isNotEmpty ? int.tryParse(parts[0]) ?? 0 : 0;
    final minute = parts.length > 1 ? int.tryParse(parts[1]) ?? 0 : 0;
    return DateTime(date.year, date.month, date.day, hour, minute);
  }

  static CheckoutQuote _decodeQuote(Object? value) {
    final map = _map(value);
    return CheckoutQuote(
      groups: _list(map['groups'])
          .map((value) {
            final group = _map(value);
            return CheckoutQuoteGroup(
              unitId: '${group['unit_id'] ?? ''}',
              subtotal: _number(group['subtotal']),
              discountAmount: _number(group['discount_amount']),
              deliveryFee: _number(group['delivery_fee']),
              totalAmount: _number(group['total_amount']),
            );
          })
          .toList(growable: false),
      totalAmount: _number(map['total_amount']),
    );
  }

  static CheckoutResult _decodeCheckout(Object? value) {
    final map = _map(value);
    return CheckoutResult(
      checkoutId: map['checkout_id'] as String? ?? '',
      orders: _list(
        map['orders'],
      ).map((item) => OrderModel.fromApi(_map(item))).toList(growable: false),
      totalAmount: _number(map['total_amount']),
    );
  }

  static Map<String, Object?> _map(Object? value) {
    if (value is Map<String, Object?>) return value;
    throw _malformed('MALFORMED_CHECKOUT_RESPONSE');
  }

  static List<Object?> _list(Object? value) {
    if (value is List<Object?>) return value;
    throw _malformed('MALFORMED_CHECKOUT_RESPONSE');
  }

  static double _number(Object? value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0;
    return 0;
  }

  static ApiFailure _malformed(String code) => ApiFailure(
    kind: ApiFailureKind.malformedResponse,
    message: 'O servidor retornou dados de pedido inválidos.',
    code: code,
  );
}
