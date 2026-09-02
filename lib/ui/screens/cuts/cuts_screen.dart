import 'package:flutter/material.dart';
import 'package:meatshop_mobile/routes/app_routes.dart';
import 'package:provider/provider.dart';
import 'package:meatshop_mobile/ui/widgets/app_header.dart';
import 'package:meatshop_mobile/ui/components/sheets/cuts_filter_sheet.dart';
import 'package:meatshop_mobile/ui/widgets/search_widget.dart';
import 'package:meatshop_mobile/providers/product_provider.dart';
import 'package:meatshop_mobile/models/product_model.dart';
import '../../../data/repositories/marketplace_context.dart';
import '../../../services/category_service.dart';
import '../../../services/product_service.dart';
import '../../../services/unit_service.dart';

class CutsScreen extends StatelessWidget {
  final String title;
  final String categoryName;

  const CutsScreen({
    super.key,
    required this.title,
    required this.categoryName,
  });

  @override
  Widget build(BuildContext context) {
    final marketplace = context.read<MarketplaceContext>().repository;
    return ChangeNotifierProvider(
      create: (_) => ProductsProvider(
        categoryName: categoryName,
        service: ProductService(marketplace: marketplace),
        categoryService: CategoryService(marketplace: marketplace),
        unitService: UnitService(marketplace: marketplace),
      )..loadFirstPage(),
      child: _CutsView(title: title),
    );
  }
}

class _CutsView extends StatefulWidget {
  final String title;

  const _CutsView({required this.title});

  @override
  State<_CutsView> createState() => _CutsViewState();
}

class _CutsViewState extends State<_CutsView> {
  static const Color _red = Color(0xFFC0392B);
  static const Color _surface = Color(0xFF3A3A3A);
  static const Color _bg = Color(0xFF2E2E2E);
  static const Color _white = Colors.white;

  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<ProductsProvider>().loadMore();
    }
  }

  Future<void> _openFilter() async {
    final provider = context.read<ProductsProvider>();

    final currentFilter = CutsFilter(
      order: _toSheetOrder(provider.sortOrder),
      priceRange: _toSheetRange(provider.priceRange),
    );

    final result = await CutsFilterSheet.show(context, currentFilter);
    if (result != null) {
      provider.updateFilters(
        order: _fromSheetOrder(result.order),
        range: _fromSheetRange(result.priceRange),
      );
    }
  }

  bool _isFilterActive(ProductsProvider provider) =>
      provider.priceRange != ProductPriceRange.all ||
      provider.sortOrder != ProductSortOrder.nameAZ;

  String _buildFilterLabel(ProductsProvider provider) {
    final parts = <String>[];

    switch (provider.sortOrder) {
      case ProductSortOrder.nameAZ:
        parts.add('A → Z');
      case ProductSortOrder.nameZA:
        parts.add('Z → A');
      case ProductSortOrder.priceAsc:
        parts.add('Menor preço');
      case ProductSortOrder.priceDesc:
        parts.add('Maior preço');
    }

    switch (provider.priceRange) {
      case ProductPriceRange.upTo20:
        parts.add('Até R\$20');
      case ProductPriceRange.from20to50:
        parts.add('R\$20–R\$50');
      case ProductPriceRange.above50:
        parts.add('Acima R\$50');
      case ProductPriceRange.all:
        break;
    }

    return parts.join(' · ');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: Stack(
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
                errorBuilder: (_, __, ___) =>
                    Container(color: const Color(0xFF1A1A1A)),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                const AppHeader(),
                Consumer<ProductsProvider>(
                  builder: (_, provider, __) => SearchWidget(
                    controller: _searchController,
                    hintText: 'Procure por um corte específico',
                    showBackButton: true,
                    onChanged: (value) => provider.updateSearch(value),
                  ),
                ),
                Expanded(
                  child: Consumer<ProductsProvider>(
                    builder: (_, provider, __) {
                      final filterActive = _isFilterActive(provider);

                      return Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
                            child: Row(
                              children: [
                                Text(
                                  widget.title,
                                  style: const TextStyle(
                                    color: _red,
                                    fontSize: 22,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                                const Spacer(),
                                GestureDetector(
                                  onTap: _openFilter,
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: filterActive ? _red : _surface,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Stack(
                                      clipBehavior: Clip.none,
                                      children: [
                                        const Icon(
                                          Icons.filter_list_rounded,
                                          color: _white,
                                          size: 22,
                                        ),
                                        if (filterActive)
                                          Positioned(
                                            top: -4,
                                            right: -4,
                                            child: Container(
                                              width: 8,
                                              height: 8,
                                              decoration: const BoxDecoration(
                                                color: Color(0xFFFFB800),
                                                shape: BoxShape.circle,
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
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: _red.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: _red.withValues(alpha: 0.4),
                                    width: 1,
                                  ),
                                ),
                                child: Text(
                                  _buildFilterLabel(provider),
                                  style: const TextStyle(
                                    color: _red,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Expanded(child: _buildBody(provider, filterActive)),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(ProductsProvider provider, bool filterActive) {
    if (provider.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFFC0392B)),
      );
    }

    if (provider.error != null && provider.items.isEmpty) {
      return _buildErrorState(provider);
    }

    if (provider.items.isEmpty) {
      return _buildEmptyState(provider, filterActive);
    }

    return _buildList(provider);
  }

  Widget _buildErrorState(ProductsProvider provider) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.wifi_off_rounded, color: Colors.white38, size: 48),
            const SizedBox(height: 12),
            Text(
              provider.error!,
              style: const TextStyle(color: Colors.white54, fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: provider.loadFirstPage,
              child: const Text(
                'Tentar novamente',
                style: TextStyle(color: Color(0xFFC0392B)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(ProductsProvider provider, bool filterActive) {
    final isPriceFiltered = provider.priceRange != ProductPriceRange.all;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.search_off_rounded, color: Colors.white24, size: 48),
          const SizedBox(height: 12),
          Text(
            isPriceFiltered
                ? 'Nenhum corte nessa faixa de preço.'
                : 'Nenhum corte encontrado.',
            style: const TextStyle(color: Colors.white38, fontSize: 14),
          ),
          if (filterActive) ...[
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () => provider.updateFilters(
                order: ProductSortOrder.nameAZ,
                range: ProductPriceRange.all,
              ),
              child: const Text(
                'Limpar filtros',
                style: TextStyle(
                  color: Color(0xFFC0392B),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  decoration: TextDecoration.underline,
                  decorationColor: Color(0xFFC0392B),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildList(ProductsProvider provider) {
    return RefreshIndicator(
      color: const Color(0xFFC0392B),
      backgroundColor: const Color(0xFF3A3A3A),
      onRefresh: provider.loadFirstPage,
      child: ListView.builder(
        controller: _scrollController,
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        itemCount: provider.items.length + (provider.isLoadingMore ? 1 : 0),
        itemBuilder: (_, index) {
          if (index == provider.items.length) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: Color(0xFFC0392B),
                  ),
                ),
              ),
            );
          }
          return _buildProductItem(provider.items[index]);
        },
      ),
    );
  }

  Widget _buildProductItem(ProductModel product) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(
        context,
        AppRoutes.productDetail,
        arguments: product,
      ),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5),
        decoration: BoxDecoration(
          color: const Color(0xFF3A3A3A),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.horizontal(
                left: Radius.circular(12),
              ),
              child: _buildProductImage(product),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    product.name,
                    style: const TextStyle(
                      color: _white,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    product.unitName,
                    style: const TextStyle(
                      color: Colors.white38,
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 14),
              child: RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: product.precoFormatado,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextSpan(
                      text: '/${product.unitOfMeasure}',
                      style: const TextStyle(
                        color: Colors.white38,
                        fontSize: 11,
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

  Widget _buildProductImage(ProductModel product) {
    if (product.imageUrl.isNotEmpty) {
      return Image.network(
        product.imageUrl,
        width: 72,
        height: 72,
        fit: BoxFit.cover,
        loadingBuilder: (_, child, progress) {
          if (progress == null) return child;
          return _imagePlaceholder(showLoader: true);
        },
        errorBuilder: (_, __, ___) => _imagePlaceholder(),
      );
    }
    return _imagePlaceholder();
  }

  Widget _imagePlaceholder({bool showLoader = false}) {
    return Container(
      width: 72,
      height: 72,
      color: const Color(0xFF555555),
      child: Center(
        child: showLoader
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Color(0xFFC0392B),
                ),
              )
            : const Icon(Icons.image_outlined, color: Colors.white24, size: 28),
      ),
    );
  }

  CutsOrder _toSheetOrder(ProductSortOrder order) => switch (order) {
    ProductSortOrder.nameAZ => CutsOrder.nameAZ,
    ProductSortOrder.nameZA => CutsOrder.nameZA,
    ProductSortOrder.priceDesc => CutsOrder.priceHigh,
    ProductSortOrder.priceAsc => CutsOrder.priceLow,
  };

  CutsPriceRange _toSheetRange(ProductPriceRange range) => switch (range) {
    ProductPriceRange.all => CutsPriceRange.all,
    ProductPriceRange.upTo20 => CutsPriceRange.upTo20,
    ProductPriceRange.from20to50 => CutsPriceRange.from20to50,
    ProductPriceRange.above50 => CutsPriceRange.above50,
  };

  ProductSortOrder _fromSheetOrder(CutsOrder order) => switch (order) {
    CutsOrder.nameAZ => ProductSortOrder.nameAZ,
    CutsOrder.nameZA => ProductSortOrder.nameZA,
    CutsOrder.priceHigh => ProductSortOrder.priceDesc,
    CutsOrder.priceLow => ProductSortOrder.priceAsc,
  };

  ProductPriceRange _fromSheetRange(CutsPriceRange range) => switch (range) {
    CutsPriceRange.all => ProductPriceRange.all,
    CutsPriceRange.upTo20 => ProductPriceRange.upTo20,
    CutsPriceRange.from20to50 => ProductPriceRange.from20to50,
    CutsPriceRange.above50 => ProductPriceRange.above50,
  };
}
