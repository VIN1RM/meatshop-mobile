import 'package:flutter/material.dart';
import 'package:meatshop_mobile/models/earning_entry.dart';
import 'package:meatshop_mobile/services/report_export_service.dart';
import 'package:meatshop_mobile/ui/widgets/earning_row.dart';
import 'package:meatshop_mobile/ui/widgets/summary_grid.dart';

class ReportsTab extends StatelessWidget {
  const ReportsTab({
    super.key,
    required this.period,
    required this.onPeriodChanged,
    required this.recentEarnings,
  });

  final String period;
  final void Function(String) onPeriodChanged;
  final List<EarningEntry> recentEarnings;

  static const Color _red = Color(0xFFC0392B);

  static const Map<String, Map<String, String>> _summaryData = {
    'Semanal': {
      'total': 'R\$ 423,75',
      'entregas': '19',
      'media': 'R\$ 22,30',
      'melhorDia': 'Quinta-feira',
    },
    'Mensal': {
      'total': 'R\$ 1.640,00',
      'entregas': '74',
      'media': 'R\$ 22,16',
      'melhorDia': 'Semana 3',
    },
  };

  void _showExportSheet(BuildContext context) {
    final summary = _summaryData[period] ?? _summaryData['Semanal']!;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFDDDDDD),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Exportar relatório',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Color(0xFF1A1A1A),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Período: $period',
              style: const TextStyle(color: Color(0xFF888888), fontSize: 13),
            ),
            const SizedBox(height: 20),
            _ExportOption(
              icon: Icons.picture_as_pdf_outlined,
              label: 'Exportar como PDF',
              onTap: () {
                Navigator.pop(context);
                ReportExportService.exportPdf(
                  period: period,
                  earnings: recentEarnings,
                  summary: summary,
                ).catchError((e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Erro ao gerar PDF: $e'),
                      backgroundColor: const Color(0xFFC0392B),
                    ),
                  );
                });
              },
            ),
            const SizedBox(height: 10),
            _ExportOption(
              icon: Icons.table_chart_outlined,
              label: 'Exportar como CSV',
              onTap: () {
                Navigator.pop(context);
                ReportExportService.exportCsv(
                  period: period,
                  earnings: recentEarnings,
                  summary: summary,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final data = _summaryData[period] ?? _summaryData['Semanal']!;

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
          SummaryGrid(data: data),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: () => _showExportSheet(context),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: _red.withOpacity(0.3), width: 1.5),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.download_outlined, color: _red, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Exportar relatório',
                    style: TextStyle(
                      color: _red,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'ENTREGAS DO PERÍODO',
            style: TextStyle(
              color: _red,
              fontSize: 13,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 12),
          Container(
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
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _ExportOption extends StatelessWidget {
  const _ExportOption({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  static const Color _red = Color(0xFFC0392B);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: _red.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: _red, size: 20),
            ),
            const SizedBox(width: 14),
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1A1A1A),
              ),
            ),
            const Spacer(),
            const Icon(Icons.chevron_right, color: Color(0xFFBBBBBB), size: 20),
          ],
        ),
      ),
    );
  }
}
