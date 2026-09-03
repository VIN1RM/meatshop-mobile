import 'package:cloud_firestore/cloud_firestore.dart';

enum GoalPeriod { daily, weekly, monthly }

class DeliveryGoalModel {
  final String id;
  final String deliveryPersonId;
  final GoalPeriod period;
  final double target;

  const DeliveryGoalModel({
    required this.id,
    required this.deliveryPersonId,
    required this.period,
    required this.target,
  });

  String get label => switch (period) {
    GoalPeriod.daily => 'Meta diária',
    GoalPeriod.weekly => 'Meta semanal',
    GoalPeriod.monthly => 'Meta mensal',
  };

  String get periodKey => switch (period) {
    GoalPeriod.daily => 'daily',
    GoalPeriod.weekly => 'weekly',
    GoalPeriod.monthly => 'monthly',
  };

  factory DeliveryGoalModel.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return DeliveryGoalModel(
      id: doc.id,
      deliveryPersonId: data['delivery_person_id'] as String? ?? '',
      period: _parsePeriod(data['period'] as String? ?? 'daily'),
      target: (data['target'] as num?)?.toDouble() ?? 0.0,
    );
  }

  factory DeliveryGoalModel.fromApi(Map<String, Object?> data) =>
      DeliveryGoalModel(
        id: '${data['id'] ?? ''}',
        deliveryPersonId: '${data['delivery_person_id'] ?? ''}',
        period: _parsePeriod('${data['period'] ?? 'daily'}'),
        target: (data['target'] as num?)?.toDouble() ?? 0,
      );

  Map<String, dynamic> toMap() => {
    'delivery_person_id': deliveryPersonId,
    'period': periodKey,
    'target': target,
  };

  DeliveryGoalModel copyWith({double? target}) => DeliveryGoalModel(
    id: id,
    deliveryPersonId: deliveryPersonId,
    period: period,
    target: target ?? this.target,
  );

  static GoalPeriod _parsePeriod(String value) => switch (value) {
    'weekly' => GoalPeriod.weekly,
    'monthly' => GoalPeriod.monthly,
    _ => GoalPeriod.daily,
  };
}
