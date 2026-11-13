import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/unit/butcher_provider.dart';
import '../../../core/utils/field_validations.dart';
import '../../widgets/app_surface.dart';

class ButcherCatalogControls extends StatefulWidget {
  const ButcherCatalogControls({super.key});
  @override
  State<ButcherCatalogControls> createState() => _CatalogControlsState();
}

class _CatalogControlsState extends State<ButcherCatalogControls> {
  final _search = TextEditingController();
  @override
  void initState() {
    super.initState();
    _search.text = context.read<ButcherProvider>().nameFilter;
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  void _searchChanged(String value) {
    final provider = context.read<ButcherProvider>();
    provider.applyFilters(
      name: value,
      brand: provider.brandFilter,
      category: provider.categoryFilter,
      maxPrice: provider.maxPriceFilter,
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ButcherProvider>();
    if (_search.text != provider.nameFilter) {
      _search.value = TextEditingValue(
        text: provider.nameFilter,
        selection: TextSelection.collapsed(offset: provider.nameFilter.length),
      );
    }
    return Theme(
      data: appSurfaceTheme(context),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFE4E4E4)),
            ),
            child: Column(
              children: [
                TextField(
                  controller: _search,
                  onChanged: _searchChanged,
                  textInputAction: TextInputAction.search,
                  style: const TextStyle(
                    color: Color(0xFF222222),
                    fontSize: 14,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Buscar produtos. Ex.: picanha',
                    hintStyle: const TextStyle(
                      color: Color(0xFF888888),
                      fontSize: 13,
                    ),
                    prefixIcon: const Icon(
                      Icons.search,
                      color: Color(0xFFBE2C1B),
                    ),
                    suffixIcon: provider.nameFilter.isEmpty
                        ? null
                        : IconButton(
                            tooltip: 'Limpar busca',
                            onPressed: () => _searchChanged(''),
                            icon: const Icon(Icons.close, size: 20),
                          ),
                    fillColor: const Color(0xFFF7F7F7),
                  ),
                ),
                const SizedBox(height: 12),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final count = Text(
                      '${provider.items.length} de ${provider.catalogCount} produtos',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF666666),
                      ),
                    );
                    final button = OutlinedButton.icon(
                      onPressed: () => _openFilters(context, provider),
                      icon: const Icon(Icons.tune, size: 18),
                      label: Text(
                        provider.advancedFilterCount == 0
                            ? 'Filtros'
                            : 'Filtros (${provider.advancedFilterCount})',
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFFBE2C1B),
                        side: const BorderSide(color: Color(0xFFE8C8C4)),
                        minimumSize: const Size(0, 44),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    );
                    if (MediaQuery.textScalerOf(context).scale(14) > 18 ||
                        constraints.maxWidth < 240) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [count, const SizedBox(height: 8), button],
                      );
                    }
                    return Row(
                      children: [
                        Expanded(child: count),
                        const SizedBox(width: 8),
                        button,
                      ],
                    );
                  },
                ),
                if (provider.hasFilters)
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton(
                      onPressed: () => provider.applyFilters(),
                      child: const Text('Limpar filtros'),
                    ),
                  ),
              ],
            ),
          ),
          if (provider.categories.length > 1)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    _category(provider, '', 'Todas'),
                    for (final category in provider.categories)
                      _category(provider, category.id, category.name),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _category(ButcherProvider provider, String id, String name) => Padding(
    padding: const EdgeInsets.only(right: 8),
    child: ChoiceChip(
      label: Text(name),
      selected: provider.categoryFilter == id,
      showCheckmark: false,
      selectedColor: const Color(0xFFBE2C1B),
      backgroundColor: Colors.white,
      labelStyle: TextStyle(
        color: provider.categoryFilter == id
            ? Colors.white
            : const Color(0xFF555555),
        fontWeight: FontWeight.w600,
        fontSize: 13,
      ),
      side: BorderSide(
        color: provider.categoryFilter == id
            ? const Color(0xFFBE2C1B)
            : const Color(0xFFDDDDDD),
      ),
      onSelected: (_) => provider.applyFilters(
        name: provider.nameFilter,
        brand: provider.brandFilter,
        category: id,
        maxPrice: provider.maxPriceFilter,
      ),
    ),
  );
  void _openFilters(BuildContext context, ButcherProvider provider) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Theme(
        data: appSurfaceTheme(context),
        child: _CatalogFilterSheet(provider: provider),
      ),
    );
  }
}

class _CatalogFilterSheet extends StatefulWidget {
  const _CatalogFilterSheet({required this.provider});
  final ButcherProvider provider;
  @override
  State<_CatalogFilterSheet> createState() => _CatalogFilterSheetState();
}

class _CatalogFilterSheetState extends State<_CatalogFilterSheet> {
  final _form = GlobalKey<FormState>();
  late final TextEditingController _price;
  late String _category;
  late String _brand;
  @override
  void initState() {
    super.initState();
    _category = widget.provider.categoryFilter;
    _brand = widget.provider.brandFilter;
    _price = TextEditingController(
      text: widget.provider.maxPriceFilter
          ?.toStringAsFixed(2)
          .replaceAll('.', ','),
    );
  }

  @override
  void dispose() {
    _price.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    padding: EdgeInsets.fromLTRB(
      20,
      0,
      20,
      20 + MediaQuery.viewInsetsOf(context).bottom,
    ),
    child: Form(
      key: _form,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Filtrar produtos',
            style: TextStyle(
              color: Color(0xFF222222),
              fontWeight: FontWeight.w800,
              fontSize: 22,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Encontre o corte que combina com sua compra.',
            style: TextStyle(color: Color(0xFF666666), fontSize: 13),
          ),
          const SizedBox(height: 24),
          if (widget.provider.categories.length > 1) ...[
            _label('Categoria'),
            DropdownButtonFormField<String>(
              key: ValueKey('category:$_category'),
              initialValue: _category,
              isExpanded: true,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.category_outlined),
              ),
              items: [
                const DropdownMenuItem(
                  value: '',
                  child: Text('Todas as categorias'),
                ),
                for (final category in widget.provider.categories)
                  DropdownMenuItem(
                    value: category.id,
                    child: Text(category.name),
                  ),
              ],
              onChanged: (value) => setState(() => _category = value ?? ''),
            ),
            const SizedBox(height: 20),
          ],
          if (widget.provider.brands.isNotEmpty) ...[
            _label('Marca'),
            DropdownButtonFormField<String>(
              key: ValueKey('brand:$_brand'),
              initialValue: _brand,
              isExpanded: true,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.sell_outlined),
              ),
              items: [
                const DropdownMenuItem(
                  value: '',
                  child: Text('Todas as marcas'),
                ),
                for (final brand in widget.provider.brands)
                  DropdownMenuItem(value: brand, child: Text(brand)),
              ],
              onChanged: (value) => setState(() => _brand = value ?? ''),
            ),
            const SizedBox(height: 20),
          ],
          _label('Preço máximo'),
          TextFormField(
            controller: _price,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              hintText: 'Ex.: 50,00',
              prefixText: r'R$ ',
              helperMaxLines: 3,
              helperText:
                  'Valor máximo por unidade de venda (kg, unidade, etc.).',
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) return null;
              final price = FieldValidations.parseMoney(value);
              return price == null || !price.isFinite || price < 0
                  ? 'Informe um preço válido.'
                  : null;
            },
          ),
          const SizedBox(height: 24),
          FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFBE2C1B),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            onPressed: () {
              if (!_form.currentState!.validate()) return;
              widget.provider.applyFilters(
                name: widget.provider.nameFilter,
                brand: _brand,
                category: _category,
                maxPrice: FieldValidations.parseMoney(_price.text),
              );
              Navigator.pop(context);
            },
            icon: const Icon(Icons.check, size: 20),
            label: const Text(
              'Aplicar filtros',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
          TextButton(
            onPressed: () => setState(() {
              _category = '';
              _brand = '';
              _price.clear();
            }),
            child: const Text('Limpar seleção'),
          ),
        ],
      ),
    ),
  );
  Widget _label(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(
      text,
      style: const TextStyle(
        color: Color(0xFF444444),
        fontWeight: FontWeight.w600,
        fontSize: 13,
      ),
    ),
  );
}
