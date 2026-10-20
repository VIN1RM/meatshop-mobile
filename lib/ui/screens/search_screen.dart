import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:meatshop_mobile/models/unit_model.dart';
import 'package:meatshop_mobile/models/product_model.dart';
import 'package:meatshop_mobile/providers/search_provider.dart';
import 'package:meatshop_mobile/routes/app_routes.dart';
import 'package:meatshop_mobile/ui/widgets/search_widget.dart';
import 'package:meatshop_mobile/models/search_model.dart';
import 'package:meatshop_mobile/core/enums/search_type_enum.dart';
import 'package:meatshop_mobile/ui/components/sheets/search_filter_sheet.dart';
import 'cuts/cuts_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  late SearchProvider _searchProvider;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _searchProvider = context.read<SearchProvider>();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(_focusNode);
      _searchProvider.loadFilters();
    });
  }

  Future<void> _openFilters(SearchProvider provider) async {
    await provider.loadFilters(force: provider.filterError != null);
    if (!mounted) return;
    if (provider.filterError != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(provider.filterError!)));
      return;
    }
    final selection = await SearchFilterSheet.show(
      context,
      categories: provider.availableCategories,
      brands: provider.brands,
      selectedCategory: provider.selectedCategory,
      selectedBrand: provider.selectedBrand,
      minPrice: provider.minPrice,
      maxPrice: provider.maxPrice,
    );
    if (selection == null || !mounted) return;
    provider.applyFilters(
      category: selection.category,
      brand: selection.brand,
      minPrice: selection.minPrice,
      maxPrice: selection.maxPrice,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    _searchProvider.clear(notify: false);
    super.dispose();
  }

  void _onTap(BuildContext context, SearchResultModel result) {
    switch (result.type) {
      case SearchResultType.butcher:
        Navigator.pushNamed(
          context,
          AppRoutes.butcherDetail,
          arguments: result.payload as UnitModel,
        );
      case SearchResultType.category:
        final normalized = result.title.toLowerCase();
        final categoryName = normalized.contains('bovin')
            ? 'Bovinos'
            : normalized.contains('suí') || normalized.contains('sui')
            ? 'Suínos'
            : normalized.contains('ave') || normalized.contains('frango')
            ? 'Aves'
            : normalized.contains('peixe')
            ? 'Peixes'
            : result.title;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => CutsScreen(
              title: categoryName.toUpperCase(),
              categoryName: categoryName,
            ),
          ),
        );
      case SearchResultType.product:
        Navigator.pushNamed(
          context,
          AppRoutes.productDetail,
          arguments: result.payload as ProductModel,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2A2A2A),
      body: SafeArea(
        child: Column(
          children: [
            SearchWidget(
              controller: _controller,
              showBackButton: true,
              hintText: 'Produto, categoria ou açougue...',
              onChanged: (v) =>
                  context.read<SearchProvider>().onQueryChanged(v),
              onFilter: () => _openFilters(context.read<SearchProvider>()),
              filterActive: context.watch<SearchProvider>().hasFilters,
            ),
            Consumer<SearchProvider>(
              builder: (_, provider, _) => !provider.hasFilters
                  ? const SizedBox.shrink()
                  : Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            if (provider.selectedCategory != null)
                              _filterChip(
                                'Categoria: ${provider.selectedCategory}',
                                () => provider.applyFilters(
                                  brand: provider.selectedBrand,
                                  minPrice: provider.minPrice,
                                  maxPrice: provider.maxPrice,
                                ),
                              ),
                            if (provider.selectedBrand != null)
                              _filterChip(
                                'Marca: ${provider.selectedBrand}',
                                () => provider.applyFilters(
                                  category: provider.selectedCategory,
                                  minPrice: provider.minPrice,
                                  maxPrice: provider.maxPrice,
                                ),
                              ),
                            if (provider.minPrice != null ||
                                provider.maxPrice != null)
                              _filterChip(
                                _priceRangeLabel(provider),
                                () => provider.applyFilters(
                                  category: provider.selectedCategory,
                                  brand: provider.selectedBrand,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
            ),
            Expanded(child: _buildBody()),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    return Consumer<SearchProvider>(
      builder: (context, provider, _) {
        if (!provider.hasCriteria) return _buildEmptyState();
        if (provider.isLoading) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFFC0392B)),
          );
        }
        if (provider.error != null) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  provider.error!,
                  style: const TextStyle(color: Colors.white),
                ),
                TextButton(
                  onPressed: () => provider.onQueryChanged(provider.query),
                  child: const Text('Tentar novamente'),
                ),
              ],
            ),
          );
        }
        if (provider.isEmpty) {
          return _buildNoResults(provider);
        }

        return ListView(
          padding: const EdgeInsets.only(bottom: 24),
          children: [
            if (provider.categories.isNotEmpty) ...[
              _sectionHeader('CATEGORIAS'),
              ...provider.categories.map((r) => _buildTile(r)),
            ],
            if (provider.butchers.isNotEmpty) ...[
              _sectionHeader('AÇOUGUES'),
              ...provider.butchers.map((r) => _buildTile(r)),
            ],
            if (provider.products.isNotEmpty) ...[
              _sectionHeader('PRODUTOS'),
              ...provider.products.map((r) => _buildTile(r)),
            ],
          ],
        );
      },
    );
  }

  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 6),
      child: Text(
        title,
        style: const TextStyle(
          color: Color(0xFFC0392B),
          fontSize: 12,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.4,
        ),
      ),
    );
  }

  Widget _filterChip(String label, VoidCallback onDeleted) => Padding(
    padding: const EdgeInsets.only(right: 8),
    child: InputChip(
      label: Text(label),
      labelStyle: const TextStyle(color: Colors.white),
      backgroundColor: const Color(0xFFC0392B),
      deleteIconColor: Colors.white,
      onDeleted: onDeleted,
    ),
  );

  String _priceRangeLabel(SearchProvider provider) {
    String price(double value) => value.toStringAsFixed(2).replaceAll('.', ',');
    if (provider.minPrice != null && provider.maxPrice != null) {
      return 'Preço: R\$ ${price(provider.minPrice!)} a R\$ ${price(provider.maxPrice!)}';
    }
    if (provider.minPrice != null) {
      return 'Preço: a partir de R\$ ${price(provider.minPrice!)}';
    }
    return 'Preço: até R\$ ${price(provider.maxPrice!)}';
  }

  Widget _buildTile(SearchResultModel result) {
    return ListTile(
      onTap: () => _onTap(context, result),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: _buildLeading(result),
      title: Text(
        result.title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: result.subtitle != null
          ? Text(
              result.subtitle!,
              style: const TextStyle(color: Colors.white38, fontSize: 12),
            )
          : null,
      trailing: const Icon(
        Icons.chevron_right,
        color: Colors.white24,
        size: 20,
      ),
    );
  }

  Widget _buildLeading(SearchResultModel result) {
    if (result.type == SearchResultType.category) {
      return Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: const Color(0xFFC0392B).withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Icon(
          Icons.category_outlined,
          color: Color(0xFFC0392B),
          size: 22,
        ),
      );
    }

    if (result.imageUrl != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.network(
          result.imageUrl!,
          width: 44,
          height: 44,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) =>
              _iconFallback(result.type),
        ),
      );
    }

    return _iconFallback(result.type);
  }

  Widget _iconFallback(SearchResultType type) {
    final icon = type == SearchResultType.butcher
        ? Icons.storefront_outlined
        : Icons.lunch_dining_outlined;
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: const Color(0xFF444444),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, color: Colors.white38, size: 22),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.search, color: Colors.white12, size: 64),
          SizedBox(height: 12),
          Text(
            'Busque por produto, categoria ou açougue',
            style: TextStyle(color: Colors.white24, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildNoResults(SearchProvider provider) {
    final criteria = <String>[
      if (provider.query.trim().isNotEmpty) '"${provider.query}"',
      if (provider.selectedCategory != null)
        'categoria ${provider.selectedCategory}',
      if (provider.selectedBrand != null) 'marca ${provider.selectedBrand}',
      if (provider.minPrice != null || provider.maxPrice != null)
        _priceRangeLabel(provider).toLowerCase(),
    ].join(', ');
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.search_off, color: Colors.white12, size: 64),
          const SizedBox(height: 12),
          Text(
            'Nada encontrado para $criteria',
            style: const TextStyle(color: Colors.white38, fontSize: 14),
          ),
        ],
      ),
    );
  }
}
