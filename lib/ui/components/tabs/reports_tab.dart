import 'package:flutter/material.dart';
import 'package:meatshop_mobile/core/utils/business_clock.dart';
import '../../widgets/delivery_export_button.dart';
import 'package:meatshop_mobile/providers/delivery_earnings_provider.dart';
import 'package:meatshop_mobile/ui/widgets/earning_row.dart';
import 'package:meatshop_mobile/ui/widgets/summary_grid.dart';

class ReportsTab extends StatelessWidget {
  const ReportsTab({
    super.key,
    required this.period,
    required this.onPeriodChanged,
    required this.earningsProvider,
  });

  final String period;
  final void Function(String) onPeriodChanged;
  final DeliveryEarningsProvider earningsProvider;

  static const Color _red = Color(0xFFC0392B);
  Map<String, String> _buildSummary() {
    final total = earningsProvider.totalForPeriod(period);
    final deliveries = earningsProvider.deliveriesForPeriod(period);
    final avg = earningsProvider.avgTicketForPeriod(period);

    String fmt(double v) => 'R\$ ${v.toStringAsFixed(2).replaceAll('.', ',')}';

    return {
      'total': fmt(total),
      'deliveries': '$deliveries',
      'average': fmt(avg),
      'bestDay': period == 'Mensal' ? '—' : '—',
    };
  }

  DateTime _exportTo() {
    final now = BusinessClock.now();
    return DateTime(now.year, now.month, now.day);
  }

  DateTime _exportFrom() {
    final now = _exportTo();
    return period == 'Mensal'
        ? DateTime(now.year, now.month, 1)
        : DateTime(now.year, now.month, now.day - 6);
  }

  @override
  Widget build(BuildContext context) {
    final summary = _buildSummary();
    final earnings = earningsProvider.earningsForPeriod(period);

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 4),
          Row(
            children: ['Semanal', 'Mensal'].map((p) {
              final selected = p == period;
              return GestureDetector(
                onTap: () => onPeriodChanged(p),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.only(right: 10),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 9,
                  ),
                  decoration: BoxDecoration(
                    color: selected ? _red : const Color(0xFFF0F0F0),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    p,
                    style: TextStyle(
                      color: selected ? Colors.white : const Color(0xFF666666),
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
          SummaryGrid(data: summary),
          const SizedBox(height: 20),
          DeliveryExportButton(from: _exportFrom(), to: _exportTo()),
          const SizedBox(height: 24),
          const Text(
            'ENTREGAS DO PERÍODO',
            style: TextStyle(
              color: Color.fromARGB(255, 255, 255, 255),
              fontSize: 13,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 12),
          if (earnings.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(
                child: Text(
                  'Nenhuma entrega no período.',
                  style: TextStyle(color: Color(0xFF999999), fontSize: 13),
                ),
              ),
            )
          else
            Container(
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
            ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
