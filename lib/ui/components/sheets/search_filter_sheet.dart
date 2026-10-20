import 'package:flutter/material.dart';

class SearchFilterSelection {
  const SearchFilterSelection({
    this.category,
    this.brand,
    this.minPrice,
    this.maxPrice,
  });

  final String? category;
  final String? brand;
  final double? minPrice;
  final double? maxPrice;
}

class SearchFilterSheet extends StatefulWidget {
  const SearchFilterSheet({
    super.key,
    required this.categories,
    required this.brands,
    required this.selectedCategory,
    required this.selectedBrand,
    required this.minPrice,
    required this.maxPrice,
  });

  final List<String> categories;
  final List<String> brands;
  final String? selectedCategory;
  final String? selectedBrand;
  final double? minPrice;
  final double? maxPrice;

  static Future<SearchFilterSelection?> show(
    BuildContext context, {
    required List<String> categories,
    required List<String> brands,
    required String? selectedCategory,
    required String? selectedBrand,
    required double? minPrice,
    required double? maxPrice,
  }) => showModalBottomSheet<SearchFilterSelection>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (_) => SearchFilterSheet(
      categories: categories,
      brands: brands,
      selectedCategory: selectedCategory,
      selectedBrand: selectedBrand,
      minPrice: minPrice,
      maxPrice: maxPrice,
    ),
  );

  @override
  State<SearchFilterSheet> createState() => _SearchFilterSheetState();
}

class _SearchFilterSheetState extends State<SearchFilterSheet> {
  static const _red = Color(0xFFC0392B);
  late final TextEditingController _minController;
  late final TextEditingController _maxController;
  String? _category;
  String? _brand;
  String? _priceError;

  @override
  void initState() {
    super.initState();
    _category = widget.selectedCategory;
    _brand = widget.selectedBrand;
    _minController = TextEditingController(
      text: _displayPrice(widget.minPrice),
    );
    _maxController = TextEditingController(
      text: _displayPrice(widget.maxPrice),
    );
  }

  @override
  void dispose() {
    _minController.dispose();
    _maxController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.sizeOf(context).height;
    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: height * .9),
      child: DecoratedBox(
        decoration: const BoxDecoration(
          color: Color(0xFFF5F5F5),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              20,
              16,
              20,
              20 + MediaQuery.viewInsetsOf(context).bottom,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFFCCCCCC),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    const Icon(Icons.filter_alt_outlined, color: _red),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Filtrar produtos',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    IconButton(
                      tooltip: 'Fechar',
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Flexible(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _label('CATEGORIA'),
                        const SizedBox(height: 10),
                        _chips(
                          values: widget.categories,
                          selected: _category,
                          onSelected: (value) =>
                              setState(() => _category = value),
                          emptyMessage: 'Nenhuma categoria disponível.',
                        ),
                        const SizedBox(height: 20),
                        _label('MARCA'),
                        const SizedBox(height: 10),
                        _chips(
                          values: widget.brands,
                          selected: _brand,
                          onSelected: (value) => setState(() => _brand = value),
                          emptyMessage: 'Nenhuma marca disponível.',
                        ),
                        const SizedBox(height: 20),
                        _label('FAIXA DE PREÇO'),
                        const SizedBox(height: 10),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: _priceField(
                                controller: _minController,
                                label: 'Mínimo',
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _priceField(
                                controller: _maxController,
                                label: 'Máximo',
                              ),
                            ),
                          ],
                        ),
                        if (_priceError != null) ...[
                          const SizedBox(height: 8),
                          Text(
                            _priceError!,
                            style: const TextStyle(
                              color: Colors.red,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _clear,
                        child: const Text('Limpar'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: FilledButton(
                        style: FilledButton.styleFrom(backgroundColor: _red),
                        onPressed: _apply,
                        child: const Text('Aplicar filtros'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _label(String text) => Text(
    text,
    style: const TextStyle(
      color: Color(0xFF777777),
      fontSize: 11,
      fontWeight: FontWeight.w700,
      letterSpacing: .8,
    ),
  );

  Widget _chips({
    required List<String> values,
    required String? selected,
    required ValueChanged<String?> onSelected,
    required String emptyMessage,
  }) {
    if (values.isEmpty) return Text(emptyMessage);
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: values
          .map((value) {
            final isSelected = value == selected;
            return FilterChip(
              selected: isSelected,
              label: Text(value),
              checkmarkColor: Colors.white,
              selectedColor: _red,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : const Color(0xFF333333),
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              ),
              onSelected: (_) => onSelected(isSelected ? null : value),
            );
          })
          .toList(growable: false),
    );
  }

  Widget _priceField({
    required TextEditingController controller,
    required String label,
  }) => TextField(
    controller: controller,
    keyboardType: const TextInputType.numberWithOptions(decimal: true),
    decoration: InputDecoration(
      labelText: label,
      prefixText: 'R\$ ',
      border: const OutlineInputBorder(),
    ),
    onChanged: (_) {
      if (_priceError != null) setState(() => _priceError = null);
    },
  );

  void _clear() {
    setState(() {
      _category = null;
      _brand = null;
      _minController.clear();
      _maxController.clear();
      _priceError = null;
    });
  }

  void _apply() {
    final minimum = _parsePrice(_minController.text);
    final maximum = _parsePrice(_maxController.text);
    final invalidMinimum =
        _minController.text.trim().isNotEmpty && minimum == null;
    final invalidMaximum =
        _maxController.text.trim().isNotEmpty && maximum == null;
    if (invalidMinimum ||
        invalidMaximum ||
        minimum != null && minimum < 0 ||
        maximum != null && maximum < 0) {
      setState(() => _priceError = 'Informe valores válidos e positivos.');
      return;
    }
    if (minimum != null && maximum != null && minimum > maximum) {
      setState(() => _priceError = 'O preço mínimo não pode superar o máximo.');
      return;
    }
    Navigator.pop(
      context,
      SearchFilterSelection(
        category: _category,
        brand: _brand,
        minPrice: minimum,
        maxPrice: maximum,
      ),
    );
  }

  static double? _parsePrice(String value) {
    final normalized = value.trim().replaceAll(',', '.');
    return normalized.isEmpty ? null : double.tryParse(normalized);
  }

  static String _displayPrice(double? value) {
    if (value == null) return '';
    return value == value.roundToDouble()
        ? value.toStringAsFixed(0)
        : value.toStringAsFixed(2).replaceAll('.', ',');
  }
}
