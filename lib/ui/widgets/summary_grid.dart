import 'package:flutter/material.dart';

class SummaryGrid extends StatelessWidget {
  const SummaryGrid({super.key, required this.data});

  final Map<String, String> data;

  static const Color _red = Color(0xFFC0392B);

  @override
  Widget build(BuildContext context) {
    final items = [
      _SummaryItem(
        icon: Icons.attach_money,
        label: 'Total ganho',
        value: data['total']!,
      ),
      _SummaryItem(
        icon: Icons.delivery_dining_outlined,
        label: 'Entregas',
        value: data['entregas']!,
      ),
      _SummaryItem(
        icon: Icons.trending_up,
        label: 'Ticket médio',
        value: data['media']!,
      ),
      _SummaryItem(
        icon: Icons.emoji_events_outlined,
        label: 'Melhor período',
        value: data['melhorDia']!,
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.7,
      ),
      itemCount: items.length,
      itemBuilder: (_, i) => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(items[i].icon, color: _red, size: 18),
            const SizedBox(height: 6),
            Text(
              items[i].value,
              style: const TextStyle(
                color: Color(0xFF1A1A1A),
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
            Text(
              items[i].label,
              style: const TextStyle(color: Color(0xFF888888), fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryItem {
  final IconData icon;
  final String label;
  final String value;

  _SummaryItem({required this.icon, required this.label, required this.value});
}
