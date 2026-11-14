import 'package:flutter/material.dart';

class CheckoutStepHeader extends StatelessWidget {
  const CheckoutStepHeader({super.key, required this.title});
  final String title;
  @override
  Widget build(BuildContext context) => Row(
    children: [
      IconButton.outlined(
        tooltip: 'Voltar',
        onPressed: () => Navigator.maybePop(context),
        style: IconButton.styleFrom(
          foregroundColor: Colors.white,
          side: const BorderSide(color: Colors.white54),
        ),
        icon: const Icon(Icons.arrow_back, size: 20),
      ),
      const SizedBox(width: 12),
      Expanded(
        child: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w900,
            letterSpacing: 1,
          ),
        ),
      ),
    ],
  );
}
