import 'package:flutter/material.dart';
import 'package:meatshop_mobile/ui/screens/cuts/bovine_cuts_screen.dart';
import 'package:meatshop_mobile/ui/widgets/cuts_filter_sheet.dart';
import 'package:meatshop_mobile/ui/widgets/search_widget.dart';

class SwineCortsScreen extends StatefulWidget {
  const SwineCortsScreen({super.key});

  @override
  State<SwineCortsScreen> createState() => _SwineCortsScreenState();
}

class _SwineCortsScreenState extends State<SwineCortsScreen> {
  static const Color _red = Color(0xFFC0392B);
  static const Color _surface = Color(0xFF3A3A3A);
  static const Color _bg = Color(0xFF2E2E2E);
  static const Color _white = Colors.white;

  CortesFilter _filtro = const CortesFilter();

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  final List<CorteModel> _todos = const [
    CorteModel(
      nome: 'Lombo suíno',
      preco: 17.99,
      unidade: '/kg',
      imagemAsset: 'assets/images/lombo.png',
    ),
    CorteModel(
      nome: 'Costela suína',
      preco: 19.90,
      unidade: '/kg',
      imagemAsset: 'assets/images/costela_suina.png',
    ),
    CorteModel(
      nome: 'Pernil',
      preco: 14.99,
      unidade: '/kg',
      imagemAsset: 'assets/images/pernil.png',
    ),
    CorteModel(
      nome: 'Panceta',
      preco: 22.90,
      unidade: '/kg',
      imagemAsset: 'assets/images/panceta.png',
    ),
    CorteModel(
      nome: 'Paleta suína',
      preco: 13.50,
      unidade: '/kg',
      imagemAsset: 'assets/images/paleta_suina.png',
    ),
    CorteModel(
      nome: 'Filé de lombo',
      preco: 24.99,
      unidade: '/kg',
      imagemAsset: 'assets/images/file_lombo.png',
    ),
    CorteModel(
      nome: 'Bisteca suína',
      preco: 18.90,
      unidade: '/kg',
      imagemAsset: 'assets/images/bisteca_suina.png',
    ),
    CorteModel(
      nome: 'Toucinho',
      preco: 9.99,
      unidade: '/kg',
      imagemAsset: 'assets/images/toucinho.png',
    ),
    CorteModel(
      nome: 'Joelho suíno',
      preco: 12.90,
      unidade: '/kg',
      imagemAsset: 'assets/images/joelho_suino.png',
    ),
    CorteModel(
      nome: 'Linguiça calabresa',
      preco: 21.99,
      unidade: '/kg',
      imagemAsset: 'assets/images/linguica_calabresa.png',
    ),
  ];

  List<CorteModel> get _filtrados {
    var lista = List<CorteModel>.from(_todos);

    if (_searchQuery.isNotEmpty) {
      lista = lista
          .where(
            (c) => c.nome.toLowerCase().contains(_searchQuery.toLowerCase()),
          )
          .toList();
    }

    lista = lista.where((c) => _filtro.aplicarFaixa(c.preco)).toList();

    switch (_filtro.ordem) {
      case CortesOrdem.nomeAZ:
        lista.sort((a, b) => a.nome.compareTo(b.nome));
      case CortesOrdem.nomeZA:
        lista.sort((a, b) => b.nome.compareTo(a.nome));
      case CortesOrdem.precoMaior:
        lista.sort((a, b) => b.preco.compareTo(a.preco));
      case CortesOrdem.precoMenor:
        lista.sort((a, b) => a.preco.compareTo(b.preco));
    }

    return lista;
  }

  String get _ordemLabel {
    final labels = <String>[];

    switch (_filtro.ordem) {
      case CortesOrdem.nomeAZ:
        labels.add('A → Z');
      case CortesOrdem.nomeZA:
        labels.add('Z → A');
      case CortesOrdem.precoMaior:
        labels.add('Maior preço');
      case CortesOrdem.precoMenor:
        labels.add('Menor preço');
    }

    switch (_filtro.faixaPreco) {
      case CortesFaixaPreco.ate20:
        labels.add('Até R\$20');
      case CortesFaixaPreco.de20a50:
        labels.add('R\$20–R\$50');
      case CortesFaixaPreco.acima50:
        labels.add('Acima R\$50');
      case CortesFaixaPreco.todas:
        break;
    }

    return labels.join(' · ');
  }

  Future<void> _abrirFiltro() async {
    final resultado = await CortesFilterSheet.show(context, _filtro);
    if (resultado != null) {
      setState(() => _filtro = resultado);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final lista = _filtrados;

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
                _buildHeader(context),
                SearchWidget(
                  controller: _searchController,
                  hintText: 'Procure por um corte específico',
                  showBackButton: true,
                  onChanged: (v) => setState(() => _searchQuery = v),
                ),
                Expanded(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
                        child: Row(
                          children: [
                            const Text(
                              'CORTES SUÍNOS',
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
                              color: _red.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: _red.withValues(alpha: 0.4),
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
                        child: lista.isEmpty
                            ? const Center(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.search_off_rounded,
                                      color: Colors.white24,
                                      size: 48,
                                    ),
                                    SizedBox(height: 12),
                                    Text(
                                      'Nenhum corte encontrado',
                                      style: TextStyle(
                                        color: Colors.white38,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : ListView.builder(
                                physics: const BouncingScrollPhysics(),
                                padding: const EdgeInsets.fromLTRB(
                                  16,
                                  8,
                                  16,
                                  24,
                                ),
                                itemCount: lista.length,
                                itemBuilder: (_, i) =>
                                    _buildCorteItem(lista[i]),
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

  Widget _buildHeader(BuildContext context) {
    return Container(
      color: Colors.transparent,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: const BoxDecoration(
              color: _white,
              shape: BoxShape.circle,
            ),
            child: ClipOval(
              child: Image.asset(
                'assets/images/logo1.png',
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => const Icon(
                  Icons.storefront_outlined,
                  color: _red,
                  size: 22,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          const Text(
            'MeatShop',
            style: TextStyle(
              color: _white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
          const Spacer(),
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              border: Border.all(color: _white, width: 1.5),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.help_outline, color: _white, size: 20),
          ),
        ],
      ),
    );
  }

  Widget _buildCorteItem(CorteModel corte) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.horizontal(
              left: Radius.circular(12),
            ),
            child: Image.asset(
              corte.imagemAsset,
              width: 72,
              height: 72,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: 72,
                height: 72,
                color: const Color(0xFF555555),
                child: const Icon(
                  Icons.image_outlined,
                  color: Colors.white24,
                  size: 28,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              corte.nome,
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
                    text: corte.precoFormatado,
                    style: const TextStyle(
                      color: _red,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextSpan(
                    text: corte.unidade,
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
}
