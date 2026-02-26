import 'dart:async';
import 'package:flutter/material.dart';
import 'package:meatshop_mobile/ui/screens/initial_screens/welcome_screen.dart';
import 'package:meatshop_mobile/ui/widgets/loading_widget.dart';

class MeatShopColors {
  MeatShopColors._();

  static const Color redDark = Color(0xFF8B1A1A);
  static const Color redPrimary = Color(0xFFC0392B);
  static const Color redMedium = Color(0xFFE05A4E);
  static const Color redBright = Color(0xFFFF3B1F);
  static const Color grey900 = Color(0xFF1C1C1C);
  static const Color grey700 = Color(0xFF4A4A4A);
  static const Color grey500 = Color(0xFF7A7A7A);
  static const Color grey200 = Color(0xFFD4D4D4);
  static const Color background = Color(0xFFF2F2F2);
}

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 3), () {
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const WelcomePage()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final sw = size.width;
    final sh = size.height;

    final double fontScale = (sw / 390).clamp(0.80, 1.20);

    return Scaffold(
      backgroundColor: MeatShopColors.background,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Opacity(
            opacity: 0.08,
            child: Image.asset(
              'assets/images/background.png',
              fit: BoxFit.cover,
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.only(
                    top: sh * 0.05,
                    left: sw * 0.06,
                    right: sw * 0.06,
                  ),
                  child: _WelcomeText(fontScale: fontScale),
                ),

                const Spacer(),
                MeatShopLoader(
                  color: MeatShopColors.grey500,
                  dotSize: sw * 0.03,
                  spacing: sw * 0.015,
                ),
                const Spacer(),

                Padding(
                  padding: EdgeInsets.only(bottom: sh * 0.05),
                  child: Image.asset(
                    'assets/images/logo1.png',
                    height: sh * 0.10,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _WelcomeText extends StatelessWidget {
  final double fontScale;
  const _WelcomeText({required this.fontScale});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            style: TextStyle(
              fontSize: 26 * fontScale,
              fontWeight: FontWeight.bold,
              color: MeatShopColors.grey900,
              letterSpacing: 0.5,
            ),
            children: const [
              TextSpan(text: 'SEJA '),
              TextSpan(
                text: 'BEM VINDO',
                style: TextStyle(color: MeatShopColors.redPrimary),
              ),
              TextSpan(text: '!'),
            ],
          ),
        ),
        SizedBox(height: 6 * fontScale),
        Text(
          'Sentimos sua falta.',
          style: TextStyle(
            fontSize: 18 * fontScale,
            fontWeight: FontWeight.w600,
            color: MeatShopColors.grey700,
          ),
        ),
      ],
    );
  }
}
