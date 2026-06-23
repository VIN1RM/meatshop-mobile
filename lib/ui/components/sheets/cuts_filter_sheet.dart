import 'package:flutter/material.dart';

enum CutsOrder { nameAZ, nameZA, priceHigh, priceLow }

enum CutsPriceRange { all, upTo20, from20to50, above50 }

class CutsFilter {
  final CutsOrder order;
  final CutsPriceRange priceRange;

  const CutsFilter({
    this.order = CutsOrder.nameAZ,
    this.priceRange = CutsPriceRange.all,
  });

  CutsFilter copyWith({CutsOrder? order, CutsPriceRange? priceRange}) {
    return CutsFilter(
      order: order ?? this.order,
      priceRange: priceRange ?? this.priceRange,
    );
  }

  bool get hasActiveFilter => priceRange != CutsPriceRange.all;

  bool matchesPriceRange(double price) => switch (priceRange) {
    CutsPriceRange.all => true,
    CutsPriceRange.upTo20 => price <= 20,
    CutsPriceRange.from20to50 => price > 20 && price <= 50,
    CutsPriceRange.above50 => price > 50,
  };
}

class CutsFilterSheet extends StatefulWidget {
  final CutsFilter currentFilter;
  final ValueChanged<CutsFilter> onApply;

  const CutsFilterSheet({
    super.key,
    required this.currentFilter,
    required this.onApply,
  });

  static Future<CutsFilter?> show(
    BuildContext context,
    CutsFilter currentFilter,
  ) {
    return showModalBottomSheet<CutsFilter>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => CutsFilterSheet(
        currentFilter: currentFilter,
        onApply: (filter) => Navigator.pop(context, filter),
      ),
    );
  }

  @override
  State<CutsFilterSheet> createState() => _CutsFilterSheetState();
}

class _CutsFilterSheetState extends State<CutsFilterSheet> {
  static const Color _red = Color(0xFFC0392B);
  static const Color _bg = Color(0xFFF5F5F5);
  static const Color _surface = Color(0xFFEAEAEA);
  static const Color _dark = Color(0xFF1A1A1A);
  static const Color _grey = Color(0xFF555555);
  static const Color _white = Colors.white;

  late CutsFilter _filter;

  @override
  void initState() {
    super.initState();
    _filter = widget.currentFilter;
  }

  void _clearFilter() => setState(() => _filter = const CutsFilter());

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final screenHeight = MediaQuery.of(context).size.height;

    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: screenHeight * 0.92),
      child: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        child: Container(
          decoration: const BoxDecoration(
            color: _bg,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: EdgeInsets.fromLTRB(20, 16, 20, 32 + bottomInset),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHandle(),
              const SizedBox(height: 20),
              _buildHeader(),
              const SizedBox(height: 24),
              _buildSectionLabel('ORDEM ALFABÉTICA'),
              const SizedBox(height: 8),
              _buildAlphaOrderRow(),
              const SizedBox(height: 18),
              _buildSectionLabel('ORDENAR POR PREÇO'),
              const SizedBox(height: 8),
              _buildPriceOrderRow(),
              const SizedBox(height: 18),
              _buildSectionLabel('FAIXA DE PREÇO'),
              const SizedBox(height: 8),
              _buildPriceRangeChips(),
              const SizedBox(height: 28),
              _buildActionButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHandle() {
    return Center(
      child: Container(
        width: 40,
        height: 4,
        decoration: BoxDecoration(
          color: const Color(0xFFDDDDDD),
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        const Icon(Icons.filter_list_rounded, color: _red, size: 22),
        const SizedBox(width: 8),
        const Text(
          'Filtrar Cortes',
          style: TextStyle(
            color: _dark,
            fontSize: 18,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.4,
          ),
        ),
        const Spacer(),
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Icon(Icons.close, color: Color(0xFF999999), size: 22),
        ),
      ],
    );
  }

  Widget _buildAlphaOrderRow() {
    return Row(
      children: [
        _buildOrderChip(
          label: 'A → Z',
          icon: Icons.sort_by_alpha_rounded,
          value: CutsOrder.nameAZ,
        ),
        const SizedBox(width: 10),
        _buildOrderChip(
          label: 'Z → A',
          icon: Icons.sort_by_alpha_rounded,
          value: CutsOrder.nameZA,
          flipIcon: true,
        ),
      ],
    );
  }

  Widget _buildPriceOrderRow() {
    return Row(
      children: [
        _buildOrderChip(
          label: 'Maior preço',
          icon: Icons.arrow_upward_rounded,
          value: CutsOrder.priceHigh,
        ),
        const SizedBox(width: 10),
        _buildOrderChip(
          label: 'Menor preço',
          icon: Icons.arrow_downward_rounded,
          value: CutsOrder.priceLow,
        ),
      ],
    );
  }

  Widget _buildPriceRangeChips() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _buildPriceRangeChip(label: 'Até R\$20', value: CutsPriceRange.upTo20),
        _buildPriceRangeChip(
          label: 'R\$20–R\$50',
          value: CutsPriceRange.from20to50,
        ),
        _buildPriceRangeChip(
          label: 'Acima R\$50',
          value: CutsPriceRange.above50,
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: _clearFilter,
            child: Container(
              height: 50,
              decoration: BoxDecoration(
                color: _surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFDDDDDD)),
              ),
              child: const Center(
                child: Text(
                  'Limpar',
                  style: TextStyle(
                    color: Color(0xFF555555),
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 2,
          child: SizedBox(
            height: 50,
            child: ElevatedButton(
              onPressed: () => widget.onApply(_filter),
              style: ElevatedButton.styleFrom(
                backgroundColor: _red,
                foregroundColor: _white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Aplicar Filtro',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.3,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        color: _grey,
        fontSize: 11,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.8,
      ),
    );
  }

  Widget _buildOrderChip({
    required String label,
    required IconData icon,
    required CutsOrder value,
    bool flipIcon = false,
  }) {
    final isSelected = _filter.order == value;

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _filter = _filter.copyWith(order: value)),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
          decoration: BoxDecoration(
            color: isSelected ? _red : _surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? _red : const Color(0xFFDDDDDD),
              width: 1.5,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Transform.scale(
                scaleX: flipIcon ? -1 : 1,
                child: Icon(icon, color: isSelected ? _white : _grey, size: 18),
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? _white : _dark,
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPriceRangeChip({
    required String label,
    required CutsPriceRange value,
  }) {
    final isSelected = _filter.priceRange == value;

    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 90),
      child: GestureDetector(
        onTap: () => setState(() {
          final next = _filter.priceRange == value ? CutsPriceRange.all : value;
          _filter = _filter.copyWith(priceRange: next);
        }),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? _red : _surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? _red : const Color(0xFFDDDDDD),
              width: 1.5,
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: isSelected ? _white : _dark,
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
