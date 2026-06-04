import 'package:flutter/material.dart';
import 'package:meatshop_mobile/models/product_model.dart';
import 'package:meatshop_mobile/models/unit_model.dart';
import 'package:meatshop_mobile/providers/unit/butcher_provider.dart';
import 'package:meatshop_mobile/routes/app_routes.dart';
import 'package:meatshop_mobile/ui/widgets/loading_widget.dart';
import 'package:provider/provider.dart';
import 'package:meatshop_mobile/ui/widgets/business_hours_banner.dart';

class ButcherDetailScreen extends StatelessWidget {
  const ButcherDetailScreen({super.key});

  static const Color _red = Color(0xFFBE2C1B);
  static const Color _pageBg = Color(0xFFEFEFEF);

  @override
  Widget build(BuildContext context) {
    final unit = ModalRoute.of(context)?.settings.arguments as UnitModel?;

    if (unit == null) {
      return Scaffold(
        backgroundColor: _pageBg,
        appBar: AppBar(backgroundColor: _red),
        body: const Center(child: Text('Açougue não encontrado.')),
      );
    }

    return ChangeNotifierProvider(
      create: (_) => ButcherProvider(unitId: unit.id),
      child: _ButcherDetailLoader(unit: unit),
    );
  }
}

class _ButcherDetailView extends StatelessWidget {
  final UnitModel unit;
  const _ButcherDetailView({required this.unit});

  static const Color _red = Color(0xFFBE2C1B);
  static const Color _pageBg = Color(0xFFEFEFEF);
  static const Color _white = Colors.white;
  static const Color _textDark = Color(0xFF1A1A1A);
  static const Color _textGray = Color(0xFF555555);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _pageBg,
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeroBanner(unit),
                  _buildInfoCard(unit),
                  const SizedBox(height: 20),
                  _buildPromocoesSection(context),
                  _buildSectionTitle('Produtos'),
                  const SizedBox(height: 12),
                  _buildProductList(context),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeroBanner(UnitModel unit) {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.bottomCenter,
      children: [
        SizedBox(
          width: double.infinity,
          height: 180,
          child: Image.asset(
            'assets/images/background_acougue.png',
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              color: const Color(0xFF2A2A2A),
              child: const Center(
                child: Icon(
                  Icons.storefront_outlined,
                  color: Colors.white24,
                  size: 60,
                ),
              ),
            ),
          ),
        ),
        Positioned(
          bottom: -40,
          child: Container(
            width: 86,
            height: 86,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: _pageBg, width: 3),
              color: const Color(0xFF1A1A1A),
            ),
            child: ClipOval(
              child: unit.imageUrl.isNotEmpty
                  ? Image.network(
                      unit.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          const Icon(Icons.store, color: _white, size: 40),
                    )
                  : const Icon(Icons.store, color: _white, size: 40),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard(UnitModel unit) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 52, 16, 0),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
      decoration: BoxDecoration(
        color: _white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            unit.name,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: _textDark,
            ),
          ),
          const SizedBox(height: 12),
          const Divider(color: Color(0xFFEEEEEE), height: 1),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.location_on_outlined, color: _red, size: 16),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  unit.formattedAddress,
                  style: const TextStyle(
                    fontSize: 12,
                    color: _textGray,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
          Consumer<ButcherProvider>(
            builder: (_, provider, __) =>
                BusinessHoursBanner(hours: provider.todayHours),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Text(
        title,
        style: const TextStyle(
          color: _red,
          fontSize: 22,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildPromocoesSection(BuildContext context) {
    return Consumer<ButcherProvider>(
      builder: (_, provider, __) {
        if (provider.promotions.isEmpty) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Promoções'),
            const SizedBox(height: 12),
            SizedBox(
              height: 160,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: provider.promotions.length,
                itemBuilder: (_, i) {
                  final promo = provider.promotions[i];
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
                        unitName: unit.name,
                        categoryId: '',
                        stockQuantity: 1,
                      );
                      Navigator.pushNamed(
                        context,
                        AppRoutes.productDetail,
                        arguments: product,
                      );
                    },
                    child: Container(
                      width: 140,
                      margin: const EdgeInsets.only(right: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE6E6E6),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(14),
                            ),
                            child: Stack(
                              children: [
                                SizedBox(
                                  height: 90,
                                  width: double.infinity,
                                  child: promo.productImageUrl.isNotEmpty
                                      ? Image.network(
                                          promo.productImageUrl,
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, __, ___) =>
                                              _imageFallback(),
                                        )
                                      : _imageFallback(),
                                ),
                                if (promo.discountPercentage > 0)
                                  Positioned(
                                    top: 6,
                                    right: 6,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                        vertical: 3,
                                      ),
                                      decoration: BoxDecoration(
                                        color: _red,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        promo.descontoLabel,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 10,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(8, 6, 8, 4),
                            child: Text(
                              promo.productName.isNotEmpty
                                  ? promo.productName
                                  : promo.title,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: _textDark,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Text(
                              promo.precoFormatado,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: _red,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
          ],
        );
      },
    );
  }

  Widget _buildProductList(BuildContext context) {
    return Consumer<ButcherProvider>(
      builder: (_, provider, __) {
        if (provider.isLoading) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 32),
            child: Center(
              child: CircularProgressIndicator(color: Color(0xFFBE2C1B)),
            ),
          );
        }

        if (provider.error != null) {
          return Padding(
            padding: const EdgeInsets.all(24),
            child: Center(
              child: Text(
                provider.error!,
                style: const TextStyle(color: _textGray),
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

        if (provider.items.isEmpty) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 32),
            child: Center(
              child: Text(
                'Nenhum produto disponível.',
                style: TextStyle(color: Color(0xFF9E9E9E)),
              ),
            ),
          );
        }

        return Column(
          children: provider.items
              .map((p) => _buildProductItem(context, p))
              .toList(),
        );
      },
    );
  }

  Widget _buildProductItem(BuildContext context, ProductModel product) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(
        context,
        AppRoutes.productDetail,
        arguments: product,
      ),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: const Color(0xFFE6E6E6),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: SizedBox(
                width: 60,
                height: 60,
                child: product.imageUrl.isNotEmpty
                    ? Image.network(
                        product.imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _imageFallback(),
                      )
                    : _imageFallback(),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                product.name,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: _textDark,
                ),
              ),
            ),
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: product.precoFormatado,
                    style: const TextStyle(
                      color: _textDark,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  TextSpan(
                    text: '/${product.unitOfMeasure}',
                    style: const TextStyle(
                      color: _red,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _imageFallback() {
    return Container(
      color: const Color(0xFFCCCCCC),
      child: const Icon(
        Icons.image_outlined,
        color: Color(0xFF9E9E9E),
        size: 28,
      ),
    );
  }
}

class _ButcherDetailLoader extends StatefulWidget {
  final UnitModel unit;
  const _ButcherDetailLoader({required this.unit});

  @override
  State<_ButcherDetailLoader> createState() => _ButcherDetailLoaderState();
}

class _ButcherDetailLoaderState extends State<_ButcherDetailLoader> {
  late Future<void> _loader;

  @override
  void initState() {
    super.initState();
    _loader = Future.microtask(
      () => context.read<ButcherProvider>().loadProducts(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _loader,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            backgroundColor: Color(0xFFEFEFEF),
            body: Center(child: MeatShopLoader()),
          );
        }
        return _ButcherDetailView(unit: widget.unit);
      },
    );
  }
}
