import 'package:flutter/material.dart';
import 'package:meatshop_mobile/ui/screens/cuts/bovine_cuts_screen.dart';
import 'package:meatshop_mobile/ui/widgets/cuts_filter_sheet.dart';

class PoultryCortsScreen extends StatefulWidget {
  const PoultryCortsScreen({super.key});

  @override
  State<PoultryCortsScreen> createState() => _PoultryCortsScreenState();
}

class _PoultryCortsScreenState extends State<PoultryCortsScreen> {
  static const Color _red = Color(0xFFC0392B);
  static const Color _surface = Color(0xFF3A3A3A);
  static const Color _bg = Color(0xFF2E2E2E);
  static const Color _white = Colors.white;

  CortesOrdem _ordemAtual = CortesOrdem.nomeAZ;

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  final List<CorteModel> _todos = const [
    CorteModel(
      nome: 'Peito de frango',
      preco: 9.99,
      unidade: '/kg',
      imagemAsset: 'assets/images/peitodefrango.png',
    ),
    CorteModel(
      nome: 'Coxa e sobrecoxa',
      preco: 8.49,
      unidade: '/kg',
      imagemAsset: 'assets/images/coxa_sobrecoxa.png',
    ),
    CorteModel(
      nome: 'Asa de frango',
      preco: 7.99,
      unidade: '/kg',
      imagemAsset: 'assets/images/asa_frango.png',
    ),
    CorteModel(
      nome: 'Filé de frango',
      preco: 14.90,
      unidade: '/kg',
      imagemAsset: 'assets/images/file_frango.png',
    ),
    CorteModel(
      nome: 'Frango inteiro',
      preco: 7.49,
      unidade: '/kg',
      imagemAsset: 'assets/images/frango_inteiro.png',
    ),
    CorteModel(
      nome: 'Coração de frango',
      preco: 11.99,
      unidade: '/kg',
      imagemAsset: 'assets/images/coracao_frango.png',
    ),
    CorteModel(
      nome: 'Moela',
      preco: 6.99,
      unidade: '/kg',
      imagemAsset: 'assets/images/moela.png',
    ),
    CorteModel(
      nome: 'Fígado de frango',
      preco: 6.49,
      unidade: '/kg',
      imagemAsset: 'assets/images/figado_frango.png',
    ),
    CorteModel(
      nome: 'Pescoço de frango',
      preco: 4.99,
      unidade: '/kg',
      imagemAsset: 'assets/images/pescoco_frango.png',
    ),
    CorteModel(
      nome: 'Peito de peru',
      preco: 19.90,
      unidade: '/kg',
      imagemAsset: 'assets/images/peito_peru.png',
    ),
    CorteModel(
      nome: 'Coxa de peru',
      preco: 16.99,
      unidade: '/kg',
      imagemAsset: 'assets/images/coxa_peru.png',
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

    switch (_ordemAtual) {
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
    switch (_ordemAtual) {
      case CortesOrdem.nomeAZ:
        return 'A → Z';
      case CortesOrdem.nomeZA:
        return 'Z → A';
      case CortesOrdem.precoMaior:
        return 'Maior preço';
      case CortesOrdem.precoMenor:
        return 'Menor preço';
    }
  }

  Future<void> _abrirFiltro() async {
    final resultado = await CortesFilterSheet.show(context, _ordemAtual);
    if (resultado != null && resultado != _ordemAtual) {
      setState(() => _ordemAtual = resultado);
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
                _buildSearchBar(),
                Expanded(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
                        child: Row(
                          children: [
                            const Text(
                              'CORTES DE AVES',
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

  Widget _buildSearchBar() {
    return Container(
      color: Colors.transparent,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 36,
              height: 36,
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color: Colors.black26,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.arrow_back,
                color: Colors.white70,
                size: 20,
              ),
            ),
          ),
          Expanded(
            child: TextField(
              controller: _searchController,
              style: const TextStyle(color: _white, fontSize: 14),
              cursorColor: _red,
              onChanged: (v) => setState(() => _searchQuery = v),
              decoration: InputDecoration(
                hintText: 'Procure por um corte específico',
                hintStyle: const TextStyle(color: Colors.white38, fontSize: 14),
                prefixIcon: const Icon(
                  Icons.search,
                  color: Colors.white38,
                  size: 20,
                ),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(
                          Icons.close,
                          color: Colors.white38,
                          size: 18,
                        ),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
                filled: true,
                fillColor: Colors.black26,
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
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
