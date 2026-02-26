import 'dart:async';
import 'package:flutter/material.dart';
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
      alignment: Alignment.topCenter,
    ),
  ];

  static const int _multiplier = 1000;
  late final PageController _pageController;
  Timer? _carouselTimer;

  @override
  void initState() {
    super.initState();
    final int initialPage = _images.length * (_multiplier ~/ 2);
    _pageController = PageController(initialPage: initialPage);

    _carouselTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (!mounted) return;
      _pageController.nextPage(
        duration: const Duration(milliseconds: 700),
        curve: Curves.easeInOut,
      );
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
      errorBuilder: (_, __, ___) => Container(color: const Color(0xFF2A2A2A)),
    );
  }

  @override
  Widget build(BuildContext context) {
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
      backgroundColor: const Color(0xFF1A1A1A),
      body: Column(
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
                      colors: [Colors.transparent, Color(0xFF1A1A1A)],
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
                    'Bem Vindo ao Meatshop!',
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
                    'Escolha seu perfil e comece agora.',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 13 * fontScale,
                      fontStyle: FontStyle.italic,
                    ),
                  ),

                  SizedBox(height: sh * 0.035),

                  PrimaryButton(label: 'Login', onPressed: () {}),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
