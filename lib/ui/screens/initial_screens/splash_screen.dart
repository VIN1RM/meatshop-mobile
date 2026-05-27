import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:flutter/material.dart';
import 'package:meatshop_mobile/providers/auth/auth_provider.dart';
import 'package:meatshop_mobile/ui/screens/initial_screens/welcome_screen.dart';
import 'package:meatshop_mobile/ui/widgets/loading_widget.dart';
import 'package:provider/provider.dart';

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
  bool _isReturningUser = false;

  @override
  void initState() {
    super.initState();
    _isReturningUser = FirebaseAuth.instance.currentUser != null;
    _checkSession();
  }

  Future<void> _checkSession() async {
    await Future.delayed(const Duration(milliseconds: 1500));
    if (!mounted) return;

    final firebaseUser = FirebaseAuth.instance.currentUser;

    if (firebaseUser == null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const WelcomePage()),
      );
      return;
    }

    try {
      await firebaseUser.getIdToken();
      if (!mounted) return;
      await context.read<AuthProvider>().restoreSession(context, firebaseUser);
    } catch (_) {
      await FirebaseAuth.instance.signOut();
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const WelcomePage()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final sw = size.width;
    final sh = size.height;
    final double fontScale = (sw / 390).clamp(0.60, 1.20);

    return Scaffold(
      backgroundColor: MeatShopColors.background,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Opacity(
            opacity: 1.0,
            child: Image.asset(
              'assets/images/background.png',
              fit: BoxFit.cover,
            ),
          ),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: EdgeInsets.only(
                    top: sh * 0.05,
                    left: sw * 0.06,
                    right: sw * 0.06,
                  ),
                  child: _WelcomeText(
                    fontScale: fontScale,
                    isReturningUser: _isReturningUser,
                  ),
                ),
                const Spacer(),
                Center(
                  child: MeatShopLoader(
                    color: MeatShopColors.grey500,
                    dotSize: sw * 0.03,
                    spacing: sw * 0.015,
                  ),
                ),
                const Spacer(),
                Center(
                  child: Padding(
                    padding: EdgeInsets.only(bottom: sh * 0.06),
                    child: Image.asset(
                      'assets/images/logo_delivery.png',
                      height: sh * 0.30,
                      fit: BoxFit.contain,
                    ),
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
  final bool isReturningUser;

  const _WelcomeText({required this.fontScale, required this.isReturningUser});

  @override
  Widget build(BuildContext context) {
    final title = isReturningUser ? 'BEM VINDO\nDE VOLTA' : 'BEM VINDO';
    final subtitle = isReturningUser
        ? 'Que bom ter você aqui novamente!'
        : 'Encontre os melhores cortes perto de você.';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            style: TextStyle(
              fontSize: 26 * fontScale,
              fontWeight: FontWeight.bold,
              color: MeatShopColors.grey900,
              letterSpacing: 0.5,
            ),
            children: [
              const TextSpan(text: 'SEJA '),
              TextSpan(
                text: title,
                style: const TextStyle(color: MeatShopColors.redPrimary),
              ),
              const TextSpan(text: '!'),
            ],
          ),
        ),
        SizedBox(height: 6 * fontScale),
        Text(
          subtitle,
          textAlign: TextAlign.center,
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
