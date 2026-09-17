import 'package:flutter/material.dart';

enum ButcherSortOrder {
  nameAscending,
  nameDescending,
  ratingDescending,
  ratingAscending,
  priceDescending,
  priceAscending,
}

class ButcherFilter {
  final ButcherSortOrder sortOrder;
  final bool openNowOnly;

  const ButcherFilter({
    this.sortOrder = ButcherSortOrder.ratingDescending,
    this.openNowOnly = false,
  });

  ButcherFilter copyWith({ButcherSortOrder? sortOrder, bool? openNowOnly}) {
    return ButcherFilter(
      sortOrder: sortOrder ?? this.sortOrder,
      openNowOnly: openNowOnly ?? this.openNowOnly,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is ButcherFilter &&
      other.sortOrder == sortOrder &&
      other.openNowOnly == openNowOnly;

  @override
  int get hashCode => Object.hash(sortOrder, openNowOnly);
}

class ButcherFilterSheet extends StatefulWidget {
  final ButcherFilter currentFilter;
  final ValueChanged<ButcherFilter> onApply;

  const ButcherFilterSheet({
    super.key,
    required this.currentFilter,
    required this.onApply,
  });

  static Future<ButcherFilter?> show(
    BuildContext context,
    ButcherFilter currentFilter,
  ) {
    return showModalBottomSheet<ButcherFilter>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => ButcherFilterSheet(
        currentFilter: currentFilter,
        onApply: (filter) => Navigator.pop(context, filter),
      ),
    );
  }

  @override
  State<ButcherFilterSheet> createState() => _ButcherFilterSheetState();
}

class _ButcherFilterSheetState extends State<ButcherFilterSheet> {
  static const Color _red = Color(0xFFC0392B);
  static const Color _bg = Color(0xFFF5F5F5);
  static const Color _surface = Color(0xFFEAEAEA);
  static const Color _white = Colors.white;

  late ButcherFilter _filter;

  @override
  void initState() {
    super.initState();
    _filter = widget.currentFilter;
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final screenH = MediaQuery.of(context).size.height;

    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: screenH * 0.92),
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
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFDDDDDD),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  const Icon(Icons.filter_list_rounded, color: _red, size: 22),
                  const SizedBox(width: 8),
                  const Text(
                    'Filtrar Açougues',
                    style: TextStyle(
                      color: Color(0xFF1A1A1A),
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.4,
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(
                      Icons.close,
                      color: Color(0xFFAAAAAA),
                      size: 22,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              _sectionLabel('Disponibilidade'),
              const SizedBox(height: 10),
              GestureDetector(
                onTap: () => setState(
                  () => _filter = _filter.copyWith(
                    openNowOnly: !_filter.openNowOnly,
                  ),
                ),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: _filter.openNowOnly
                        ? const Color(0xFF27AE60).withValues(alpha: 0.1)
                        : _surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _filter.openNowOnly
                          ? const Color(0xFF27AE60)
                          : const Color(0xFFCCCCCC),
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: _filter.openNowOnly
                              ? const Color(0xFF27AE60)
                              : const Color(0xFFAAAAAA),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Apenas abertos agora',
                          style: TextStyle(
                            color: _filter.openNowOnly
                                ? const Color(0xFF1E7E46)
                                : const Color(0xFF555555),
                            fontSize: 14,
                            fontWeight: _filter.openNowOnly
                                ? FontWeight.w700
                                : FontWeight.w500,
                          ),
                        ),
                      ),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 180),
                        child: _filter.openNowOnly
                            ? const Icon(
                                Icons.check_circle_rounded,
                                color: Color(0xFF27AE60),
                                size: 20,
                                key: ValueKey('checked'),
                              )
                            : const Icon(
                                Icons.radio_button_unchecked_rounded,
                                color: Color(0xFFCCCCCC),
                                size: 20,
                                key: ValueKey('unchecked'),
                              ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),
              _sectionLabel('Ordem Alfabética'),
              const SizedBox(height: 10),
              Row(
                children: [
                  _optionChip(
                    label: 'A → Z',
                    icon: Icons.sort_by_alpha_rounded,
                    value: ButcherSortOrder.nameAscending,
                  ),
                  const SizedBox(width: 10),
                  _optionChip(
                    label: 'Z → A',
                    icon: Icons.sort_by_alpha_rounded,
                    value: ButcherSortOrder.nameDescending,
                    iconFlipped: true,
                  ),
                ],
              ),

              const SizedBox(height: 20),
              _sectionLabel('Avaliação'),
              const SizedBox(height: 10),
              Row(
                children: [
                  _optionChip(
                    label: 'Maior ★',
                    icon: Icons.star_rounded,
                    value: ButcherSortOrder.ratingDescending,
                  ),
                  const SizedBox(width: 10),
                  _optionChip(
                    label: 'Menor ★',
                    icon: Icons.star_outline_rounded,
                    value: ButcherSortOrder.ratingAscending,
                  ),
                ],
              ),

              const SizedBox(height: 20),
              _sectionLabel('Preço'),
              const SizedBox(height: 10),
              Row(
                children: [
                  _optionChip(
                    label: 'Maior \$\$',
                    icon: Icons.attach_money_rounded,
                    value: ButcherSortOrder.priceDescending,
                  ),
                  const SizedBox(width: 10),
                  _optionChip(
                    label: 'Menor \$',
                    icon: Icons.money_off_rounded,
                    value: ButcherSortOrder.priceAscending,
                  ),
                ],
              ),

              const SizedBox(height: 28),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _filter = const ButcherFilter();
                        });
                      },
                      child: Container(
                        height: 50,
                        decoration: BoxDecoration(
                          color: _surface,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFFCCCCCC)),
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
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        color: Color(0xFF888888),
        fontSize: 12,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.8,
      ),
    );
  }

  Widget _optionChip({
    required String label,
    required IconData icon,
    required ButcherSortOrder value,
    bool iconFlipped = false,
  }) {
    final selected = _filter.sortOrder == value;
    return Expanded(
      child: GestureDetector(
        onTap: () =>
            setState(() => _filter = _filter.copyWith(sortOrder: value)),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
          decoration: BoxDecoration(
            color: selected ? _red : _surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected ? _red : const Color(0xFFCCCCCC),
              width: 1.5,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Transform.scale(
                scaleX: iconFlipped ? -1 : 1,
                child: Icon(
                  icon,
                  color: selected ? _white : const Color(0xFFAAAAAA),
                  size: 18,
                ),
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  label,
                  style: TextStyle(
                    color: selected ? _white : const Color(0xFF555555),
                    fontSize: 13,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
