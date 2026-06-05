import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:meatshop_mobile/models/delivery_earnings_model.dart';
import 'package:meatshop_mobile/models/delivery_goal_model.dart';
import 'package:meatshop_mobile/services/delivery_earnings_service.dart';

class DeliveryEarningsProvider extends ChangeNotifier {
  final String deliveryPersonId;

  DeliveryEarningsProvider({required this.deliveryPersonId}) {
    _init();
  }

  List<DeliveryEarningModel> _earnings = [];
  List<DeliveryGoalModel> _goals = [];
  bool _loadingEarnings = true;
  bool _loadingGoals = true;

  StreamSubscription<List<DeliveryEarningModel>>? _earningsSub;
  StreamSubscription<List<DeliveryGoalModel>>? _goalsSub;

  List<DeliveryEarningModel> get earnings => _earnings;
  List<DeliveryGoalModel> get goals => _goals;
  bool get loading => _loadingEarnings || _loadingGoals;

  List<DeliveryEarningModel> get todayEarnings =>
      _earnings.where((e) => e.isToday).toList();

  double get todayTotal => todayEarnings.fold(0.0, (sum, e) => sum + e.amount);

  int get todayDeliveries => todayEarnings.length;

  List<double> get weeklyBarValues {
    final now = DateTime.now();
    final values = List.filled(7, 0.0);
    for (final e in _earnings) {
      final diff = now.difference(e.createdAt).inDays;
      if (diff >= 0 && diff < 7) {
        values[6 - diff] += e.amount;
      }
    }
    return values;
  }

  static const List<String> weekDayLabels = ['D', 'S', 'T', 'Q', 'Q', 'S', 'S'];

  double goalProgress(DeliveryGoalModel goal) {
    if (goal.target <= 0) return 0.0;
    final earned = _earnedForPeriod(goal.period);
    return (earned / goal.target).clamp(0.0, 1.0);
  }

  double goalCurrent(DeliveryGoalModel goal) => _earnedForPeriod(goal.period);

  double totalForPeriod(String period) {
    final earnings = period == 'Mensal'
        ? _earningsThisMonth()
        : _earningsThisWeek();
    return earnings.fold(0.0, (sum, e) => sum + e.amount);
  }

  List<DeliveryEarningModel> earningsForPeriod(String period) =>
      period == 'Mensal' ? _earningsThisMonth() : _earningsThisWeek();

  int deliveriesForPeriod(String period) => earningsForPeriod(period).length;

  double avgTicketForPeriod(String period) {
    final list = earningsForPeriod(period);
    if (list.isEmpty) return 0.0;
    return totalForPeriod(period) / list.length;
  }

  Future<void> updateGoalTarget(
    DeliveryGoalModel goal,
    double newTarget,
  ) async {
    await DeliveryEarningsService.instance.updateGoalTarget(
      deliveryPersonId: deliveryPersonId,
      goalId: goal.id,
      target: newTarget,
    );
  }

  Future<void> _init() async {
    await DeliveryEarningsService.instance.ensureDefaultGoals(deliveryPersonId);

    _earningsSub = DeliveryEarningsService.instance
        .earningsStream(deliveryPersonId)
        .listen(
          (list) {
            _earnings = list;
            _loadingEarnings = false;
            notifyListeners();
          },
          onError: (_) {
            _loadingEarnings = false;
            notifyListeners();
          },
        );

    _goalsSub = DeliveryEarningsService.instance
        .goalsStream(deliveryPersonId)
        .listen(
          (list) {
            _goals = list;
            _loadingGoals = false;
            notifyListeners();
          },
          onError: (_) {
            _loadingGoals = false;
            notifyListeners();
          },
        );
  }

  double _earnedForPeriod(GoalPeriod period) {
    final now = DateTime.now();
    return _earnings
        .where((e) {
          return switch (period) {
            GoalPeriod.daily => e.isToday,
            GoalPeriod.weekly => now.difference(e.createdAt).inDays < 7,
            GoalPeriod.monthly =>
              e.createdAt.year == now.year && e.createdAt.month == now.month,
          };
        })
        .fold(0.0, (sum, e) => sum + e.amount);
  }

  List<DeliveryEarningModel> _earningsThisWeek() {
    final now = DateTime.now();
    return _earnings
        .where((e) => now.difference(e.createdAt).inDays < 7)
        .toList();
  }

  List<DeliveryEarningModel> _earningsThisMonth() {
    final now = DateTime.now();
    return _earnings
        .where(
          (e) => e.createdAt.year == now.year && e.createdAt.month == now.month,
        )
        .toList();
  }

  @override
  void dispose() {
    _earningsSub?.cancel();
    _goalsSub?.cancel();
    super.dispose();
  }
}
