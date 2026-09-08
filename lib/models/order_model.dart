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
    if (unitOfMeasure == 'kg' || unitOfMeasure == 'g') {
      final grams = (quantity * 1000).round();
      return grams >= 1000 ? '${quantity.toStringAsFixed(0)} kg' : '$grams g';
    }
    return '${quantity.toStringAsFixed(0)} $unitOfMeasure';
  }
}

class OrderModel {
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
      id: '${data['id'] ?? ''}',
      clientId: '${data['client_id'] ?? ''}',
      unitId: '${data['unit_id'] ?? ''}',
      unitName: data['unit_name'] as String? ?? 'Açougue',
      unitLogoUrl: data['unit_logo_url'] as String? ?? '',
      addressId: '${data['address_id'] ?? ''}',
      status: data['status'] as String? ?? 'PENDING',
      deliveryStatus: data['delivery_status'] as String? ?? '',
      deliveryPersonId: data['delivery_person_id']?.toString(),
      deliveryType: data['delivery_type'] as String? ?? 'DELIVERY',
      paymentStatus: data['payment_status'] as String? ?? 'PENDING',
      paymentMethod: payment['method'] as String? ?? '',
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
