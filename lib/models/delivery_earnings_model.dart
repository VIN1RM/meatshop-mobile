import '../core/utils/business_clock.dart';

class DeliveryEarningModel {
  final String id;
  final String deliveryPersonId;
  final String orderId;
  final String label;
  final double amount;
  final DateTime createdAt;
  final DateTime? paidAt;

  const DeliveryEarningModel({
    required this.id,
    required this.deliveryPersonId,
    required this.orderId,
    required this.label,
    required this.amount,
    required this.createdAt,
    this.paidAt,
  });

  factory DeliveryEarningModel.fromApi(
    Map<String, Object?> data,
  ) => DeliveryEarningModel(
    id: '${data['id'] ?? ''}',
    paidAt: DateTime.tryParse('${data['paid_at'] ?? ''}'),
    deliveryPersonId: '${data['delivery_person_id'] ?? ''}',
    orderId: '${data['order_id'] ?? ''}',
    label:
        '${data['label'] ?? 'Entrega'} · ${data['paid_at'] == null ? 'A receber' : 'Recebido'}',
    amount: (data['amount'] as num?)?.toDouble() ?? 0,
    createdAt:
        DateTime.tryParse('${data['created_at'] ?? ''}')?.toLocal() ??
        DateTime.now(),
  );

  Map<String, dynamic> toMap() => {
    'delivery_person_id': deliveryPersonId,
    'order_id': orderId,
    'label': label,
    'amount': amount,
    'created_at': createdAt.toIso8601String(),
  };

  bool get isToday {
    final now = BusinessClock.now();
    final date = BusinessClock.local(createdAt);
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  bool isNewest(List<DeliveryEarningModel> all) =>
      all.isNotEmpty && all.first.id == id;
}
