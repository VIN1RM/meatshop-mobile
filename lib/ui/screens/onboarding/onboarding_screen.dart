import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:meatshop_mobile/ui/widgets/buttons_widget.dart';

class OnboardingSlide {
  final String title;
  final String description;
  final IconData icon;
  const OnboardingSlide({
    required this.title,
    required this.description,
    required this.icon,
  });
}

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  static const String prefsKey = 'hasSeenOnboarding';

  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingSlide> _slides = const [
    OnboardingSlide(
      title: 'Escolha seu acougue',
      description:
          'Veja os açougues disponíveis perto de você, com produtos, promoções e avaliações.',
      icon: Icons.storefront_outlined,
    ),
    OnboardingSlide(
      title: 'Monte seu pedido',
      description:
          'Adicione carnes e produtos ao carrinho, filtre por categoria, preço e marca.',
      icon: Icons.shopping_cart_outlined,
    ),
    OnboardingSlide(
      title: 'Agende sua entrega',
      description:
          'Escolha o melhor dia e horário, ou receba agora mesmo com entrega imediata.',
      icon: Icons.calendar_month_outlined,
    ),
    OnboardingSlide(
      title: 'Acompanhe em tempo real',
      description:
          'Saiba exatamente onde seu pedido está, do preparo até a porta da sua casa.',
      icon: Icons.delivery_dining_outlined,
    ),
  ];

  Future<void> _finish() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(prefsKey, true);
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  void _nextPage() {
    if (_currentPage == _slides.length - 1) {
      _finish();
      return;
    }
    _pageController.nextPage(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isLastPage = _currentPage == _slides.length - 1;

    return Scaffold(
      backgroundColor: const Color(0xFF424242),
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: TextButton(
                  onPressed: _finish,
                  child: const Text(
                    'Pular',
                    style: TextStyle(color: Colors.white70),
                  ),
                ),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _slides.length,
                onPageChanged: (index) => setState(() => _currentPage = index),
                itemBuilder: (_, index) {
                  final slide = _slides[index];
                  return Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: size.width * 0.08,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(slide.icon, size: 96, color: Colors.white),
                        const SizedBox(height: 32),
                        Text(
                          slide.title,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          slide.description,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 15,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _slides.length,
                (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _currentPage == index ? 20 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _currentPage == index
                        ? Colors.white
                        : Colors.white30,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(
                size.width * 0.08,
                24,
                size.width * 0.08,
                24,
              ),
              child: PrimaryButton(
                label: isLastPage ? 'COMECAR' : 'PROXIMO',
                onPressed: _nextPage,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
