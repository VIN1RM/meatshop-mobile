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

  AcougueOrdem _ordemAtual = AcougueOrdem.avaliacaoMaior;
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

  List<UnitModel> _ordenar(List<UnitModel> lista) {
    final copia = List<UnitModel>.from(lista);
    switch (_ordemAtual) {
      case AcougueOrdem.nomeAZ:
        copia.sort((a, b) => a.name.compareTo(b.name));
      case AcougueOrdem.nomeZA:
        copia.sort((a, b) => b.name.compareTo(a.name));
      default:
        break;
    }
    return copia;
  }

  String get _ordemLabel {
    switch (_ordemAtual) {
      case AcougueOrdem.nomeAZ:
        return 'A → Z';
      case AcougueOrdem.nomeZA:
        return 'Z → A';
      case AcougueOrdem.avaliacaoMaior:
        return 'Maior avaliação';
      case AcougueOrdem.avaliacaoMenor:
        return 'Menor avaliação';
      case AcougueOrdem.precoMaior:
        return 'Maior preço';
      case AcougueOrdem.precoMenor:
        return 'Menor preço';
    }
  }

  Future<void> _abrirFiltro() async {
    final resultado = await AcougueFilterSheet.show(context, _ordemAtual);
    if (resultado != null && resultado != _ordemAtual) {
      setState(() => _ordemAtual = resultado);
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
                              color: _red.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: _red.withOpacity(0.4),
                                width: 1,
                              ),
                            ),
                            child: Text(
                              _ordemLabel,
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
                            final lista = _ordenar(provider.units);
                            return ListView.builder(
                              physics: const BouncingScrollPhysics(),
                              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                              itemCount: lista.length,
                              itemBuilder: (_, i) =>
                                  _buildAcougueItem(lista[i]),
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

  Widget _buildAcougueItem(UnitModel u) {
    return GestureDetector(
      onTap: () =>
          Navigator.pushNamed(context, AppRoutes.butcherDetail, arguments: u),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: _surface,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: u.imageUrl.isNotEmpty
                  ? Image.network(
                      u.imageUrl,
                      width: 48,
                      height: 48,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _logoFallback(),
                    )
                  : _logoFallback(),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                u.name,
                style: const TextStyle(
                  color: _white,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const Icon(Icons.star_rounded, color: Color(0xFFFFB800), size: 18),
          ],
        ),
      ),
    );
  }

  Widget _logoFallback() {
    return Container(
      width: 48,
      height: 48,
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
