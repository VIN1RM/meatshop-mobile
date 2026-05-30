import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:meatshop_mobile/ui/widgets/app_header.dart';
import 'package:meatshop_mobile/ui/widgets/cuts_filter_sheet.dart';
import 'package:meatshop_mobile/ui/widgets/search_widget.dart';
import 'package:meatshop_mobile/providers/product_provider.dart';
import 'package:meatshop_mobile/models/product_model.dart';

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
    return ChangeNotifierProvider(
      create: (_) =>
          ProductsProvider(categoryName: categoryName)..loadFirstPage(),
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

  Future<void> _abrirFiltro() async {
    final provider = context.read<ProductsProvider>();

    final filtroAtual = CortesFilter(
      ordem: _toSheetOrder(provider.sortOrder),
      faixaPreco: _toSheetRange(provider.priceRange),
    );

    final resultado = await CortesFilterSheet.show(context, filtroAtual);
    if (resultado != null) {
      provider.updateFilters(
        order: _fromSheetOrder(resultado.ordem),
        range: _fromSheetRange(resultado.faixaPreco),
      );
    }
  }

  String _ordemLabel(ProductsProvider p) {
    final labels = <String>[];

    switch (p.sortOrder) {
      case ProductSortOrder.nameAZ:
        labels.add('A → Z');
      case ProductSortOrder.nameZA:
        labels.add('Z → A');
      case ProductSortOrder.priceAsc:
        labels.add('Menor preço');
      case ProductSortOrder.priceDesc:
        labels.add('Maior preço');
    }

    switch (p.priceRange) {
      case ProductPriceRange.upTo20:
        labels.add('Até R\$20');
      case ProductPriceRange.from20to50:
        labels.add('R\$20–R\$50');
      case ProductPriceRange.above50:
        labels.add('Acima R\$50');
      case ProductPriceRange.all:
        break;
    }

    return labels.join(' · ');
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
                    onChanged: (v) => provider.updateSearch(v),
                  ),
                ),
                Expanded(
                  child: Consumer<ProductsProvider>(
                    builder: (_, provider, __) {
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
                                  onTap: _abrirFiltro,
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: _surface,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Icon(
                                      Icons.filter_list_rounded,
                                      color: _white,
                                      size: 22,
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
                                  _ordemLabel(provider),
                                  style: const TextStyle(
                                    color: _red,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Expanded(child: _buildBody(provider)),
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

  Widget _buildBody(ProductsProvider provider) {
    if (provider.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFFC0392B)),
      );
    }

    if (provider.error != null && provider.items.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.wifi_off_rounded,
                color: Colors.white38,
                size: 48,
              ),
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

    if (provider.items.isEmpty) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search_off_rounded, color: Colors.white24, size: 48),
            SizedBox(height: 12),
            Text(
              'Nenhum corte encontrado',
              style: TextStyle(color: Colors.white38, fontSize: 14),
            ),
          ],
        ),
      );
    }

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
        itemBuilder: (_, i) {
          if (i == provider.items.length) {
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
          return _buildProductItem(provider.items[i]);
        },
      ),
    );
  }

  Widget _buildProductItem(ProductModel product) {
    return Container(
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
            child: Text(
              product.name,
              style: const TextStyle(
                color: _white,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
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
                      color: _red,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextSpan(
                    text: '/${product.unitOfMeasure}',
                    style: const TextStyle(color: Colors.white38, fontSize: 11),
                  ),
                ],
              ),
            ),
          ),
        ],
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
          return Container(
            width: 72,
            height: 72,
            color: const Color(0xFF555555),
            child: const Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Color(0xFFC0392B),
                ),
              ),
            ),
          );
        },
        errorBuilder: (_, __, ___) => _imagePlaceholder(),
      );
    }
    return _imagePlaceholder();
  }

  Widget _imagePlaceholder() {
    return Container(
      width: 72,
      height: 72,
      color: const Color(0xFF555555),
      child: const Icon(Icons.image_outlined, color: Colors.white24, size: 28),
    );
  }

  CortesOrdem _toSheetOrder(ProductSortOrder o) => switch (o) {
    ProductSortOrder.nameAZ => CortesOrdem.nomeAZ,
    ProductSortOrder.nameZA => CortesOrdem.nomeZA,
    ProductSortOrder.priceDesc => CortesOrdem.precoMaior,
    ProductSortOrder.priceAsc => CortesOrdem.precoMenor,
  };

  CortesFaixaPreco _toSheetRange(ProductPriceRange r) => switch (r) {
    ProductPriceRange.all => CortesFaixaPreco.todas,
    ProductPriceRange.upTo20 => CortesFaixaPreco.ate20,
    ProductPriceRange.from20to50 => CortesFaixaPreco.de20a50,
    ProductPriceRange.above50 => CortesFaixaPreco.acima50,
  };

  ProductSortOrder _fromSheetOrder(CortesOrdem o) => switch (o) {
    CortesOrdem.nomeAZ => ProductSortOrder.nameAZ,
    CortesOrdem.nomeZA => ProductSortOrder.nameZA,
    CortesOrdem.precoMaior => ProductSortOrder.priceDesc,
    CortesOrdem.precoMenor => ProductSortOrder.priceAsc,
  };

  ProductPriceRange _fromSheetRange(CortesFaixaPreco f) => switch (f) {
    CortesFaixaPreco.todas => ProductPriceRange.all,
    CortesFaixaPreco.ate20 => ProductPriceRange.upTo20,
    CortesFaixaPreco.de20a50 => ProductPriceRange.from20to50,
    CortesFaixaPreco.acima50 => ProductPriceRange.above50,
  };
}
