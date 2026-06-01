import 'package:cloud_firestore/cloud_firestore.dart';

class OrderItemModel {
  final String productId;
  final String productName;
  final String unitOfMeasure;
  final String imageUrl;
  final int quantity;
  final double unitPrice;

  const OrderItemModel({
    required this.productId,
    required this.productName,
    required this.unitOfMeasure,
    required this.imageUrl,
    required this.quantity,
    required this.unitPrice,
  });

  factory OrderItemModel.fromMap(Map<String, dynamic> map) {
    final snapshot = map['product_snapshot'] as Map<String, dynamic>? ?? {};
    return OrderItemModel(
      productId: map['product_id'] as String? ?? '',
      productName: snapshot['name'] as String? ?? '',
      unitOfMeasure: snapshot['unit_of_measure'] as String? ?? '',
      imageUrl: snapshot['image_url'] as String? ?? '',
      quantity: (map['quantity'] as num?)?.toInt() ?? 0,
      unitPrice: (map['unit_price'] as num?)?.toDouble() ?? 0.0,
    );
  }

  String get quantityLabel {
    if (unitOfMeasure.isEmpty) return '$quantity';
    return '$quantity ${unitOfMeasure.toUpperCase()}';
  }
}

enum OrderStatus {
  pending,
  confirmed,
  preparing,
  ready,
  outForDelivery,
  delivered,
  cancelled,
  unknown;

  static OrderStatus fromString(String? value) {
    switch (value?.toUpperCase()) {
      case 'PENDING':
        return OrderStatus.pending;
      case 'CONFIRMED':
        return OrderStatus.confirmed;
      case 'PREPARING':
        return OrderStatus.preparing;
      case 'READY':
        return OrderStatus.ready;
      case 'OUT_FOR_DELIVERY':
        return OrderStatus.outForDelivery;
      case 'DELIVERED':
        return OrderStatus.delivered;
      case 'CANCELLED':
        return OrderStatus.cancelled;
      default:
        return OrderStatus.unknown;
    }
  }

  bool get isActive =>
      this == OrderStatus.pending ||
      this == OrderStatus.confirmed ||
      this == OrderStatus.preparing ||
      this == OrderStatus.ready ||
      this == OrderStatus.outForDelivery;

  bool get isFinished =>
      this == OrderStatus.delivered || this == OrderStatus.cancelled;
}

class OrderModel {
  final String id;
  final String clientId;
  final String unitId;
  final String unitName;
  final String unitLogoUrl;
  final OrderStatus status;
  final double totalAmount;
  final DateTime orderDate;
  final List<OrderItemModel> items;

  final String? cancellationReason;
  final DateTime? cancelledAt;
  final String? cancelledBy;

  const OrderModel({
    required this.id,
    required this.clientId,
    required this.unitId,
    required this.unitName,
    required this.unitLogoUrl,
    required this.status,
    required this.totalAmount,
    required this.orderDate,
    required this.items,
    this.cancellationReason,
    this.cancelledAt,
    this.cancelledBy,
  });

  factory OrderModel.fromDoc(
    DocumentSnapshot doc, {
    List<OrderItemModel> items = const [],
    String unitName = '',
    String unitLogoUrl = '',
  }) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    final rawDate = data['order_date'];
    final DateTime orderDate;
    if (rawDate is Timestamp) {
      orderDate = rawDate.toDate();
    } else {
      orderDate = DateTime.now();
    }

    final rawCancelledAt = data['cancelled_at'];
    DateTime? cancelledAt;
    if (rawCancelledAt is Timestamp) {
      cancelledAt = rawCancelledAt.toDate();
    }

    return OrderModel(
      id: doc.id,
      clientId: data['client_id'] as String? ?? '',
      unitId: data['unit_id'] as String? ?? '',
      unitName: unitName,
      unitLogoUrl: unitLogoUrl,
      status: OrderStatus.fromString(data['status'] as String?),
      totalAmount: (data['total_amount'] as num?)?.toDouble() ?? 0.0,
      orderDate: orderDate,
      items: items,
      cancellationReason: data['cancellation_reason'] as String?,
      cancelledAt: cancelledAt,
      cancelledBy: data['cancelled_by'] as String?,
    );
  }

  String get formattedTotal {
    return 'R\$${totalAmount.toStringAsFixed(2).replaceAll('.', ',')}';
  }

  bool get isActive => status.isActive;
  bool get isFinished => status.isFinished;
  bool get isCancelled => status == OrderStatus.cancelled;
  bool get isDelivered => status == OrderStatus.delivered;
}