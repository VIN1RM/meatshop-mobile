import 'package:cloud_firestore/cloud_firestore.dart';

class DeliveryEarningModel {
  final String id;
  final String deliveryPersonId;
  final String orderId;
  final String label;
  final double amount;
  final DateTime createdAt;

  const DeliveryEarningModel({
    required this.id,
    required this.deliveryPersonId,
    required this.orderId,
    required this.label,
    required this.amount,
    required this.createdAt,
  });

  factory DeliveryEarningModel.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return DeliveryEarningModel(
      id: doc.id,
      deliveryPersonId: data['delivery_person_id'] as String? ?? '',
      orderId: data['order_id'] as String? ?? '',
      label: data['label'] as String? ?? 'Entrega',
      amount: (data['amount'] as num?)?.toDouble() ?? 0.0,
      createdAt: (data['created_at'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  factory DeliveryEarningModel.fromApi(Map<String, Object?> data) =>
      DeliveryEarningModel(
        id: '${data['id'] ?? ''}',
        deliveryPersonId: '${data['delivery_person_id'] ?? ''}',
        orderId: '${data['order_id'] ?? ''}',
        label: '${data['label'] ?? 'Entrega'}',
        amount: (data['amount'] as num?)?.toDouble() ?? 0,
        createdAt:
            DateTime.tryParse('${data['created_at'] ?? ''}') ?? DateTime.now(),
      );

  Map<String, dynamic> toMap() => {
    'delivery_person_id': deliveryPersonId,
    'order_id': orderId,
    'label': label,
    'amount': amount,
    'created_at': FieldValue.serverTimestamp(),
  };

  bool get isToday {
    final now = DateTime.now();
    return createdAt.year == now.year &&
        createdAt.month == now.month &&
        createdAt.day == now.day;
  }

  bool isNewest(List<DeliveryEarningModel> all) =>
      all.isNotEmpty && all.first.id == id;
}
