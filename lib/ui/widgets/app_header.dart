import 'package:flutter/material.dart';

class AppHeader extends StatelessWidget {
  final bool showBack;

  const AppHeader({
    super.key,
    this.showBack = false,
  });

  static const Color _red = Color(0xFFC0392B);
  static const Color _white = Colors.white;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (showBack)
            Align(
              alignment: Alignment.centerLeft,
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    border: Border.all(color: _white, width: 1.5),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.arrow_back,
                    color: _white,
                    size: 20,
                  ),
                ),
              ),
            ),

          Image.asset(
            'assets/images/logo.png',
            width: 64,
            height: 64,
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => const Icon(
              Icons.storefront_outlined,
              color: _red,
              size: 30,
            ),
          ),
        ],
      ),
    );
  }
}