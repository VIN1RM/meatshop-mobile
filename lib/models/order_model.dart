import 'address_model.dart';

class OrderItemModel {
  final String productId;
  final String productName;
  final String unitOfMeasure;
  final double quantity;
  final double unitPrice;
  final String productImageUrl;

  const OrderItemModel({
    required this.productId,
    required this.productName,
    required this.unitOfMeasure,
    required this.quantity,
    required this.unitPrice,
    required this.productImageUrl,
  });

  String get quantityLabel {
    final unit = unitOfMeasure.trim().toLowerCase();
    if (unit == 'kg' && quantity > 0 && quantity < 1) {
      return '${_formatQuantity(quantity * 1000)} g';
    }
    return '${_formatQuantity(quantity)} $unit';
  }

  static String _formatQuantity(double value) => value
      .toStringAsFixed(3)
      .replaceFirst(RegExp(r'\.?0+$'), '')
      .replaceAll('.', ',');
}

class OrderModel {
  final AddressModel? destination;
  final String id;
  final String clientId;
  final String unitId;
  final String unitName;
  final String unitLogoUrl;
  final String addressId;
  final String status;
  final String deliveryStatus;
  final String? deliveryPersonId;
  final String deliveryType;
  final String paymentStatus;
  final String paymentMethod;
  final String? checkoutId;
  final DateTime? paymentDueAt;
  final String? refundStatus;
  final double refundedAmount;
  final double? changeFor;
  bool get isOfflinePayment =>
      const {'Cash', 'Card on Delivery'}.contains(paymentMethod);
  bool get canPay =>
      status == 'PENDING' &&
      const {'PENDING', 'REJECTED', 'CANCELLED'}.contains(paymentStatus) &&
      !isOfflinePayment &&
      paymentDueAt != null &&
      paymentDueAt!.isAfter(DateTime.now());
  String get paymentMethodLabel => switch (paymentMethod.toUpperCase()) {
    'PIX' => 'Pix',
    'CREDIT' || 'CREDIT_CARD' => 'Cartão de crédito',
    'DEBIT' || 'DEBIT_CARD' => 'Cartão de débito',
    'CASH' => 'Dinheiro',
    'CARD ON DELIVERY' => 'Maquininha na entrega',
    'MERCADO PAGO BALANCE' => 'Saldo Mercado Pago',
    'BANK SLIP' => 'Boleto',
    _ => paymentMethod.isEmpty ? 'Não informado' : paymentMethod,
  };

  String get paymentStatusLabel {
    if (refundStatus == 'PENDING') return 'Estorno solicitado';
    if (refundStatus == 'FAILED') return 'Estorno precisa de atendimento';
    return switch (paymentStatus) {
      'PAID' => 'Pago',
      'REJECTED' => 'Pagamento recusado',
      'REFUNDED' => 'Reembolsado',
      'PARTIALLY_REFUNDED' => 'Reembolsado parcialmente',
      'CHARGED_BACK' => 'Pagamento contestado',
      'CANCELLED' => 'Pagamento cancelado',
      _ => isOfflinePayment ? 'A pagar na entrega' : 'Aguardando pagamento',
    };
  }

  final double subtotal;
  final double deliveryFee;
  final double discountAmount;
  final double totalAmount;
  final bool isScheduled;
  final DateTime? scheduledDeliveryDate;
  final String? scheduledTime;
  final DateTime? orderDate;
  final String? cancellationReason;
  final List<OrderItemModel> items;
  final bool reviewed;
  final bool productsReviewed;
  final String? deliveryCode;

  const OrderModel({
    this.destination,
    required this.id,
    required this.clientId,
    required this.unitId,
    this.unitName = '',
    this.unitLogoUrl = '',
    required this.addressId,
    required this.status,
    required this.deliveryStatus,
    this.deliveryPersonId,
    required this.deliveryType,
    required this.paymentStatus,
    required this.paymentMethod,
    this.checkoutId,
    this.paymentDueAt,
    this.refundStatus,
    this.refundedAmount = 0,
    this.changeFor,
    required this.subtotal,
    required this.deliveryFee,
    required this.discountAmount,
    required this.totalAmount,
    required this.isScheduled,
    this.scheduledDeliveryDate,
    this.scheduledTime,
    this.orderDate,
    this.cancellationReason,
    this.items = const [],
    this.reviewed = false,
    this.productsReviewed = false,
    this.deliveryCode,
  });

  bool get isCancelled => status == 'CANCELLED';

  String get formattedTotal =>
      'R\$ ${totalAmount.toStringAsFixed(2).replaceAll('.', ',')}';

  OrderModel copyWith({
    String? unitName,
    String? unitLogoUrl,
    List<OrderItemModel>? items,
    bool? reviewed,
    String? deliveryPersonId,
    bool? productsReviewed,
    String? deliveryCode,
  }) => OrderModel(
    destination: destination,
    id: id,
    clientId: clientId,
    unitId: unitId,
    unitName: unitName ?? this.unitName,
    unitLogoUrl: unitLogoUrl ?? this.unitLogoUrl,
    addressId: addressId,
    status: status,
    deliveryStatus: deliveryStatus,
    deliveryPersonId: deliveryPersonId ?? this.deliveryPersonId,
    deliveryType: deliveryType,
    paymentStatus: paymentStatus,
    paymentMethod: paymentMethod,
    checkoutId: checkoutId,
    paymentDueAt: paymentDueAt,
    refundStatus: refundStatus,
    refundedAmount: refundedAmount,
    changeFor: changeFor,
    subtotal: subtotal,
    deliveryFee: deliveryFee,
    discountAmount: discountAmount,
    totalAmount: totalAmount,
    isScheduled: isScheduled,
    scheduledDeliveryDate: scheduledDeliveryDate,
    scheduledTime: scheduledTime,
    orderDate: orderDate,
    cancellationReason: cancellationReason,
    items: items ?? this.items,
    reviewed: reviewed ?? this.reviewed,
    productsReviewed: productsReviewed ?? this.productsReviewed,
    deliveryCode: deliveryCode ?? this.deliveryCode,
  );

  factory OrderModel.fromApi(Map<String, Object?> data) {
    double number(String key) {
      final value = data[key];
      if (value is num) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? 0;
      return 0;
    }

    DateTime? date(String key) {
      final value = data[key];
      return value is String ? DateTime.tryParse(value) : null;
    }

    final payment = data['payment'] is Map<String, Object?>
        ? data['payment']! as Map<String, Object?>
        : const <String, Object?>{};
    final reviews = data['review_status'] is Map<String, Object?>
        ? data['review_status'] as Map<String, Object?>
        : null;
    final reviewedProducts = reviews?['reviewed_product_ids'] is List
        ? (reviews!['reviewed_product_ids'] as List).map((id) => '$id').toSet()
        : <String>{};
    final rawItems = data['items'];
    final items = rawItems is List<Object?>
        ? rawItems
              .whereType<Map<String, Object?>>()
              .map((item) {
                double itemNumber(String key) {
                  final value = item[key];
                  if (value is num) return value.toDouble();
                  if (value is String) return double.tryParse(value) ?? 0;
                  return 0;
                }

                return OrderItemModel(
                  productId: '${item['product_id'] ?? ''}',
                  productName: item['product_name'] as String? ?? '',
                  unitOfMeasure: item['unit_of_measure'] as String? ?? 'un',
                  quantity: itemNumber('quantity'),
                  unitPrice: itemNumber('unit_price'),
                  productImageUrl: item['product_image_url'] as String? ?? '',
                );
              })
              .toList(growable: false)
        : const <OrderItemModel>[];
    return OrderModel(
      reviewed: reviews?['unit_reviewed'] == true,
      productsReviewed:
          reviews != null &&
          items.every((i) => reviewedProducts.contains(i.productId)),
      destination: data['destination'] is Map<String, Object?>
          ? AddressModel.fromApi(data['destination'] as Map<String, Object?>)
          : null,
      id: '${data['id'] ?? ''}',
      clientId: '${data['client_id'] ?? ''}',
      unitId: '${data['unit_id'] ?? ''}',
      unitName: data['unit_name'] as String? ?? 'AÃ§ougue',
      unitLogoUrl: data['unit_logo_url'] as String? ?? '',
      addressId: '${data['address_id'] ?? ''}',
      status: data['status'] as String? ?? 'PENDING',
      deliveryStatus: data['delivery_status'] as String? ?? '',
      deliveryPersonId: data['delivery_person_id']?.toString(),
      deliveryType: data['delivery_type'] as String? ?? 'DELIVERY',
      paymentStatus: data['payment_status'] as String? ?? 'PENDING',
      paymentMethod: payment['method'] as String? ?? '',
      checkoutId: data['checkout_id'] as String?,
      paymentDueAt: date('payment_due_at'),
      refundStatus: payment['refund_status'] as String?,
      refundedAmount: double.tryParse('${payment['refunded_amount']}') ?? 0,
      changeFor: double.tryParse('${data['change_for']}'),
      subtotal: number('subtotal'),
      deliveryFee: number('delivery_fee'),
      discountAmount: number('discount_amount'),
      totalAmount: number('total_amount'),
      isScheduled: data['is_scheduled'] as bool? ?? false,
      scheduledDeliveryDate: date('scheduled_delivery_date'),
      orderDate: date('order_date'),
      cancellationReason: data['cancellation_reason'] as String?,
      items: items,
      deliveryCode: data['delivery_code'] as String?,
    );
  }
}
