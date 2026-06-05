import 'package:flutter/material.dart';
import 'package:meatshop_mobile/models/delivery_earnings_model.dart';
import 'package:meatshop_mobile/models/delivery_goal_model.dart';
import 'package:meatshop_mobile/providers/delivery_earnings_provider.dart';
import 'package:meatshop_mobile/ui/widgets/earning_row.dart';
import 'package:meatshop_mobile/ui/widgets/card/goal_card.dart';
import 'package:meatshop_mobile/ui/widgets/mini_bar_chart.dart';
import 'package:meatshop_mobile/models/bar_data.dart';

class EarningsTab extends StatelessWidget {
  const EarningsTab({
    super.key,
    required this.goals,
    required this.earnings,
    required this.weekBarValues,
    required this.earningsProvider,
    required this.onEditGoal,
    required this.todayTotal,
    required this.todayDeliveries,
  });

  final List<DeliveryGoalModel> goals;
  final List<DeliveryEarningModel> earnings;
  final List<double> weekBarValues;
  final DeliveryEarningsProvider earningsProvider;
  final void Function(DeliveryGoalModel) onEditGoal;
  final double todayTotal;
  final int todayDeliveries;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 4),
          _sectionTitle('GANHOS EM TEMPO REAL'),
          const SizedBox(height: 12),
          _TodayCard(total: todayTotal, deliveries: todayDeliveries),
          const SizedBox(height: 20),
          _sectionTitle('ÚLTIMOS 7 DIAS'),
          const SizedBox(height: 12),
          MiniBarChart(
            bars: List.generate(
              weekBarValues.length,
              (i) => BarData(
                day: DeliveryEarningsProvider.weekDayLabels[i],
                value: weekBarValues[i],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [_sectionTitle('MINHAS METAS')],
          ),
          const SizedBox(height: 12),
          if (goals.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Text(
                'Nenhuma meta cadastrada.',
                style: TextStyle(color: Colors.white60, fontSize: 13),
              ),
            )
          else
            ...goals.map(
              (g) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: GoalCard(
                  goal: g,
                  current: earningsProvider.goalCurrent(g),
                  onEdit: () => onEditGoal(g),
                ),
              ),
            ),
          const SizedBox(height: 24),
          _sectionTitle('GANHOS RECENTES'),
          const SizedBox(height: 12),
          _EarningsList(earnings: earnings),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 13,
        fontWeight: FontWeight.w900,
        letterSpacing: 1.0,
      ),
    );
  }
}

class _TodayCard extends StatelessWidget {
  const _TodayCard({required this.total, required this.deliveries});

  final double total;
  final int deliveries;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFC0392B), Color(0xFF96281B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFC0392B).withValues(alpha: 0.4),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.bolt, color: Colors.white70, size: 16),
              const SizedBox(width: 4),
              const Text(
                'Ganhos hoje',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  '● AO VIVO',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'R\$ ${total.toStringAsFixed(2).replaceAll('.', ',')}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 36,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '$deliveries ${deliveries == 1 ? 'entrega realizada' : 'entregas realizadas'}',
            style: const TextStyle(color: Colors.white60, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _EarningsList extends StatelessWidget {
  const _EarningsList({required this.earnings});

  final List<DeliveryEarningModel> earnings;

  @override
  Widget build(BuildContext context) {
    if (earnings.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Center(
          child: Text(
            'Nenhum ganho registrado ainda.',
            style: TextStyle(color: Colors.white60, fontSize: 13),
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: List.generate(earnings.length, (i) {
          return Column(
            children: [
              EarningRow(entry: earnings[i]),
              if (i < earnings.length - 1)
                const Divider(
                  height: 1,
                  indent: 16,
                  endIndent: 16,
                  color: Color(0xFFE8E8E8),
                ),
            ],
          );
        }),
      ),
    );
  }
}
