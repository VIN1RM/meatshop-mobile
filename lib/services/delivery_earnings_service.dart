import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:meatshop_mobile/models/delivery_earnings_model.dart';
import 'package:meatshop_mobile/models/delivery_goal_model.dart';

class DeliveryEarningsService {
  DeliveryEarningsService._();
  static final DeliveryEarningsService instance = DeliveryEarningsService._();

  final _db = FirebaseFirestore.instance;

  static const _earningsCollection = 'delivery_earnings';
  static const _goalsCollection = 'delivery_goals';
  static const _goalsSubcollection = 'goals';

  Stream<List<DeliveryEarningModel>> earningsStream(String deliveryPersonId) {
    return _db
        .collection(_earningsCollection)
        .where('delivery_person_id', isEqualTo: deliveryPersonId)
        .orderBy('created_at', descending: true)
        .limit(50)
        .snapshots()
        .map((snap) => snap.docs.map(DeliveryEarningModel.fromDoc).toList());
  }

  Future<void> addEarning({
    required String deliveryPersonId,
    required String orderId,
    required String label,
    required double amount,
  }) async {
    await _db.collection(_earningsCollection).add({
      'delivery_person_id': deliveryPersonId,
      'order_id': orderId,
      'label': label,
      'amount': amount,
      'created_at': FieldValue.serverTimestamp(),
    });
  }

  Stream<List<DeliveryGoalModel>> goalsStream(String deliveryPersonId) {
    return _db
        .collection(_goalsCollection)
        .doc(deliveryPersonId)
        .collection(_goalsSubcollection)
        .snapshots()
        .map((snap) => snap.docs.map(DeliveryGoalModel.fromDoc).toList());
  }

  Future<void> updateGoalTarget({
    required String deliveryPersonId,
    required String goalId,
    required double target,
  }) async {
    await _db
        .collection(_goalsCollection)
        .doc(deliveryPersonId)
        .collection(_goalsSubcollection)
        .doc(goalId)
        .update({'target': target});
  }

  Future<void> ensureDefaultGoals(String deliveryPersonId) async {
    final ref = _db
        .collection(_goalsCollection)
        .doc(deliveryPersonId)
        .collection(_goalsSubcollection);

    final existing = await ref.get();
    if (existing.docs.isNotEmpty) return;

    final batch = _db.batch();
    for (final period in GoalPeriod.values) {
      final periodKey = switch (period) {
        GoalPeriod.daily => 'daily',
        GoalPeriod.weekly => 'weekly',
        GoalPeriod.monthly => 'monthly',
      };
      final defaultTarget = switch (period) {
        GoalPeriod.daily => 150.0,
        GoalPeriod.weekly => 800.0,
        GoalPeriod.monthly => 3000.0,
      };
      batch.set(ref.doc(periodKey), {
        'delivery_person_id': deliveryPersonId,
        'period': periodKey,
        'target': defaultTarget,
      });
    }
    await batch.commit();
  }
}
