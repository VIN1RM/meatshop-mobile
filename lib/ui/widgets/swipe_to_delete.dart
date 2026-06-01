import 'package:flutter/material.dart';

class SwipeToDelete extends StatelessWidget {
  final Widget child;
  final Future<bool> Function() onSwipe;

  const SwipeToDelete({
    super.key,
    required this.child,
    required this.onSwipe,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Dismissible(
        key: UniqueKey(),
        direction: DismissDirection.endToStart,
        confirmDismiss: (_) => onSwipe(),
        resizeDuration: null,
        background: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 20),
          color: const Color(0xFFC0392B),
          child: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.delete_outline, color: Colors.white, size: 26),
              SizedBox(height: 4),
              Text(
                'Remover',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        child: child,
      ),
    );
  }
}