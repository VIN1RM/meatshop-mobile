import 'dart:math';
import 'package:flutter/material.dart';

class MeatShopLoader extends StatefulWidget {
  final Color color;
  final double dotSize;
  final double spacing;

  const MeatShopLoader({
    super.key,
    this.color = const Color(0xFFC0392B),
    this.dotSize = 10.0,
    this.spacing = 6.0,
  });

  @override
  State<MeatShopLoader> createState() => _MeatShopLoaderState();
}

class _MeatShopLoaderState extends State<MeatShopLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (index) {
            final double phase = (index * 0.2);
            final double animValue = (_controller.value - phase).clamp(
              0.0,
              1.0,
            );

            final double scale = 0.5 + 0.5 * sin(animValue * pi);

            return Container(
              margin: EdgeInsets.symmetric(horizontal: widget.spacing / 2),
              child: Transform.scale(
                scale: scale,
                child: Container(
                  width: widget.dotSize,
                  height: widget.dotSize,
                  decoration: BoxDecoration(
                    color: widget.color.withOpacity(0.4 + 0.6 * scale),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}
