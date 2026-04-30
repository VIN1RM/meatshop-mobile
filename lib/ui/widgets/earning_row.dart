import 'package:flutter/material.dart';
import 'package:meatshop_mobile/models/earning_entry.dart';

class EarningRow extends StatelessWidget {
  const EarningRow({super.key, required this.entry});

  final EarningEntry entry;

  static const Color _red = Color(0xFFC0392B);

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
              color: _red.withOpacity(0.08),
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
                    if (entry.isNew) ...[
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
                  entry.time,
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
