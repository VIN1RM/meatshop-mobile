import 'package:flutter/material.dart';

class AppBarCurved extends StatelessWidget {
  const AppBarCurved({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 20,
      width: double.infinity,
      child: CustomPaint(painter: _AppBarCurvedPainter()),
    );
  }
}

class _AppBarCurvedPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF010D28)
      ..style = PaintingStyle.fill;

    final path = Path();

    path.lineTo(0, size.height);

    path.quadraticBezierTo(10, 0, 40, 0);

    path.lineTo(size.width - 40, 0);

    path.quadraticBezierTo(size.width - 10, 0, size.width, size.height);

    path.lineTo(size.width, 0);
    path.lineTo(0, 0);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
