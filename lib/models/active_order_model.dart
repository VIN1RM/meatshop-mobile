import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:meatshop_mobile/core/enums/order_status_enum.dart';

class ActiveOrderModel {
  final String id;
  final String unitId;
  final String unitName;
  final String unitLogoUrl;
  final OrderStatus status;
  final String? cancellationReason;
  final DateTime? orderDate;

  const ActiveOrderModel({
    required this.id,
    required this.unitId,
    required this.unitName,
    required this.unitLogoUrl,
    required this.status,
    this.cancellationReason,
    this.orderDate,
  });

  bool get canCancel => status.canCancel;
  bool get isCancelled => status == OrderStatus.cancelled;

  factory ActiveOrderModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc, {
    required String unitName,
    required String unitLogoUrl,
  }) {
    final d = doc.data()!;
    return ActiveOrderModel(
      id: doc.id,
      unitId: d['unit_id'] as String? ?? '',
      unitName: unitName,
      unitLogoUrl: unitLogoUrl,
      status: OrderStatusX.fromString(d['status'] as String? ?? 'PENDING'),
      cancellationReason: d['cancellation_reason'] as String?,
      orderDate: (d['order_date'] as Timestamp?)?.toDate(),
    );
  }
}
