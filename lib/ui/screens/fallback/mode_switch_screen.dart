import 'package:flutter/material.dart';

class ModeSwitchScreen extends StatefulWidget {
  const ModeSwitchScreen({super.key});

  @override
  State<ModeSwitchScreen> createState() => _ModeSwitchScreenState();
}

class _ModeSwitchScreenState extends State<ModeSwitchScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeIn;

  static const Color _red = Color(0xFFC0392B);
  static const Color _pageBg = Color(0xFF1A1A1A);

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();

    _fadeIn = CurvedAnimation(parent: _controller, curve: Curves.easeIn);

    Future.delayed(const Duration(seconds: 3), () {
      if (!mounted) return;
      final args = ModalRoute.of(context)?.settings.arguments as String?;
      Navigator.of(
        context,
      ).pushNamedAndRemoveUntil(args ?? '/', (route) => false);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments as String?;
    final isGoingDelivery = args?.contains('delivery') ?? false;

    return Scaffold(
      backgroundColor: _pageBg,
      body: FadeTransition(
        opacity: _fadeIn,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: ClipOval(
                  child: Image.asset(
                    'assets/images/logo1.png',
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => const Icon(
                      Icons.storefront_outlined,
                      color: _red,
                      size: 36,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              Text(
                isGoingDelivery
                    ? 'Entrando no\nmodo entregador'
                    : 'Entrando no\nmodo cliente',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                isGoingDelivery
                    ? 'Preparando sua área de entregas...'
                    : 'Preparando sua experiência de compra...',
                style: const TextStyle(color: Colors.white38, fontSize: 13),
              ),
              const SizedBox(height: 40),
              const SizedBox(
                width: 28,
                height: 28,
                child: CircularProgressIndicator(strokeWidth: 2.5, color: _red),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
