import 'dart:math';
import 'package:flutter/material.dart';
import 'package:meatshop_mobile/models/bar_data.dart';

class MiniBarChart extends StatelessWidget {
  const MiniBarChart({super.key, required this.bars});

  final List<BarData> bars;

  static const Color _red = Color(0xFFC0392B);

  @override
  Widget build(BuildContext context) {
    final maxVal = bars.map((b) => b.value).reduce(max).toDouble();

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          SizedBox(
            height: 80,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: bars.map((b) {
                final frac = b.value / maxVal;
                final isLast = b == bars.last;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 500),
                          height: frac * 65,
                          decoration: BoxDecoration(
                            color: isLast ? _red : _red.withOpacity(0.25),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: bars.map((b) {
              return Expanded(
                child: Center(
                  child: Text(
                    b.day,
                    style: const TextStyle(
                      color: Color(0xFF999999),
                      fontSize: 10,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
