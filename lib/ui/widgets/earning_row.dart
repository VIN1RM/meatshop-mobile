import 'package:flutter/material.dart';
import 'package:meatshop_mobile/models/delivery_earnings_model.dart';

class EarningRow extends StatelessWidget {
  const EarningRow({super.key, required this.entry});

  final DeliveryEarningModel entry;

  static const Color _red = Color(0xFFC0392B);

  String get _timeLabel {
    final now = DateTime.now();
    final diff = now.difference(entry.createdAt);

    if (diff.inMinutes < 1) return 'Agora';
    if (diff.inHours < 1) return '${diff.inMinutes} min atrás';
    if (entry.isToday) {
      final h = entry.createdAt.hour.toString().padLeft(2, '0');
      final m = entry.createdAt.minute.toString().padLeft(2, '0');
      return '$h:$m';
    }
    return 'Ontem';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: _red.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.delivery_dining_outlined,
              color: _red,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      entry.label,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                    if (entry.isToday &&
                        entry.createdAt.isAfter(
                          DateTime.now().subtract(const Duration(minutes: 30)),
                        )) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 5,
                          vertical: 1,
                        ),
                        decoration: BoxDecoration(
                          color: _red,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'NOVO',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 8,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                Text(
                  _timeLabel,
                  style: const TextStyle(
                    color: Color(0xFF999999),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          Text(
            'R\$ ${entry.amount.toStringAsFixed(2).replaceAll('.', ',')}',
            style: const TextStyle(
              color: Color(0xFF1A1A1A),
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
