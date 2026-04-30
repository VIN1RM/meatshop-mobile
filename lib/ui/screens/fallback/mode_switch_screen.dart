import 'package:flutter/material.dart';

class ModeSwitchScreen extends StatefulWidget {
  const ModeSwitchScreen({super.key});

  @override
  State<ModeSwitchScreen> createState() => _ModeSwitchScreenState();
}

class _ModeSwitchScreenState extends State<ModeSwitchScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _fadeController;
  late final Animation<double> _fadeIn;

  static const Color _red = Color(0xFFC0392B);

  static const _deliveryImages = ['assets/images/person11.png'];
  static const _clientImages = ['assets/images/person12.png'];

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..forward();

    _fadeIn = CurvedAnimation(parent: _fadeController, curve: Curves.easeIn);

    Future.delayed(const Duration(seconds: 5), () {
      if (!mounted) return;
      final args = ModalRoute.of(context)?.settings.arguments as String?;
      Navigator.of(
        context,
      ).pushNamedAndRemoveUntil(args ?? '/', (route) => false);
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments as String?;
    final isGoingDelivery = args?.contains('delivery') ?? false;
    final images = isGoingDelivery ? _deliveryImages : _clientImages;

    final size = MediaQuery.of(context).size;
    final sh = size.height;
    final sw = size.width;

    final double carouselRatio = sh < 700
        ? 0.50
        : sh > 900
        ? 0.58
        : 0.55;

    return Scaffold(
      backgroundColor: const Color(0xFF424242),
      body: FadeTransition(
        opacity: _fadeIn,
        child: Column(
          children: [
            Stack(
              children: [
                SizedBox(
                  height: sh * carouselRatio,
                  width: sw,
                  child: Image.asset(
                    images[0],
                    fit: BoxFit.cover,
                    alignment: Alignment.topCenter,
                    errorBuilder: (_, __, ___) =>
                        Container(color: const Color(0xFF2A2A2A)),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  height: sh * 0.14,
                  child: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Color(0xFF424242)],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Expanded(
              child: Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: sw * 0.07),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/images/logo.png',
                        width: 100,
                        height: 100,
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => const Icon(
                          Icons.storefront_outlined,
                          color: _red,
                          size: 36,
                        ),
                      ),
                      const SizedBox(height: 24),
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
                      const SizedBox(height: 12),
                      Text(
                        isGoingDelivery
                            ? 'Preparando sua área de entregas...'
                            : 'Preparando sua experiência de compra...',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 32),
                      const SizedBox(
                        width: 28,
                        height: 28,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: _red,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
