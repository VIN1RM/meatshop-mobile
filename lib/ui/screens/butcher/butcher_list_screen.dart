import 'package:flutter/material.dart';
import 'package:meatshop_mobile/routes/app_routes.dart';
import 'package:meatshop_mobile/ui/widgets/app_header.dart';
import 'package:meatshop_mobile/ui/components/sheets/butcher_filter_sheet.dart';
import 'package:meatshop_mobile/ui/widgets/loading_widget.dart';
import 'package:meatshop_mobile/ui/widgets/search_widget.dart';
import 'package:provider/provider.dart';
import 'package:meatshop_mobile/providers/unit/unit_provider.dart';
import 'package:meatshop_mobile/models/unit_model.dart';

class AcouguesScreen extends StatefulWidget {
  const AcouguesScreen({super.key});

  @override
  State<AcouguesScreen> createState() => _AcouguesScreenState();
}

class _AcouguesScreenState extends State<AcouguesScreen> {
  static const Color _red = Color(0xFFC0392B);
  static const Color _surface = Color(0xFF3A3A3A);
  static const Color _bg = Color(0xFF2E2E2E);
  static const Color _white = Colors.white;

  AcougueFilter _filtro = const AcougueFilter();
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

  List<UnitModel> _aplicarFiltro(List<UnitModel> lista, UnitProvider provider) {
    var resultado = List<UnitModel>.from(lista);

    final query = _searchController.text.trim().toLowerCase();
    if (query.isNotEmpty) {
      resultado = resultado
          .where((u) => u.name.toLowerCase().contains(query))
          .toList();
    }

    if (_filtro.apenasAbertos) {
      resultado = resultado.where((u) => provider.isOpenNow(u.id)).toList();
    }

    switch (_filtro.ordem) {
      case AcougueOrdem.nomeAZ:
        resultado.sort((a, b) => a.name.compareTo(b.name));
      case AcougueOrdem.nomeZA:
        resultado.sort((a, b) => b.name.compareTo(a.name));
      default:
        break;
    }

    return resultado;
  }

  String get _filtroLabel {
    final parts = <String>[];
    if (_filtro.apenasAbertos) parts.add('Abertos agora');
    switch (_filtro.ordem) {
      case AcougueOrdem.nomeAZ:
        parts.add('A → Z');
      case AcougueOrdem.nomeZA:
        parts.add('Z → A');
      case AcougueOrdem.avaliacaoMaior:
        parts.add('Maior avaliação');
      case AcougueOrdem.avaliacaoMenor:
        parts.add('Menor avaliação');
      case AcougueOrdem.precoMaior:
        parts.add('Maior preço');
      case AcougueOrdem.precoMenor:
        parts.add('Menor preço');
    }
    return parts.join(' · ');
  }

  bool get _filtroAtivo =>
      _filtro.apenasAbertos || _filtro.ordem != AcougueOrdem.avaliacaoMaior;

  Future<void> _abrirFiltro() async {
    final resultado = await AcougueFilterSheet.show(context, _filtro);
    if (resultado != null && resultado != _filtro) {
      setState(() => _filtro = resultado);
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
                errorBuilder: (_, __, ___) =>
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
                              onTap: _abrirFiltro,
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: _filtroAtivo ? _red : _surface,
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
                                    if (_filtroAtivo)
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
                              _filtroLabel,
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
                            final lista = _aplicarFiltro(
                              provider.units,
                              provider,
                            );
                            if (lista.isEmpty) {
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
                                      _filtro.apenasAbertos
                                          ? 'Nenhum açougue aberto agora.'
                                          : 'Nenhum resultado encontrado.',
                                      style: const TextStyle(
                                        color: Colors.white38,
                                        fontSize: 14,
                                      ),
                                    ),
                                    if (_filtroAtivo) ...[
                                      const SizedBox(height: 8),
                                      GestureDetector(
                                        onTap: () => setState(
                                          () => _filtro = const AcougueFilter(),
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
                              itemCount: lista.length,
                              itemBuilder: (_, i) =>
                                  _buildAcougueItem(lista[i], provider),
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

  Widget _buildAcougueItem(UnitModel u, UnitProvider provider) {
    final hours = provider.hoursFor(u.id);
    final isOpen = provider.isOpenNow(u.id);
    final hasHours = hours != null;

    return GestureDetector(
      onTap: () =>
          Navigator.pushNamed(context, AppRoutes.butcherDetail, arguments: u),
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
                child: u.imageUrl.isNotEmpty
                    ? Image.network(
                        u.imageUrl,
                        width: 52,
                        height: 52,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _logoFallback(),
                      )
                    : _logoFallback(),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      u.name,
                      style: const TextStyle(
                        color: _white,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                    if (u.city.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        u.city,
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
