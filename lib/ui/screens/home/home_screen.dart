import 'package:flutter/material.dart';
import 'dart:async';
import 'package:meatshop_mobile/ui/widgets/search_widget.dart';
import 'package:meatshop_mobile/routes/app_routes.dart';

class _Promocao {
  final String nome;
  final String preco;
  final String unidade;
  const _Promocao(this.nome, this.preco, this.unidade);
}

class _Acougue {
  final String nome;
  final double rating;
  const _Acougue(this.nome, this.rating);
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) => const HomeBody();
}

class HomeBody extends StatefulWidget {
  const HomeBody({super.key});

  @override
  State<HomeBody> createState() => _HomeBodyState();
}

class _HomeBodyState extends State<HomeBody> {
  static const Color _surface = Color(0xFF3A3A3A);
  static const Color _red = Color(0xFFC0392B);
  static const Color _white = Colors.white;

  final List<_Promocao> _promocoes = const [
    _Promocao('Picanha', 'R\$58,99', '/kg'),
    _Promocao('Peito de frango', 'R\$9,99', '/kg'),
    _Promocao('Lombo suíno', 'R\$17,99', '/kg'),
  ];

  final List<_Acougue> _acougues = const [
    _Acougue('Master Carnes', 4.5),
    _Acougue('Frigorífico Goiás', 3.5),
    _Acougue('Bom Beef', 3.0),
  ];

  final List<Map<String, dynamic>> _cortes = const [
    {'label': 'Bovino', 'icon': Icons.looks_one},
    {'label': 'Suíno', 'icon': Icons.looks_two},
    {'label': 'Frango', 'icon': Icons.looks_3},
    {'label': 'Peixe', 'icon': Icons.set_meal},
  ];

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: SizedBox(
            height: 130,
            child: Image.asset(
              'assets/images/background.png',
              fit: BoxFit.cover,
            ),
          ),
        ),
        SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              SearchWidget(
                controller: _searchController,
                hintText: 'Procure por produto ou estabelecimento',
                onSubmitted: (value) {},
              ),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),
                      _sectionTitle('CORTES'),
                      const SizedBox(height: 12),
                      _buildCortes(),
                      const SizedBox(height: 24),
                      _sectionTitle('PROMOÇÕES', redTitle: true),
                      const SizedBox(height: 12),
                      _buildPromocoes(),
                      const SizedBox(height: 24),
                      _sectionTitle('AÇOUGUES'),
                      const SizedBox(height: 12),
                      _buildAcougues(),
                      const SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.only(right: 16, bottom: 8),
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: GestureDetector(
                            onTap: () => Navigator.pushNamed(
                              context,
                              AppRoutes.acougues,
                            ),
                            child: const Text(
                              'Ver mais...',
                              style: TextStyle(
                                color: _red,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      color: Colors.transparent,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: const BoxDecoration(
              color: _white,
              shape: BoxShape.circle,
            ),
            child: ClipOval(
              child: Image.asset(
                'assets/images/logo1.png',
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => const Icon(
                  Icons.storefront_outlined,
                  color: _red,
                  size: 22,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          const Text(
            'MeatShop',
            style: TextStyle(
              color: _white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
          const Spacer(),
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              border: Border.all(color: _white, width: 1.5),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.help_outline, color: _white, size: 20),
          ),
        ],
      ),
    );
  }

  final TextEditingController _searchController = TextEditingController();

  Widget _sectionTitle(String title, {bool redTitle = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Text(
        title,
        style: TextStyle(
          color: redTitle ? _red : _white,
          fontSize: 20,
          fontWeight: FontWeight.w900,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildCortes() {
    final imagens = [
      'assets/images/vaca.png',
      'assets/images/porco.png',
      'assets/images/frango.png',
      'assets/images/peixe.png',
    ];

    final rotas = [
      AppRoutes.cortesBovinos,
      AppRoutes.cortesSuinos,
      AppRoutes.cortesAves,
      AppRoutes.cortesPeixes,
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(_cortes.length, (i) {
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: GestureDetector(
                onTap: () => Navigator.pushNamed(context, rotas[i]),
                child: Container(
                  height: 80,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE0E0E0),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Center(
                    child: Image.asset(
                      imagens[i],
                      width: 48,
                      height: 48,
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => const Icon(
                        Icons.image_not_supported_outlined,
                        color: Color(0xFF3A3A3A),
                        size: 30,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  final PageController _pageController = PageController(
    viewportFraction: 0.68,
    initialPage: 1000,
  );
  Timer? _autoScrollTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startAutoScroll();
    });
  }

  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    _pageController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _startAutoScroll() {
    _autoScrollTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (!_pageController.hasClients) return;
      _pageController.animateToPage(
        _pageController.page!.round() + 1,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    });
  }

  Widget _buildPromocoes() {
    final imagens = [
      'assets/images/picanha.png',
      'assets/images/peitodefrango.png',
      'assets/images/lombo.png',
    ];

    return Padding(
      padding: const EdgeInsets.only(left: 16),
      child: SizedBox(
        height: 210,
        child: PageView.builder(
          controller: _pageController,
          padEnds: false,
          itemCount: _promocoes.length,
          itemBuilder: (context, i) {
            final p = _promocoes[i % _promocoes.length];
            final img = imagens[i % imagens.length];
            return AnimatedBuilder(
              animation: _pageController,
              builder: (context, child) {
                double scale = 1.0;
                if (_pageController.position.haveDimensions) {
                  final diff = (_pageController.page! - i).abs();
                  scale = (1 - diff * 0.08).clamp(0.88, 1.0);
                }
                return Transform.scale(scale: scale, child: child);
              },
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF4A4A4A),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(16),
                        ),
                        child: Image.asset(
                          img,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            color: const Color(0xFF555555),
                            child: const Center(
                              child: Icon(
                                Icons.image_outlined,
                                color: Colors.white24,
                                size: 44,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(
                            child: RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: p.nome,
                                    style: const TextStyle(
                                      color: _white,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  TextSpan(
                                    text: ' ${p.unidade}',
                                    style: const TextStyle(
                                      color: Colors.white54,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Text(
                            p.preco,
                            style: const TextStyle(
                              color: _red,
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildAcougues() {
    return Column(
      children: _acougues.map((a) => _buildAcougueItem(a)).toList(),
    );
  }

  Widget _buildAcougueItem(_Acougue a) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, AppRoutes.butcherDetail),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: _surface,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFF555555),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.storefront_outlined,
                color: Colors.white38,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                a.nome,
                style: const TextStyle(
                  color: _white,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            _buildStars(a.rating),
          ],
        ),
      ),
    );
  }

  Widget _buildStars(double rating) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        final filled = i < rating.floor();
        final half = !filled && i < rating;
        return Icon(
          half
              ? Icons.star_half_rounded
              : (filled ? Icons.star_rounded : Icons.star_outline_rounded),
          color: const Color(0xFFFFB800),
          size: 20,
        );
      }),
    );
  }
}
