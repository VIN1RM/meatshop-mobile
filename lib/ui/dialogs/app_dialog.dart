import 'package:flutter/material.dart';
import '../widgets/app_surface.dart';
import '../widgets/buttons_widget.dart';

class AppDialog extends StatelessWidget {
  const AppDialog({
    super.key,
    required this.title,
    required this.icon,
    required this.content,
    this.description,
    this.actions = const [],
  });
  final String title;
  final IconData icon;
  final String? description;
  final Widget content;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) => Theme(
    data: appSurfaceTheme(context),
    child: Dialog(
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    backgroundColor: const Color(0xFFF8E9E7),
                    child: Icon(icon, color: AppColors.redPrimary),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.w800,
                          color: AppColors.dark,
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    tooltip: 'Fechar',
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: AppColors.dark),
                  ),
                ],
              ),
              if (description != null) ...[
                const SizedBox(height: 14),
                Text(
                  description!,
                  style: const TextStyle(color: Color(0xFF555555), height: 1.5),
                ),
              ],
              const SizedBox(height: 20),
              content,
              if (actions.isNotEmpty) ...[
                const SizedBox(height: 20),
                Wrap(
                  alignment: WrapAlignment.end,
                  spacing: 12,
                  runSpacing: 8,
                  children: actions,
                ),
              ],
            ],
          ),
        ),
      ),
    ),
  );
}
