import 'dart:convert';
import '../../core/utils/business_clock.dart';
import 'package:crypto/crypto.dart';
import '../auth/secure_key_value_store.dart';
import '../../core/network/api_failure.dart';
import '../../data/repositories/order_repository.dart';
import '../../models/checkout_summary_model.dart';
import '../../models/order_model.dart';
import '../../models/cart_item_model.dart';
import '../http/api_client.dart';

final class HttpOrderRepository
    implements OrderRepository, CheckoutRecovery, CheckoutCapabilities {
  HttpOrderRepository(this._client, {SecureKeyValueStore? pendingStorage})
    : _pendingStorage = pendingStorage;
  final ApiClient _client;
  final SecureKeyValueStore? _pendingStorage;
  bool _creating = false;
  String? get _storageKey => _client.accountId == null
      ? null
      : 'meatshop.checkout.pending.v1.${_client.accountId}';

  Future<Map<String, Object?>?> _readPending() async {
    final key = _storageKey;
    if (key == null || _pendingStorage == null) return null;
    final raw = await _pendingStorage.read(key);
    if (raw == null) return null;
    return _map(jsonDecode(raw));
  }

  Future<CheckoutResult?> _recover(String key) => _client.get(
    '/orders/checkouts/$key',
    decode: (value) =>
        value == null ? null : _decodeCheckout(value, recovered: true),
  );

  @override
  Future<CheckoutResult?> recoverPending() async {
    final pending = await _readPending();
    if (pending == null) return null;
    final storageKey = _storageKey;
    final result = await _recover(pending['key']! as String);
    if (result != null && storageKey != null) {
      await _pendingStorage?.delete(storageKey);
    }
    return result;
  }

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
  }) async {
    if (_creating) throw StateError('Já existe uma confirmação em andamento.');
    _creating = true;
    final storageKey = _storageKey;
    try {
      final body = _checkoutBody(summary);
      final fingerprintBody = Map<String, Object?>.of(body)
        ..remove('quote_token');
      fingerprintBody['quote_digest'] = summary.quoteToken
          ?.split('.')
          .elementAtOrNull(1);
      final fingerprint = sha256
          .convert(utf8.encode(jsonEncode(fingerprintBody)))
          .toString();
      final pending = await _readPending();
      final key = pending?['key'] as String? ?? idempotencyKey;
      if (pending != null) {
        final recovered = await _recover(key);
        if (recovered != null) {
          if (storageKey != null) await _pendingStorage?.delete(storageKey);
          return recovered;
        }
      }
      if (_storageKey != storageKey) {
        throw const ApiFailure(
          kind: ApiFailureKind.unauthorized,
          message: 'A sessão mudou. Entre novamente.',
          code: 'SESSION_EXPIRED',
        );
      }
      // Resolve the original request before starting a different purchase after a timeout.
      final changed = pending != null && pending['fingerprint'] != fingerprint;
      final requestBody = changed ? _map(pending['body']) : body;
      if (storageKey != null && pending == null) {
        await _pendingStorage?.write(
          storageKey,
          jsonEncode({'key': key, 'fingerprint': fingerprint, 'body': body}),
        );
      }
      try {
        final result = await _client.post(
          '/orders',
          body: requestBody,
          headers: {'idempotency-key': key},
          decode: (v) => _decodeCheckout(v, recovered: changed),
        );
        if (storageKey != null) await _pendingStorage?.delete(storageKey);
        _cachedAt = DateTime.fromMillisecondsSinceEpoch(0);
        return result;
      } on ApiFailure catch (error) {
        // Transport/server/decoding failures may have happened after commit; retain the key.
        if (error.kind == ApiFailureKind.validation && storageKey != null) {
          await _pendingStorage?.delete(storageKey);
        }
        rethrow;
      }
    } finally {
      _creating = false;
    }
  }

  @override
  Future<String> createPayment(String orderId) => _client.post(
    '/mercadopago/orders/$orderId/checkout',
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
  Future<Map<String, bool>> paymentAvailability(List<String> units) =>
      _client.get(
        '/mercadopago/capabilities',
        authenticated: false,
        query: {'unit_ids': units.join(',')},
        decode: (value) => {
          for (final entry in _list(_map(value)['units']))
            '${_map(entry)['unit_id']}': _map(entry)['online'] == true,
        },
      );

  @override
  Future<bool> onlinePaymentsAvailable() => _client.get(
    '/mercadopago/capabilities',
    authenticated: false,
    decode: (value) => _map(value)['online'] == true,
  );

  @override
  Future<void> reconcilePayment(String orderId) =>
      _client.post('/payments/orders/$orderId/reconcile', decode: (_) {});

  Future<List<OrderModel>>? _listing;
  List<OrderModel>? _cached;
  String? _cachedOwner;
  DateTime? _cachedAt;
  @override
  Future<List<OrderModel>> list() {
    final owner = _client.accountId;
    if (_cached != null &&
        owner == _cachedOwner &&
        DateTime.now().difference(_cachedAt!) < const Duration(seconds: 5)) {
      return Future.value(_cached);
    }
    return _listing ??= _fetchOrders(owner).whenComplete(() => _listing = null);
  }

  Future<List<OrderModel>> _fetchOrders(String? owner) async {
    final orders = <OrderModel>[];
    for (var page = 0; ; page++) {
      final response = await _client.get(
        '/orders/mobile',
        query: {'page': page},
        decode: _map,
      );
      if (_client.accountId != owner) {
        throw const ApiFailure(
          kind: ApiFailureKind.unauthorized,
          message: 'A sessão mudou. Entre novamente.',
          code: 'SESSION_EXPIRED',
        );
      }
      orders.addAll(
        _list(response['data']).map((v) => OrderModel.fromApi(_map(v))),
      );
      if (response['has_more'] != true) break;
    }
    _cached = List.unmodifiable(orders);
    _cachedOwner = owner;
    _cachedAt = DateTime.now();
    return _cached!;
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
    _cachedAt = DateTime.fromMillisecondsSinceEpoch(0);
    return get(orderId);
  }

  @override
  Future<OrderModel> schedule(String orderId, DateTime date) async {
    await _client.patch<Object?>(
      '/orders/$orderId/schedule',
      body: {'scheduled_delivery_date': date.toUtc().toIso8601String()},
      decode: (value) => value,
    );
    _cachedAt = DateTime.fromMillisecondsSinceEpoch(0);
    return get(orderId);
  }

  @override
  Future<List<String>> repeat(String orderId) => _client.post(
    '/orders/$orderId/repeat',
    decode: (value) =>
        _list(_map(value)['skippedItems']).map((item) => '$item').toList(),
  );

  static Map<String, Object?> _checkoutBody(CheckoutSummaryModel summary) {
    final scheduled = _scheduledDate(summary);
    final paymentMethod = switch (summary.paymentMethod) {
      'pix' => 'Pix',
      'credit' => 'Credit',
      'debit' => 'Debit',
      'cash' => 'Cash',
      'machine' => 'Card on Delivery',
      _ => null,
    };
    final body = <String, Object?>{
      'delivery_type': 'DELIVERY',
      if (summary.quoteToken != null) 'quote_token': summary.quoteToken,
      if (summary.coupons.isNotEmpty)
        'coupon_codes':
            (summary.coupons.entries.toList()
                  ..sort((a, b) => a.key.compareTo(b.key)))
                .map((e) => {'unit_id': int.parse(e.key), 'code': e.value})
                .toList(),
      if (summary.unitPaymentMethods.isNotEmpty)
        'unit_payment_methods':
            (summary.unitPaymentMethods.entries.toList()
                  ..sort((a, b) => a.key.compareTo(b.key)))
                .map(
                  (e) => {
                    'unit_id': int.parse(e.key),
                    'method': _method(e.value),
                    if (e.value == 'cash' &&
                        summary.changeFor != null &&
                        summary.unitPaymentMethods.length == 1)
                      'change_for': summary.changeFor,
                  },
                )
                .toList(),
      if (summary.changeFor != null) 'change_for': summary.changeFor,
      if (summary.expectedTotal != null)
        'expected_total': summary.expectedTotal,
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

  static String _method(String method) => switch (method) {
    'pix' => 'Pix',
    'credit' => 'Credit',
    'debit' => 'Debit',
    'cash' => 'Cash',
    'machine' => 'Card on Delivery',
    _ => throw StateError('Forma de pagamento inválida.'),
  };

  static DateTime? _scheduledDate(CheckoutSummaryModel summary) {
    final date = summary.scheduledDate;
    if (!summary.isScheduled || date == null) return null;
    final parts = summary.scheduledTime?.split(':') ?? const [];
    final hour = parts.isNotEmpty ? int.tryParse(parts[0]) ?? 0 : 0;
    final minute = parts.length > 1 ? int.tryParse(parts[1]) ?? 0 : 0;
    return BusinessClock.scheduled(date, hour, minute);
  }

  static CheckoutQuote _decodeQuote(Object? value) {
    final map = _map(value);
    return CheckoutQuote(
      token: map['quote_token'] as String?,
      expiresAt: DateTime.tryParse('${map['quote_expires_at'] ?? ''}'),
      groups: _list(map['groups'])
          .map((value) {
            final group = _map(value);
            return CheckoutQuoteGroup(
              unitId: '${group['unit_id'] ?? ''}',
              items: group['items'] is List<Object?>
                  ? _list(
                      group['items'],
                    ).map((v) => CartItemModel.fromApi(_map(v))).toList()
                  : const [],
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

  static CheckoutResult _decodeCheckout(
    Object? value, {
    bool recovered = false,
  }) {
    final map = _map(value);
    return CheckoutResult(
      recovered: recovered,
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
