import 'package:flutter/material.dart';
import 'package:meatshop_mobile/models/product_model.dart';
import 'package:meatshop_mobile/providers/promotion_provider.dart';
import 'package:meatshop_mobile/ui/widgets/loading_widget.dart';
import 'dart:async';
import 'package:meatshop_mobile/ui/widgets/search_widget.dart';
import 'package:meatshop_mobile/ui/widgets/app_header.dart';
import 'package:meatshop_mobile/routes/app_routes.dart';
import 'package:provider/provider.dart';
import 'package:meatshop_mobile/providers/unit/unit_provider.dart';
import 'package:meatshop_mobile/models/unit_model.dart';
import 'package:meatshop_mobile/providers/user/user_provider.dart';

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
  static const Color _surface = Color.fromARGB(255, 58, 58, 58);
  static const Color _red = Color(0xFFC0392B);
  static const Color _white = Colors.white;

  final List<Map<String, dynamic>> _cortes = const [
    {'label': 'Bovino', 'icon': Icons.looks_one},
    {'label': 'Suíno', 'icon': Icons.looks_two},
    {'label': 'Frango', 'icon': Icons.looks_3},
    {'label': 'Peixe', 'icon': Icons.set_meal},
  ];

  final TextEditingController _searchController = TextEditingController();

  final PageController _pageController = PageController(
    viewportFraction: 0.68,
    initialPage: 1000,
  );
  Timer? _autoScrollTimer;

  late Future<void> _loader;

  @override
  void initState() {
    super.initState();
    _loader = Future.microtask(() async {
      await Future.wait([
        context.read<UnitProvider>().loadUnits(),
        context.read<PromotionProvider>().loadPromotions(),
      ]);
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => _startAutoScroll());
  }

  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    _pageController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _startAutoScroll() {
    _autoScrollTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (!_pageController.hasClients) return;
      _pageController.animateToPage(
        _pageController.page!.round() + 1,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _loader,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            backgroundColor: Color(0xFF3A3A3A),
            body: Center(child: MeatShopLoader()),
          );
        }
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
                  const AppHeader(),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                    child: Consumer<UserProvider>(
                      builder: (context, userProvider, _) {
                        final name =
                            userProvider.user?.name.split(' ').first ?? '';
                        return Text(
                          name.isNotEmpty
                              ? '${_greeting()}, $name 👋'
                              : '${_greeting()}! 👋',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        );
                      },
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pushNamed(context, AppRoutes.search),
                    child: AbsorbPointer(
                      child: SearchWidget(
                        controller: _searchController,
                        hintText: 'Procure por produto ou estabelecimento',
                      ),
                    ),
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
                          _sectionTitle('PROMOÇÕES'),
                          const SizedBox(height: 12),
                          _buildPromocoes(),
                          const SizedBox(height: 24),
                          _sectionTitle('AÇOUGUES'),
                          const SizedBox(height: 12),
                          _buildAcougues(),
                          const SizedBox(height: 16),
                          Padding(
                            padding: const EdgeInsets.only(
                              right: 16,
                              bottom: 8,
                            ),
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
                                    color: Color.fromARGB(255, 255, 255, 255),
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
      },
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

  Widget _buildPromocoes() {
    return Consumer<PromotionProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) {
          return const SizedBox(
            height: 210,
            child: Center(
              child: CircularProgressIndicator(color: Color(0xFFC0392B)),
            ),
          );
        }

        if (provider.promotions.isEmpty) {
          return const SizedBox(
            height: 210,
            child: Center(
              child: Text(
                'Nenhuma promoção disponível',
                style: TextStyle(color: Colors.white38),
              ),
            ),
          );
        }

        return Padding(
          padding: const EdgeInsets.only(left: 16),
          child: SizedBox(
            height: 210,
            child: PageView.builder(
              controller: _pageController,
              padEnds: false,
              itemCount: null,
              itemBuilder: (context, i) {
                final promo =
                    provider.promotions[i % provider.promotions.length];
                return GestureDetector(
                  onTap: () {
                    final product = ProductModel(
                      id: promo.productId,
                      name: promo.productName.isNotEmpty
                          ? promo.productName
                          : promo.title,
                      description: promo.description,
                      price: promo.promotionalPrice,
                      unitOfMeasure: promo.productUnitOfMeasure,
                      active: true,
                      brand: '',
                      imageUrl: promo.productImageUrl,
                      unitId: promo.unitId,
                      unitName: promo.unitName,
                      categoryId: '',
                      stockQuantity: 1,
                    );
                    Navigator.pushNamed(
                      context,
                      AppRoutes.productDetail,
                      arguments: product,
                    );
                  },
                  child: AnimatedBuilder(
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
                      margin: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF4A4A4A),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(16),
                                  ),
                                  child: Container(
                                    color: Colors.white,
                                    width: double.infinity,
                                    child: promo.productImageUrl.isNotEmpty
                                        ? Image.network(
                                            promo.productImageUrl,
                                            width: double.infinity,
                                            height: double.infinity,
                                            fit: BoxFit.contain,
                                            errorBuilder: (_, __, ___) =>
                                                _placeholderCard(
                                                  promo.productName,
                                                ),
                                          )
                                        : _placeholderCard(promo.productName),
                                  ),
                                ),

                                if (promo.discountPercentage > 0)
                                  Positioned(
                                    top: 8,
                                    right: 8,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFC0392B),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        promo.descontoLabel,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Expanded(
                                  child: Text(
                                    promo.productName.isNotEmpty
                                        ? promo.productName
                                        : promo.title,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                RichText(
                                  text: TextSpan(
                                    children: [
                                      TextSpan(
                                        text: promo.precoFormatado,
                                        style: const TextStyle(
                                          color: Color(0xFFC0392B),
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      TextSpan(
                                        text: '/${promo.productUnitOfMeasure}',
                                        style: const TextStyle(
                                          color: Colors.white54,
                                          fontSize: 11,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildAcougues() {
    return Consumer<UnitProvider>(
      builder: (context, provider, _) {
        if (provider.loading) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Center(child: MeatShopLoader()),
          );
        }
        if (provider.units.isEmpty) {
          return const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              'Nenhum açougue disponível.',
              style: TextStyle(color: Colors.white38),
            ),
          );
        }

        final lista = provider.units.take(3).toList();
        return Column(
          children: lista.map((u) => _buildAcougueItemFromUnit(u)).toList(),
        );
      },
    );
  }

  Widget _buildAcougueItemFromUnit(UnitModel u) {
    return GestureDetector(
      onTap: () =>
          Navigator.pushNamed(context, AppRoutes.butcherDetail, arguments: u),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: _surface,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: u.imageUrl.isNotEmpty
                  ? Image.network(
                      u.imageUrl,
                      width: 44,
                      height: 44,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _unitLogoFallback(),
                    )
                  : _unitLogoFallback(),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                u.name,
                style: const TextStyle(
                  color: _white,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.star_rounded,
                  color: Color(0xFFFFB800),
                  size: 16,
                ),
                const SizedBox(width: 3),
                Text(
                  u.averageRating > 0
                      ? u.averageRating.toStringAsFixed(1)
                      : '–',
                  style: const TextStyle(
                    color: Color(0xFFFFB800),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _unitLogoFallback() {
    return Container(
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
    );
  }

  Widget _placeholderCard(String nome) {
    return Container(
      width: double.infinity,
      color: const Color(0xFF555555),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.lunch_dining_outlined,
            color: Colors.white12,
            size: 44,
          ),
          const SizedBox(height: 8),
          Text(
            nome,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white24, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

String _greeting() {
  final hour = DateTime.now().hour;
  if (hour < 12) return 'Bom dia';
  if (hour < 18) return 'Boa tarde';
  return 'Boa noite';
}
