import 'package:flutter/material.dart';
import 'package:meatshop_mobile/main.dart';

enum SnackBarType { success, error, warning, info, neutral }

class CustomSnackBar {
  static Color _colorFor(SnackBarType type) => switch (type) {
        SnackBarType.success => const Color(0xFF2E7D32),
        SnackBarType.error => Colors.redAccent,
        SnackBarType.warning => Colors.orange,
        SnackBarType.info => const Color(0xFF0072E4),
        SnackBarType.neutral => Colors.black87,
      };

  static IconData _iconFor(SnackBarType type) => switch (type) {
        SnackBarType.success => Icons.check_circle_outline,
        SnackBarType.error => Icons.error_outline,
        SnackBarType.warning => Icons.warning_amber_rounded,
        SnackBarType.info => Icons.info_outline,
        SnackBarType.neutral => Icons.notifications_none,
      };

  static void show(
    SnackBarType type,
    String message, {
    BuildContext? context,
    Duration duration = const Duration(seconds: 3),
    SnackBarAction? action,
    Widget? leadingIcon,
  }) {
    final ctx = context ?? navigatorKey.currentContext;
    if (ctx == null) return;

    final messenger = ScaffoldMessenger.maybeOf(ctx);
    if (messenger == null) return;

    final color = _colorFor(type);
    final icon =
        leadingIcon ?? Icon(_iconFor(type), color: Colors.white, size: 20);

    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        backgroundColor: color,
        duration: duration,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        action: action,
        content: Row(
          children: [
            icon,
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  fontFamily: 'Karla',
                  fontSize: 14,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static void success(String message,
          {BuildContext? context, Widget? leadingIcon}) =>
      show(SnackBarType.success, message,
          context: context, leadingIcon: leadingIcon);

  static void warning(String message,
          {BuildContext? context, Widget? leadingIcon}) =>
      show(SnackBarType.warning, message,
          context: context, leadingIcon: leadingIcon);

  static void info(String message,
          {BuildContext? context, Widget? leadingIcon}) =>
      show(SnackBarType.info, message,
          context: context, leadingIcon: leadingIcon);

  static void error(String message,
          {BuildContext? context, Widget? leadingIcon}) =>
      show(SnackBarType.error, message,
          context: context, leadingIcon: leadingIcon);

  static void neutral(String message,
          {BuildContext? context, Widget? leadingIcon}) =>
      show(SnackBarType.neutral, message,
          context: context, leadingIcon: leadingIcon);

  @Deprecated('Use CustomSnackBar.show() com SnackBarType')
  static void showSnackBar(
    BuildContext context,
    String message,
    Color color, {
    Duration duration = const Duration(seconds: 2),
    SnackBarAction? action,
  }) {
    if (!context.mounted) return;
    final messenger = ScaffoldMessenger.maybeOf(context);
    if (messenger == null) return;
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: duration,
        action: action,
      ),
    );
  }
}
