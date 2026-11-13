import 'butcher_catalog_controls.dart';
import 'package:meatshop_mobile/ui/widgets/app_empty_state.dart';
import '../account/image_gallery_screen.dart';
import 'package:flutter/material.dart';
import 'package:meatshop_mobile/models/product_model.dart';
import 'package:meatshop_mobile/models/unit_model.dart';
import 'package:meatshop_mobile/providers/cart_provider.dart';
import 'package:meatshop_mobile/providers/unit/butcher_provider.dart';
import 'package:meatshop_mobile/routes/app_routes.dart';
import 'package:meatshop_mobile/ui/components/sheets/cart_bag_sheet.dart';
import 'package:meatshop_mobile/ui/widgets/review_card.dart';
import 'package:provider/provider.dart';
import 'package:meatshop_mobile/ui/widgets/business_hours_banner.dart';
import 'package:shimmer/shimmer.dart';
import '../../../data/repositories/marketplace_context.dart';
import '../../../services/business_hours_service.dart';
import '../../../services/product_service.dart';
import '../../../services/promotion_service.dart';
import '../../../services/review_service.dart';

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

    final marketplace = context.read<MarketplaceContext>().repository;
    return ChangeNotifierProvider(
      create: (_) => ButcherProvider(
        unitId: unit.id,
        productService: ProductService(marketplace: marketplace),
        promotionService: PromotionService(marketplace: marketplace),
        hoursService: BusinessHoursService(marketplace: marketplace),
        reviewService: ReviewService(marketplace: marketplace),
      ),
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
    final catalog = context.watch<ButcherProvider>();
    if (catalog.isLoading) {
      return Scaffold(
        backgroundColor: _pageBg,
        body: _ButcherDetailShimmer(hasCover: unit.coverUrl.isNotEmpty),
      );
    }
    return Scaffold(
      backgroundColor: _pageBg,
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeroBanner(context, unit),
                      _buildInfoCard(unit),
                      if (unit.allImageUrls.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                          child: Center(
                            child: FilledButton.icon(
                              onPressed: () => ImageGalleryScreen.show(
                                context,
                                images: unit.allImageUrls,
                                title: unit.name,
                              ),
                              style: FilledButton.styleFrom(
                                backgroundColor: _red,
                                foregroundColor: Colors.white,
                                minimumSize: const Size(0, 48),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              icon: const Icon(
                                Icons.photo_library_outlined,
                                size: 20,
                              ),
                              label: Text(
                                'Ver fotos do açougue (${unit.allImageUrls.length})',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        ),
                      if (catalog.warning != null)
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  catalog.warning!,
                                  style: const TextStyle(
                                    color: _textGray,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              TextButton(
                                onPressed: catalog.loadProducts,
                                child: const Text('Tentar novamente'),
                              ),
                            ],
                          ),
                        ),
                      if (catalog.error != null)
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: AppEmptyState(
                            brightness: Brightness.light,
                            title: catalog.error!,
                            icon: Icons.wifi_off_rounded,
                            actionLabel: 'Tentar novamente',
                            onAction: catalog.loadProducts,
                          ),
                        )
                      else ...[
                        if (catalog.promotions.isNotEmpty) ...[
                          const SizedBox(height: 28),
                          _buildPromocoesSection(context),
                        ],
                        if (catalog.hasCatalog) ...[
                          const SizedBox(height: 28),
                          _buildSectionTitle('Produtos'),
                          const ButcherCatalogControls(),
                          const SizedBox(height: 16),
                          _buildProductList(context),
                        ],
                        if (catalog.reviews.isNotEmpty) ...[
                          const SizedBox(height: 28),
                          _buildReviewsSection(context),
                        ],
                      ],
                      SizedBox(
                        height: context.watch<CartProvider>().items.isEmpty
                            ? 32
                            : 120,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Consumer<CartProvider>(
            builder: (_, cart, _) {
              if (cart.items.isEmpty) return const SizedBox.shrink();
              return Positioned(
                bottom: 24,
                left: 16,
                right: 16,
                child: GestureDetector(
                  onTap: () => CartBagSheet.show(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: _red,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.shopping_bag_outlined,
                          color: Colors.white,
                          size: 20,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          '${cart.items.length} ${cart.items.length == 1 ? 'item' : 'itens'} na sacola',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          'R\$${cart.total.toStringAsFixed(2).replaceAll('.', ',')}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Icon(
                          Icons.keyboard_arrow_up,
                          color: Colors.white70,
                          size: 18,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildHeroBanner(BuildContext context, UnitModel unit) {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.bottomCenter,
      children: [
        Semantics(
          label: unit.allImageUrls.isEmpty
              ? unit.name
              : 'Visualizar fotos do açougue',
          button: unit.allImageUrls.isNotEmpty,
          child: GestureDetector(
            onTap: unit.allImageUrls.isEmpty
                ? null
                : () => ImageGalleryScreen.show(
                    context,
                    images: unit.allImageUrls,
                    title: unit.name,
                    initialImage: unit.coverUrl,
                  ),
            child: SizedBox(
              width: double.infinity,
              height: unit.coverUrl.isEmpty ? 88 : 180,
              child: unit.coverUrl.isNotEmpty
                  ? Image.network(
                      unit.coverUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => const SizedBox.shrink(),
                    )
                  : const SizedBox.shrink(),
            ),
          ),
        ),

        Positioned(
          top: MediaQuery.paddingOf(context).top + 8,
          left: 16,
          child: Material(
            color: Colors.white,
            shape: const CircleBorder(),
            child: IconButton(
              tooltip: 'Voltar',
              onPressed: () => Navigator.maybePop(context),
              icon: const Icon(Icons.arrow_back, color: _textDark),
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
            child: GestureDetector(
              onTap: unit.allImageUrls.isEmpty
                  ? null
                  : () => ImageGalleryScreen.show(
                      context,
                      images: unit.allImageUrls,
                      title: unit.name,
                      initialImage: unit.imageUrl,
                    ),
              child: ClipOval(
                child: unit.imageUrl.isNotEmpty
                    ? Image.network(
                        unit.imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) =>
                            const Icon(Icons.store, color: _white, size: 40),
                      )
                    : const Icon(Icons.store, color: _white, size: 40),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard(UnitModel unit) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 52, 16, 0),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
      decoration: BoxDecoration(
        color: _white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            unit.name,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: _textDark,
            ),
          ),
          const SizedBox(height: 12),
          if ([
            unit.street,
            unit.neighborhood,
            unit.city,
            unit.state,
          ].any((value) => value.trim().isNotEmpty)) ...[
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
          ],
          Consumer<ButcherProvider>(
            builder: (_, provider, _) =>
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
      builder: (_, provider, _) {
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
                        stockQuantity: promo.productStockQuantity,
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
                                          errorBuilder: (_, _, _) =>
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
                              promo.formattedPrice,
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
    final provider = context.watch<ButcherProvider>();
    if (provider.items.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: AppEmptyState(
          brightness: Brightness.light,
          title: 'Nenhum produto encontrado',
          description: 'Tente outro nome ou ajuste os filtros.',
          icon: Icons.search_off,
          actionLabel: 'Limpar filtros',
          onAction: () => provider.applyFilters(),
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final group in provider.groupedProducts.entries) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    group.key,
                    style: const TextStyle(
                      color: _textDark,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  group.value.length.toString(),
                  style: const TextStyle(color: _textGray, fontSize: 13),
                ),
              ],
            ),
          ),
          for (final product in group.value)
            _buildProductItem(context, product),
          const SizedBox(height: 8),
        ],
      ],
    );
  }

  Widget _buildReviewsSection(BuildContext context) {
    return Consumer<ButcherProvider>(
      builder: (_, provider, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Expanded(
                    child: Text(
                      'Avaliações dos Clientes',
                      style: TextStyle(
                        color: _red,
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  if (provider.reviews.length >= 3)
                    GestureDetector(
                      onTap: () => Navigator.pushNamed(
                        context,
                        AppRoutes.unitReviews,
                        arguments: unit.id,
                      ),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: _red.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: _red.withValues(alpha: 0.4),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Text(
                              'Ver todas',
                              style: TextStyle(
                                color: _red,
                                fontWeight: FontWeight.w700,
                                fontSize: 12,
                              ),
                            ),
                            SizedBox(width: 4),
                            Icon(
                              Icons.arrow_forward_ios,
                              size: 11,
                              color: _red,
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            if (provider.reviews.isNotEmpty) ...[
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: provider.reviews.length > 3
                    ? 3
                    : provider.reviews.length,
                itemBuilder: (_, i) => ReviewCard(review: provider.reviews[i]),
              ),
              if (provider.reviews.length < 3) _buildFewReviewsCta(),
            ],
          ],
        );
      },
    );
  }

  Widget _buildFewReviewsCta() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 4, 16, 0),
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      decoration: BoxDecoration(
        color: _red.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _red.withValues(alpha: 0.15), width: 1),
      ),
      child: Row(
        children: const [
          Icon(Icons.edit_outlined, color: _red, size: 18),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Gostou? Deixe sua avaliação após o pedido!',
              style: TextStyle(
                fontSize: 13,
                color: _red,
                fontWeight: FontWeight.w600,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductItem(BuildContext context, ProductModel product) =>
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
        child: Material(
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: Color(0xFFE3E3E3)),
          ),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () => Navigator.pushNamed(
              context,
              AppRoutes.productDetail,
              arguments: product,
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: SizedBox(
                      width: 64,
                      height: 64,
                      child: product.imageUrl.isEmpty
                          ? _imageFallback()
                          : Image.network(
                              product.imageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (_, _, _) => _imageFallback(),
                            ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.name,
                          style: const TextStyle(
                            color: _textDark,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        if (product.brand.trim().isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 3),
                            child: Text(
                              product.brand,
                              style: const TextStyle(
                                color: _textGray,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        const SizedBox(height: 6),
                        Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: product.formattedPrice,
                                style: const TextStyle(
                                  color: _red,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              TextSpan(
                                text: ' / ${product.unitOfMeasure}',
                                style: const TextStyle(
                                  color: _textGray,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Icon(
                    Icons.chevron_right,
                    color: Color(0xFF999999),
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
        ),
      );

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
    final provider = context.read<ButcherProvider>();
    _loader = Future.microtask(provider.loadProducts);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _loader,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return Scaffold(
            backgroundColor: const Color(0xFFEFEFEF),
            body: _ButcherDetailShimmer(
              hasCover: widget.unit.coverUrl.isNotEmpty,
            ),
          );
        }
        return _ButcherDetailView(unit: widget.unit);
      },
    );
  }
}

class _ButcherDetailShimmer extends StatelessWidget {
  const _ButcherDetailShimmer({required this.hasCover});
  final bool hasCover;

  static const Color _base = Color(0xFFE0E0E0);
  static const Color _highlight = Color(0xFFF5F5F5);

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: _base,
      highlightColor: _highlight,
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              height: hasCover ? 180 : 88,
              color: Colors.white,
            ),
            const SizedBox(height: 52),

            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              height: 100,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            const SizedBox(height: 28),

            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              width: 120,
              height: 22,
              color: Colors.white,
            ),
            const SizedBox(height: 12),

            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              height: 110,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  for (var i = 0; i < 3; i++)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: Container(
                        width: 80,
                        height: 34,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _shimmerItem(),
            _shimmerItem(),
            _shimmerItem(),
          ],
        ),
      ),
    );
  }

  Widget _shimmerItem() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(height: 14, width: 140, color: Colors.white),
                const SizedBox(height: 8),
                Container(height: 12, width: 80, color: Colors.white),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
