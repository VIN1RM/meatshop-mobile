import 'dart:async';
import 'package:flutter/material.dart';
import 'package:meatshop_mobile/ui/widgets/buttons_widget.dart';

// import 'package:meatshop_mobile/ui/screens/auth/login_screen.dart';

// Classe simples para guardar caminho + alinhamento de cada imagem
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
  // ─────────────────────────────────────────────────────────────────────────
  // Para ajustar o enquadramento de cada imagem, edite o alignment:
  //   Alignment.topCenter      → topo
  //   Alignment.center         → centro
  //   Alignment(0.0, -0.6)     → entre -1.0 (topo) e 1.0 (base)
  // ─────────────────────────────────────────────────────────────────────────
  final List<_CarouselItem> _images = const [
    _CarouselItem(path: 'assets/images/person1.png', alignment: Alignment.topCenter),
    _CarouselItem(path: 'assets/images/person3.png', alignment: Alignment.topCenter),
    _CarouselItem(path: 'assets/images/person4.png', alignment: Alignment.topCenter),
    _CarouselItem(path: 'assets/images/person5.png', alignment: Alignment(0.0, -0.6)), // ajuste fino
    _CarouselItem(path: 'assets/images/person6.png', alignment: Alignment.topCenter),
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

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      body: Column(
        children: [
          // ── 1. Carrossel automático e infinito ──────────────────────────
          Stack(
            children: [
              SizedBox(
                height: size.height * 0.55,
                width: size.width,
                child: PageView.builder(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _images.length * _multiplier,
                  itemBuilder: (_, index) {
                    return _carouselImage(_images[index % _images.length]);
                  },
                ),
              ),

              // Gradiente na borda inferior da imagem
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                height: 120,
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

          // ── 2. Painel de texto ──────────────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(28, 16, 28, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 30),

                  const Text(
                    'Bem Vindo ao Meatshop!',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      height: 1.25,
                    ),
                  ),

                  const SizedBox(height: 14),

                  const Text(
                    'O MeatShop conecta clientes, açougues e entregadores em uma plataforma prática e segura.',
                    textAlign: TextAlign.justify,
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 15,
                      height: 1.6,
                    ),
                  ),

                  const SizedBox(height: 15),

                  const Text(
                    'Escolha seu perfil e comece agora.',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                      fontStyle: FontStyle.italic,
                    ),
                  ),

                  const SizedBox(height: 28),

                  PrimaryButton(
                    label: 'Login',
                    onPressed: () {
                      // Navigator.pushReplacement(context,
                      //   MaterialPageRoute(builder: (_) => const LoginPage()));
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}