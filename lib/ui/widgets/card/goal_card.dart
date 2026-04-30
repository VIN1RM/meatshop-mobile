import 'package:flutter/material.dart';
import 'package:meatshop_mobile/models/goal_model.dart';

class GoalCard extends StatelessWidget {
  const GoalCard({super.key, required this.goal, required this.onEdit});

  final GoalModel goal;
  final VoidCallback onEdit;

  static const Color _red = Color(0xFFC0392B);

  @override
  Widget build(BuildContext context) {
    final progress = (goal.current / goal.target).clamp(0.0, 1.0);
    final percent = (progress * 100).toStringAsFixed(0);
    final isComplete = progress >= 1.0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: isComplete
                      ? const Color(0xFF27AE60).withOpacity(0.12)
                      : _red.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  isComplete ? '✓ Concluída' : goal.label,
                  style: TextStyle(
                    color: isComplete ? const Color(0xFF27AE60) : _red,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: onEdit,
                child: const Icon(
                  Icons.edit_outlined,
                  color: Color(0xFFBBBBBB),
                  size: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              RichText(
                text: TextSpan(
                  style: const TextStyle(
                    color: Color(0xFF1A1A1A),
                    fontSize: 20,
                  ),
                  children: [
                    TextSpan(
                      text:
                          'R\$ ${goal.current.toStringAsFixed(2).replaceAll('.', ',')}',
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                    TextSpan(
                      text:
                          ' / R\$ ${goal.target.toStringAsFixed(0).replaceAll('.', ',')}',
                      style: const TextStyle(
                        color: Color(0xFF999999),
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '$percent%',
                style: TextStyle(
                  color: isComplete ? const Color(0xFF27AE60) : _red,
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 7,
              backgroundColor: const Color(0xFFE0E0E0),
              valueColor: AlwaysStoppedAnimation<Color>(
                isComplete ? const Color(0xFF27AE60) : _red,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
