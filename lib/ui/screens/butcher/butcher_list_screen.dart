import 'package:flutter/material.dart';
import 'package:meatshop_mobile/routes/app_routes.dart';
import 'package:meatshop_mobile/ui/widgets/app_header.dart';
import 'package:meatshop_mobile/ui/components/sheets/butcher_filter_sheet.dart';
import 'package:meatshop_mobile/ui/widgets/loading_widget.dart';
import 'package:meatshop_mobile/ui/widgets/search_widget.dart';
import 'package:provider/provider.dart';
import 'package:meatshop_mobile/providers/unit/unit_provider.dart';
import 'package:meatshop_mobile/models/unit_model.dart';

class ButcherListScreen extends StatefulWidget {
  const ButcherListScreen({super.key});

  @override
  State<ButcherListScreen> createState() => _ButcherListScreenState();
}

class _ButcherListScreenState extends State<ButcherListScreen> {
  static const Color _red = Color(0xFFC0392B);
  static const Color _surface = Color(0xFF3A3A3A);
  static const Color _bg = Color(0xFF2E2E2E);
  static const Color _white = Colors.white;

  ButcherFilter _filter = const ButcherFilter();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<UnitProvider>().loadUnits();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<UnitModel> _applyFilter(List<UnitModel> units, UnitProvider provider) {
    var filteredUnits = List<UnitModel>.from(units);

    final query = _searchController.text.trim().toLowerCase();
    if (query.isNotEmpty) {
      filteredUnits = filteredUnits
          .where((u) => u.name.toLowerCase().contains(query))
          .toList();
    }

    if (_filter.openNowOnly) {
      filteredUnits = filteredUnits
          .where((unit) => provider.isOpenNow(unit.id))
          .toList();
    }

    switch (_filter.sortOrder) {
      case ButcherSortOrder.nameAscending:
        filteredUnits.sort((a, b) => a.name.compareTo(b.name));
      case ButcherSortOrder.nameDescending:
        filteredUnits.sort((a, b) => b.name.compareTo(a.name));
      case ButcherSortOrder.ratingDescending:
        filteredUnits.sort(
          (a, b) => b.averageRating.compareTo(a.averageRating),
        );
      case ButcherSortOrder.ratingAscending:
        filteredUnits.sort(
          (a, b) => a.averageRating.compareTo(b.averageRating),
        );
      case ButcherSortOrder.priceDescending:
      case ButcherSortOrder.priceAscending:
        break;
    }

    return filteredUnits;
  }

  String get _filterLabel {
    final parts = <String>[];
    if (_filter.openNowOnly) parts.add('Abertos agora');
    switch (_filter.sortOrder) {
      case ButcherSortOrder.nameAscending:
        parts.add('A → Z');
      case ButcherSortOrder.nameDescending:
        parts.add('Z → A');
      case ButcherSortOrder.ratingDescending:
        parts.add('Maior avaliação');
      case ButcherSortOrder.ratingAscending:
        parts.add('Menor avaliação');
      case ButcherSortOrder.priceDescending:
        parts.add('Maior preço');
      case ButcherSortOrder.priceAscending:
        parts.add('Menor preço');
    }
    return parts.join(' · ');
  }

  bool get _filterActive =>
      _filter.openNowOnly ||
      _filter.sortOrder != ButcherSortOrder.ratingDescending;

  Future<void> _openFilter() async {
    final selectedFilter = await ButcherFilterSheet.show(context, _filter);
    if (selectedFilter != null && selectedFilter != _filter) {
      setState(() => _filter = selectedFilter);
    }
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
                errorBuilder: (_, _, _) =>
                    Container(color: const Color(0xFF1A1A1A)),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                SizedBox(
                  height: 130,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.asset(
                        'assets/images/background.png',
                        fit: BoxFit.cover,
                      ),
                      const SafeArea(child: AppHeader()),
                    ],
                  ),
                ),
                SearchWidget(
                  controller: _searchController,
                  hintText: 'Procure por um estabelecimento',
                  showBackButton: true,
                  onChanged: (_) => setState(() {}),
                ),
                Expanded(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
                        child: Row(
                          children: [
                            const Text(
                              'AÇOUGUES',
                              style: TextStyle(
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
                                  color: _filterActive ? _red : _surface,
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
                                    if (_filterActive)
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
                              _filterLabel,
                              style: const TextStyle(
                                color: _red,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Consumer<UnitProvider>(
                          builder: (context, provider, _) {
                            if (provider.loading) {
                              return const Padding(
                                padding: EdgeInsets.symmetric(vertical: 16),
                                child: Center(child: MeatShopLoader()),
                              );
                            }
                            if (provider.units.isEmpty) {
                              return const Center(
                                child: Text(
                                  'Nenhum açougue disponível.',
                                  style: TextStyle(color: Colors.white38),
                                ),
                              );
                            }
                            final filteredUnits = _applyFilter(
                              provider.units,
                              provider,
                            );
                            if (filteredUnits.isEmpty) {
                              return Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.search_off_rounded,
                                      color: Colors.white24,
                                      size: 48,
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      _filter.openNowOnly
                                          ? 'Nenhum açougue aberto agora.'
                                          : 'Nenhum resultado encontrado.',
                                      style: const TextStyle(
                                        color: Colors.white38,
                                        fontSize: 14,
                                      ),
                                    ),
                                    if (_filterActive) ...[
                                      const SizedBox(height: 8),
                                      GestureDetector(
                                        onTap: () => setState(
                                          () => _filter = const ButcherFilter(),
                                        ),
                                        child: const Text(
                                          'Limpar filtros',
                                          style: TextStyle(
                                            color: Color(0xFFC0392B),
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                            decoration:
                                                TextDecoration.underline,
                                            decorationColor: Color(0xFFC0392B),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              );
                            }
                            return ListView.builder(
                              physics: const BouncingScrollPhysics(),
                              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                              itemCount: filteredUnits.length,
                              itemBuilder: (_, i) =>
                                  _buildButcherItem(filteredUnits[i], provider),
                            );
                          },
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
    );
  }

  Widget _buildButcherItem(UnitModel unit, UnitProvider provider) {
    final hours = provider.hoursFor(unit.id);
    final isOpen = provider.isOpenNow(unit.id);
    final hasHours = hours != null;

    return GestureDetector(
      onTap: () => Navigator.pushNamed(
        context,
        AppRoutes.butcherDetail,
        arguments: unit,
      ),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5),
        decoration: BoxDecoration(
          color: _surface,
          borderRadius: BorderRadius.circular(14),
          border: hasHours
              ? Border(
                  left: BorderSide(
                    color: isOpen
                        ? const Color(0xFF27AE60)
                        : const Color(0xFFC0392B),
                    width: 3,
                  ),
                )
              : null,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: unit.imageUrl.isNotEmpty
                    ? Image.network(
                        unit.imageUrl,
                        width: 52,
                        height: 52,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => _logoFallback(),
                      )
                    : _logoFallback(),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      unit.name,
                      style: const TextStyle(
                        color: _white,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                    if (unit.city.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        unit.city,
                        style: const TextStyle(
                          color: Colors.white38,
                          fontSize: 12,
                        ),
                      ),
                    ],
                    if (hasHours) ...[
                      const SizedBox(height: 5),
                      _OpenStatusBadge(isOpen: isOpen, hours: hours),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.chevron_right_rounded,
                color: Colors.white38,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _logoFallback() {
    return Container(
      width: 52,
      height: 52,
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
}

class _OpenStatusBadge extends StatelessWidget {
  const _OpenStatusBadge({required this.isOpen, required this.hours});

  final bool isOpen;
  final dynamic hours;

  @override
  Widget build(BuildContext context) {
    final color = isOpen ? const Color(0xFF27AE60) : const Color(0xFFC0392B);
    final label = isOpen ? 'Aberto agora' : 'Fechado';
    final sub = isOpen
        ? 'Fecha às ${hours.closingTime}'
        : hours.isOpen
        ? 'Abre às ${hours.openingTime}'
        : 'Fechado hoje';

    return Row(
      children: [
        Container(
          width: 7,
          height: 7,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 5),
        Flexible(
          child: Text(
            '$label · $sub',
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
