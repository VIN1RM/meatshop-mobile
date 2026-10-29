import 'package:flutter/material.dart';

class ChatLoadError extends StatelessWidget {
  const ChatLoadError({
    super.key,
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(16),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.white),
        ),
        TextButton(
          onPressed: onRetry,
          child: const Text(
            'Tentar novamente',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ],
    ),
  );
}
