import 'package:flutter/material.dart';
import 'buttons_widget.dart';

/// An empty state with an explicit palette matching its surrounding surface.
class AppEmptyState extends StatelessWidget {
  const AppEmptyState({
    super.key,
    required this.title,
    this.description,
    this.icon = Icons.inbox_outlined,
    this.actionLabel,
    this.onAction,
    this.brightness = Brightness.dark,
  });
  final String title;
  final String? description;
  final IconData icon;
  final String? actionLabel;
  final VoidCallback? onAction;
  final Brightness brightness;
  bool get _light => brightness == Brightness.light;

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
      decoration: BoxDecoration(
        color: _light ? const Color(0xFFEFEFEF) : const Color(0xFF2E2E2E),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 76,
            height: 76,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: (_light ? Colors.black : Colors.white).withValues(
                alpha: .025,
              ),
              border: Border.all(
                color: (_light ? Colors.black : Colors.white).withValues(
                  alpha: .06,
                ),
              ),
            ),
            alignment: Alignment.center,
            child: Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.redPrimary.withValues(
                  alpha: _light ? .07 : .12,
                ),
              ),
              child: Icon(
                icon,
                size: 26,
                color: _light ? AppColors.redPrimary : const Color(0xFFE78176),
              ),
            ),
          ),
          const SizedBox(height: 18),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _light ? AppColors.dark : Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
              height: 1.35,
            ),
          ),
          if (description != null) ...[
            const SizedBox(height: 8),
            Text(
              description!,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: _light ? const Color(0xFF666666) : Colors.white60,
                fontSize: 13,
                height: 1.6,
              ),
            ),
          ],
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: 20),
            TextButton.icon(
              onPressed: onAction,
              style: TextButton.styleFrom(
                foregroundColor: _light
                    ? AppColors.redPrimary
                    : const Color(0xFFFFA99F),
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 12,
                ),
              ),
              icon: const Icon(Icons.arrow_forward_rounded, size: 18),
              label: Text(actionLabel!),
            ),
          ],
        ],
      ),
    ),
  );
}
