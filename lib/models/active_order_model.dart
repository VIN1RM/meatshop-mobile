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
}
