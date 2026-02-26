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

  // Cinzas
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

          // ── 2. Conteúdo principal ──────────────────────────────────────
          SafeArea(
            child: Column(
              children: [
                // Texto de boas-vindas — topo
                const Padding(
                  padding: EdgeInsets.only(top: 48.0, left: 24.0, right: 24.0),
                  child: _WelcomeText(),
                ),

                // Loader — centro
                const Spacer(),
                const MeatShopLoader(
                  color: MeatShopColors.grey500,
                  dotSize: 12,
                  spacing: 6,
                ),
                const Spacer(),

                // Logo — rodapé
                Padding(
                  padding: const EdgeInsets.only(bottom: 48.0),
                  child: Image.asset(
                    'assets/images/logo1.png',
                    height: 80,
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

/// Bloco de texto "SEJA BEM VINDO! / Sentimos sua falta."
class _WelcomeText extends StatelessWidget {
  const _WelcomeText();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: const TextSpan(
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: MeatShopColors.grey900,
              letterSpacing: 0.5,
            ),
            children: [
              TextSpan(text: 'SEJA '),
              TextSpan(
                text: 'BEM VINDO',
                style: TextStyle(color: MeatShopColors.redPrimary),
              ),
              TextSpan(text: '!'),
            ],
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Sentimos sua falta.',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: MeatShopColors.grey700,
          ),
        ),
      ],
    );
  }
}
