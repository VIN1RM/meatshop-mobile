import 'package:flutter/material.dart';
import 'package:meatshop_mobile/models/business_hours_model.dart';

class BusinessHoursBanner extends StatelessWidget {
  final BusinessHoursModel? hours;

  const BusinessHoursBanner({super.key, required this.hours});

  @override
  Widget build(BuildContext context) {
    if (hours == null) return const SizedBox.shrink();

    final open = hours!.isOpenNow;
    final color = open ? const Color(0xFF27AE60) : const Color(0xFFC0392B);
    final bg = open ? const Color(0xFFEAF7EE) : const Color(0xFFFDECEC);
    final label = open ? 'Aberto agora' : 'Fechado agora';
    final hours_ = '${hours!.openingTime} – ${hours!.closingTime}';
    final closedMsg = hours!.isOpen
        ? 'Abre hoje às ${hours!.openingTime}'
        : 'Fechado hoje';

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: color,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  open ? 'Horário: $hours_' : closedMsg,
                  style: const TextStyle(
                    color: Color(0xFF555555),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          if (!open)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Agendado',
                style: TextStyle(
                  color: color,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
