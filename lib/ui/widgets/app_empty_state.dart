import 'package:flutter/material.dart';
import 'buttons_widget.dart';

/// Shared presentation for empty lists, with an optional next step.
class AppEmptyState extends StatelessWidget {
  const AppEmptyState({
    super.key,
    required this.title,
    this.description,
    this.icon = Icons.inbox_outlined,
    this.actionLabel,
    this.onAction,
  });
  final String title;
  final String? description;
  final IconData icon;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(24),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: const Color(0xFFEAEAEA)),
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.redPrimary.withValues(alpha: .08),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Icon(icon, size: 30, color: AppColors.redPrimary),
        ),
        const SizedBox(height: 16),
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: AppColors.dark,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          description ??
              'Os registros aparecerão aqui assim que estiverem disponíveis.',
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Color(0xFF666666),
            fontSize: 13,
            height: 1.5,
          ),
        ),
        if (actionLabel != null && onAction != null) ...[
          const SizedBox(height: 18),
          PrimaryButton(label: actionLabel!, onPressed: onAction),
        ],
      ],
    ),
  );
}
