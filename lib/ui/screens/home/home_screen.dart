import 'package:flutter/material.dart';
import 'dart:async';

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

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

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
    {'label': 'Bovino', 'icon': Icons.local_dining},
    {'label': 'Suíno', 'icon': Icons.set_meal},
    {'label': 'Frango', 'icon': Icons.egg_alt},
    {'label': 'Peixe', 'icon': Icons.set_meal_outlined},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Image.asset(
              'assets/images/background.png',
              fit: BoxFit.fitWidth,
            ),
          ),
          SafeArea(
            child: IndexedStack(
              index: _currentIndex,
              children: [
                _buildHomeTab(),
                _buildPlaceholderTab(Icons.shopping_cart_outlined, 'Carrinho'),
                _buildPlaceholderTab(Icons.receipt_long_outlined, 'Pedidos'),
                _buildPlaceholderTab(Icons.person_outline, 'Minha Conta'),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildHomeTab() {
    return Column(
      children: [
        _buildHeader(),
        _buildSearchBar(),
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
                      onTap: () {},
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
    );
  }

  Widget _buildHeader() {
    return Container(
      color: _surface,
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
            child: const Icon(Icons.storefront_outlined, color: _red, size: 22),
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

  Widget _buildSearchBar() {
    return Container(
      color: const Color(0xFF3A3A3A),
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: TextField(
        controller: _searchController,
        style: const TextStyle(color: _white, fontSize: 14),
        cursorColor: _red,
        decoration: InputDecoration(
          hintText: 'Procure por produto ou estabelecimento',
          hintStyle: const TextStyle(color: Colors.white38, fontSize: 14),
          prefixIcon: const Icon(Icons.search, color: Colors.white38, size: 20),
          suffixIcon: ValueListenableBuilder(
            valueListenable: _searchController,
            builder: (_, value, __) => value.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(
                      Icons.close,
                      color: Colors.white38,
                      size: 18,
                    ),
                    onPressed: () => _searchController.clear(),
                  )
                : const SizedBox.shrink(),
          ),
          filled: true,
          fillColor: const Color(0xFF4A4A4A),
          contentPadding: const EdgeInsets.symmetric(vertical: 10),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
        ),
        onSubmitted: (value) {},
      ),
    );
  }

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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: _cortes.map((corte) {
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: GestureDetector(
                onTap: () {},
                child: Container(
                  height: 80,
                  decoration: BoxDecoration(
                    color: const Color(0xFF4A4A4A),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(corte['icon'] as IconData, color: _white, size: 30),
                      const SizedBox(height: 6),
                      Text(
                        corte['label'] as String,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  final PageController _pageController = PageController(
    viewportFraction: 0.68,
    initialPage: 0,
  );
  Timer? _autoScrollTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startAutoScroll();
    });
  }

  void _startAutoScroll() {
    _autoScrollTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (!_pageController.hasClients) return;
      final nextPage = (_pageController.page!.round() + 1) % _promocoes.length;
      _pageController.animateToPage(
        nextPage,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    _pageController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Widget _buildPromocoes() {
    return Padding(
      padding: const EdgeInsets.only(left: 16),
      child: SizedBox(
        height: 210,
        child: PageView.builder(
          controller: _pageController,
          padEnds: false,
          itemCount: _promocoes.length,
          itemBuilder: (context, i) {
            final p = _promocoes[i];
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
                      child: Container(
                        decoration: const BoxDecoration(
                          color: Color(0xFF555555),
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(16),
                          ),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.image_outlined,
                            color: Colors.white24,
                            size: 44,
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: p.nome,
                                  style: const TextStyle(
                                    color: _white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                TextSpan(
                                  text: ' ${p.unidade}',
                                  style: const TextStyle(
                                    color: Colors.white54,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            p.preco,
                            style: const TextStyle(
                              color: _red,
                              fontSize: 16,
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
    return Container(
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

  Widget _buildPlaceholderTab(IconData icon, String label) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white38, size: 56),
          const SizedBox(height: 12),
          Text(
            label,
            style: const TextStyle(color: Colors.white38, fontSize: 16),
          ),
          const SizedBox(height: 6),
          const Text(
            'Em breve',
            style: TextStyle(color: Colors.white24, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    final items = const [
      {
        'label': 'Início',
        'icon': Icons.home_outlined,
        'activeIcon': Icons.home,
      },
      {
        'label': 'Carrinho',
        'icon': Icons.shopping_cart_outlined,
        'activeIcon': Icons.shopping_cart,
      },
      {
        'label': 'Pedidos',
        'icon': Icons.receipt_long_outlined,
        'activeIcon': Icons.receipt_long,
      },
      {
        'label': 'Minha conta',
        'icon': Icons.person_outline,
        'activeIcon': Icons.person,
      },
    ];

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF3A3A3A),
        border: Border(top: BorderSide(color: Color(0xFF555555), width: 0.5)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(items.length, (i) {
              final item = items[i];
              final isActive = _currentIndex == i;
              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => setState(() => _currentIndex = i),
                child: SizedBox(
                  width: 72,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        isActive
                            ? item['activeIcon'] as IconData
                            : item['icon'] as IconData,
                        color: isActive ? _red : Colors.white54,
                        size: 26,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item['label'] as String,
                        style: TextStyle(
                          color: isActive ? _red : Colors.white54,
                          fontSize: 10.5,
                          fontWeight: isActive
                              ? FontWeight.w700
                              : FontWeight.normal,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
