import 'package:flutter/material.dart';
import 'package:meatshop_mobile/models/bar_data.dart';
import 'package:meatshop_mobile/models/earning_entry.dart';
import 'package:meatshop_mobile/models/goal_model.dart';
import 'package:meatshop_mobile/ui/widgets/earning_row.dart';
import 'package:meatshop_mobile/ui/widgets/card/goal_card.dart';
import 'package:meatshop_mobile/ui/widgets/mini_bar_chart.dart';

class EarningsTab extends StatelessWidget {
  const EarningsTab({
    super.key,
    required this.goals,
    required this.recentEarnings,
    required this.weekBars,
    required this.onEditGoal,
    required this.todayTotal,
    required this.todayDeliveries,
  });

  final List<GoalModel> goals;
  final List<EarningEntry> recentEarnings;
  final List<BarData> weekBars;
  final void Function(GoalModel) onEditGoal;
  final double todayTotal;
  final int todayDeliveries;

  static const Color _red = Color(0xFFC0392B);

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
          _buildTodayCard(),
          const SizedBox(height: 20),
          _sectionTitle('ÚLTIMOS 7 DIAS'),
          const SizedBox(height: 12),
          MiniBarChart(bars: weekBars),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _sectionTitle('MINHAS METAS'),
              GestureDetector(
                onTap: () {},
                child: const Text(
                  '+ Nova meta',
                  style: TextStyle(
                    color: _red,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...goals.map(
            (g) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: GoalCard(goal: g, onEdit: () => onEditGoal(g)),
            ),
          ),
          const SizedBox(height: 24),
          _sectionTitle('GANHOS RECENTES'),
          const SizedBox(height: 12),
          _buildEarningsList(),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildTodayCard() {
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
            color: _red.withOpacity(0.25),
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
                  color: Colors.white.withOpacity(0.2),
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
            'R\$ ${todayTotal.toStringAsFixed(2).replaceAll('.', ',')}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 36,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '$todayDeliveries ${todayDeliveries == 1 ? 'entrega realizada' : 'entregas realizadas'}',
            style: const TextStyle(color: Colors.white60, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildEarningsList() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: List.generate(recentEarnings.length, (i) {
          return Column(
            children: [
              EarningRow(entry: recentEarnings[i]),
              if (i < recentEarnings.length - 1)
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

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: _red,
        fontSize: 13,
        fontWeight: FontWeight.w900,
        letterSpacing: 1.0,
      ),
    );
  }
}
