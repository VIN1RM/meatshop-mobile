import 'package:flutter/material.dart';

class AppRefresh extends StatelessWidget {
  const AppRefresh({
    super.key,
    required this.onRefresh,
    required this.child,
  });

  final Future<void> Function() onRefresh;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      color: const Color(0xFFC0392B),
      backgroundColor: const Color(0xFFF5F5F5),
      strokeWidth: 2.5,
      displacement: 40,
      child: child,
    );
  }
}