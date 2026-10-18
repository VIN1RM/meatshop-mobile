import 'package:flutter/material.dart';
import 'buttons_widget.dart';

class LegalSection extends StatelessWidget {
  const LegalSection({
    super.key,
    required this.title,
    required this.icon,
    required this.child,
    this.description,
  });
  final String title;
  final IconData icon;
  final Widget child;
  final String? description;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: AppColors.background,
      borderRadius: BorderRadius.circular(16),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: AppColors.redPrimary, size: 22),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  color: AppColors.dark,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        if (description != null) ...[
          const SizedBox(height: 8),
          Text(
            description!,
            style: const TextStyle(
              color: Colors.black54,
              fontSize: 13,
              height: 1.5,
            ),
          ),
        ],
        const SizedBox(height: 16),
        child,
      ],
    ),
  );
}

class LegalConsentTile extends StatelessWidget {
  const LegalConsentTile({
    super.key,
    required this.value,
    required this.onChanged,
    this.dark = false,
  });
  final bool value;
  final ValueChanged<bool>? onChanged;
  final bool dark;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      color: value
          ? AppColors.redPrimary.withValues(alpha: dark ? 0.2 : 0.06)
          : Colors.transparent,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(
        color: value
            ? AppColors.redPrimary
            : (dark ? Colors.white24 : Colors.black12),
      ),
    ),
    child: CheckboxListTile(
      value: value,
      onChanged: onChanged == null
          ? null
          : (value) => onChanged!(value == true),
      activeColor: AppColors.redPrimary,
      checkColor: AppColors.white,
      controlAffinity: ListTileControlAffinity.leading,
      contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      title: Text(
        'Li e aceito os Termos de Uso e declaro ciência da Política de Privacidade.',
        style: TextStyle(
          color: dark ? AppColors.white : AppColors.dark,
          fontSize: 13,
          height: 1.5,
        ),
      ),
    ),
  );
}

class LegalActionButton extends StatelessWidget {
  const LegalActionButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.loading = false,
  });
  final String label;
  final VoidCallback? onPressed;
  final bool loading;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: double.infinity,
    child: FilledButton(
      onPressed: loading ? null : onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.redPrimary,
        foregroundColor: AppColors.white,
        disabledBackgroundColor: AppColors.redPrimary.withValues(alpha: 0.6),
        disabledForegroundColor: Colors.white70,
        minimumSize: const Size(0, 54),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      child: loading
          ? const SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(
                color: AppColors.white,
                strokeWidth: 2.5,
              ),
            )
          : Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
    ),
  );
}
