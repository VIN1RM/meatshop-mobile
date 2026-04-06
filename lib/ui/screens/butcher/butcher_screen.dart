import 'package:flutter/material.dart';
import 'package:meatshop_mobile/ui/widgets/butcher_filter_sheet.dart';

class AcougueModel {
  final String nome;
  final double rating;
  final int faixaPreco;
  final String logoAsset;

  const AcougueModel({
    required this.nome,
    required this.rating,
    required this.faixaPreco,
    required this.logoAsset,
  });

  String get faixaPrecoLabel => '\$' * faixaPreco;
}

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

  final List<AcougueModel> _todos = const [
    AcougueModel(
      nome: 'Master Carnes',
      rating: 5.0,
      faixaPreco: 2,
      logoAsset: 'assets/images/logo_master.png',
    ),
    AcougueModel(
      nome: 'Frigorífico Goiás',
      rating: 4.5,
      faixaPreco: 3,
      logoAsset: 'assets/images/logo_frigorifico.png',
    ),
    AcougueModel(
      nome: 'Bom Beef',
      rating: 4.0,
      faixaPreco: 3,
      logoAsset: 'assets/images/logo_bombeff.png',
    ),
    AcougueModel(
      nome: 'Bifão Carnes',
      rating: 4.0,
      faixaPreco: 3,
      logoAsset: 'assets/images/logo_bifao.png',
    ),
    AcougueModel(
      nome: 'Mendes',
      rating: 4.0,
      faixaPreco: 2,
      logoAsset: 'assets/images/logo_mendes.png',
    ),
    AcougueModel(
      nome: 'Disk Suíno',
      rating: 3.5,
      faixaPreco: 2,
      logoAsset: 'assets/images/logo_disksuino.png',
    ),
    AcougueModel(
      nome: 'Rio Branco',
      rating: 3.5,
      faixaPreco: 2,
      logoAsset: 'assets/images/logo_riobranco.png',
    ),
    AcougueModel(
      nome: 'Casa de Carne Marcos',
      rating: 3.0,
      faixaPreco: 1,
      logoAsset: 'assets/images/logo_marcos.png',
    ),
    AcougueModel(
      nome: 'Filé de Ouro',
      rating: 2.5,
      faixaPreco: 1,
      logoAsset: 'assets/images/logo_fileouro.png',
    ),
    AcougueModel(
      nome: 'Peixaria do Ronaldão',
      rating: 2.0,
      faixaPreco: 1,
      logoAsset: 'assets/images/logo_ronaldao.png',
    ),
  ];

  List<AcougueModel> get _ordenados {
    final lista = List<AcougueModel>.from(_todos);
    switch (_ordemAtual) {
      case AcougueOrdem.nomeAZ:
        lista.sort((a, b) => a.nome.compareTo(b.nome));
      case AcougueOrdem.nomeZA:
        lista.sort((a, b) => b.nome.compareTo(a.nome));
      case AcougueOrdem.avaliacaoMaior:
        lista.sort((a, b) => b.rating.compareTo(a.rating));
      case AcougueOrdem.avaliacaoMenor:
        lista.sort((a, b) => a.rating.compareTo(b.rating));
      case AcougueOrdem.precoMaior:
        lista.sort((a, b) => b.faixaPreco.compareTo(a.faixaPreco));
      case AcougueOrdem.precoMenor:
        lista.sort((a, b) => a.faixaPreco.compareTo(b.faixaPreco));
    }
    return lista;
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
    final lista = _ordenados;

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
                        child: ListView.builder(
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                          itemCount: lista.length,
                          itemBuilder: (_, i) => _buildAcougueItem(lista[i]),
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

  final TextEditingController _searchController = TextEditingController();

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
              decoration: InputDecoration(
                hintText: 'Procure por um estabelecimento',
                hintStyle: const TextStyle(color: Colors.white38, fontSize: 14),
                prefixIcon: const Icon(
                  Icons.search,
                  color: Colors.white38,
                  size: 20,
                ),
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

  Widget _buildAcougueItem(AcougueModel a) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: const BoxDecoration(
              color: Color(0xFF555555),
              shape: BoxShape.circle,
            ),
            child: ClipOval(
              child: Image.asset(
                a.logoAsset,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const Icon(
                  Icons.storefront_outlined,
                  color: Colors.white38,
                  size: 22,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  a.nome,
                  style: const TextStyle(
                    color: _white,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  a.faixaPrecoLabel,
                  style: const TextStyle(
                    color: Colors.white38,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),

          _buildStars(a.rating),
        ],
      ),
    );
  }

  Widget _buildStars(double rating) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        final filled = i < rating.floor();
        final half = !filled && i < rating;
        return Icon(
          half
              ? Icons.star_half_rounded
              : (filled ? Icons.star_rounded : Icons.star_outline_rounded),
          color: const Color(0xFFFFB800),
          size: 18,
        );
      }),
    );
  }
}
