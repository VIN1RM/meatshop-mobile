import 'dart:async';
import 'package:flutter/material.dart';
import 'package:meatshop_mobile/routes/app_routes.dart';
import 'package:meatshop_mobile/services/onboarding_service.dart';
import 'package:meatshop_mobile/ui/screens/onboarding/onboarding_screen.dart';
import 'package:meatshop_mobile/ui/widgets/buttons_widget.dart';

class _CarouselItem {
  final String path;
  final Alignment alignment;
  const _CarouselItem({required this.path, required this.alignment});
}

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  final List<_CarouselItem> _images = const [
    _CarouselItem(
      path: 'assets/images/person1.png',
      alignment: Alignment.topCenter,
    ),
    _CarouselItem(
      path: 'assets/images/person2.png',
      alignment: Alignment.topCenter,
    ),
    _CarouselItem(
      path: 'assets/images/person3.png',
      alignment: Alignment.topCenter,
    ),
    _CarouselItem(
      path: 'assets/images/person4.png',
      alignment: Alignment.topCenter,
    ),
    _CarouselItem(
      path: 'assets/images/person5.png',
      alignment: Alignment(0.0, -0.6),
    ),
    _CarouselItem(
      path: 'assets/images/person6.png',
      alignment: Alignment(1.0, 0.0),
    ),
    _CarouselItem(
      path: 'assets/images/person7.png',
      alignment: Alignment.topCenter,
    ),
    _CarouselItem(
      path: 'assets/images/person8.png',
      alignment: Alignment.topCenter,
    ),
    _CarouselItem(
      path: 'assets/images/person9.png',
      alignment: Alignment.topCenter,
    ),
    _CarouselItem(
      path: 'assets/images/person10.png',
      alignment: Alignment.topCenter,
    ),
    _CarouselItem(
      path: 'assets/images/person13.png',
      alignment: Alignment.topCenter,
    ),
  ];

  static const int _multiplier = 1000;
  late final PageController _pageController;
  Timer? _carouselTimer;
  late final Future<bool> _introduction;

  @override
  void initState() {
    super.initState();
    final int initialPage = _images.length * (_multiplier ~/ 2);
    _pageController = PageController(initialPage: initialPage);

    _introduction = OnboardingService().shouldShowIntroduction();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _carouselTimer?.cancel();
    if (MediaQuery.disableAnimationsOf(context)) return;
    _carouselTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (!mounted ||
          !_pageController.hasClients ||
          ModalRoute.of(context)?.isCurrent != true ||
          WidgetsBinding.instance.lifecycleState == AppLifecycleState.paused) {
        return;
      }
      final next = (_pageController.page?.round() ?? 0) + 1;
      if (next >= _images.length * _multiplier) {
        _pageController.jumpToPage(_images.length * (_multiplier ~/ 2));
      } else {
        _pageController.animateToPage(
          next,
          duration: const Duration(milliseconds: 700),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _carouselTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  Widget _carouselImage(_CarouselItem item) {
    return Image.asset(
      item.path,
      fit: BoxFit.cover,
      alignment: item.alignment,
      errorBuilder: (_, _, _) => Container(color: const Color(0xFF2A2A2A)),
    );
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<bool>(
    future: _introduction,
    builder: (context, snapshot) {
      if (snapshot.connectionState != ConnectionState.done) {
        return const Scaffold(
          backgroundColor: AppColors.darkSurface,
          body: Center(child: CircularProgressIndicator(color: Colors.white)),
        );
      }
      if (snapshot.hasError) {
        return Scaffold(
          backgroundColor: AppColors.darkSurface,
          body: SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: PrimaryButton(
                  label: 'TENTAR NOVAMENTE',
                  onPressed: () => Navigator.pushReplacementNamed(
                    context,
                    AppRoutes.welcome,
                  ),
                ),
              ),
            ),
          ),
        );
      }
      if (snapshot.data == true) return const OnboardingScreen();
      return _buildWelcome(context);
    },
  );

  Widget _buildWelcome(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final sw = size.width;
    final sh = size.height;

    final double fontScale = (sw / 390).clamp(0.80, 1.20);

    final double carouselRatio = sh < 700
        ? 0.50
        : sh > 900
        ? 0.58
        : 0.55;

    return Scaffold(
      backgroundColor: const Color(0xFF424242),
      body: SafeArea(
        child: Column(
          children: [
            Stack(
              children: [
                SizedBox(
                  height: sh * carouselRatio,
                  width: sw,
                  child: PageView.builder(
                    controller: _pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _images.length * _multiplier,
                    itemBuilder: (_, index) {
                      return _carouselImage(_images[index % _images.length]);
                    },
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
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  sw * 0.07,
                  sh * 0.02,
                  sw * 0.07,
                  sh * 0.05,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: sh * 0.03),

                    Text(
                      'Bem-vindo ao MeatShop!',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 26 * fontScale,
                        fontWeight: FontWeight.bold,
                        height: 1.25,
                      ),
                    ),

                    SizedBox(height: sh * 0.018),

                    Text(
                      'O MeatShop conecta clientes, açougues e entregadores em uma plataforma prática e segura.',
                      textAlign: TextAlign.justify,
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 15 * fontScale,
                        height: 1.6,
                      ),
                    ),

                    SizedBox(height: sh * 0.018),

                    Text(
                      'Crie sua conta para pedir ou entregar. Já tem cadastro? Entre para continuar.',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 13 * fontScale,
                        fontStyle: FontStyle.italic,
                      ),
                    ),

                    SizedBox(height: sh * 0.035),

                    PrimaryButton(
                      label: 'CRIAR CONTA',
                      onPressed: () => Navigator.pushNamed(
                        context,
                        AppRoutes.selectRegister,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Center(
                      child: TextButton(
                        onPressed: () =>
                            Navigator.pushNamed(context, AppRoutes.login),
                        child: const Text(
                          'Já tenho conta',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                    Center(
                      child: TextButton(
                        onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) =>
                                const OnboardingScreen(review: true),
                          ),
                        ),
                        child: const Text(
                          'Conhecer o MeatShop',
                          style: TextStyle(color: Colors.white70),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
