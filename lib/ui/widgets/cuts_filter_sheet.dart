import 'package:flutter/material.dart';

enum CortesOrdem { nomeAZ, nomeZA, precoMaior, precoMenor }

enum CortesFaixaPreco { todas, ate20, de20a50, acima50 }

class CortesFilter {
  final CortesOrdem ordem;
  final CortesFaixaPreco faixaPreco;

  const CortesFilter({
    this.ordem = CortesOrdem.nomeAZ,
    this.faixaPreco = CortesFaixaPreco.todas,
  });

  CortesFilter copyWith({CortesOrdem? ordem, CortesFaixaPreco? faixaPreco}) {
    return CortesFilter(
      ordem: ordem ?? this.ordem,
      faixaPreco: faixaPreco ?? this.faixaPreco,
    );
  }

  bool get temFiltroAtivo => faixaPreco != CortesFaixaPreco.todas;

  bool aplicarFaixa(double preco) {
    switch (faixaPreco) {
      case CortesFaixaPreco.todas:
        return true;
      case CortesFaixaPreco.ate20:
        return preco <= 20;
      case CortesFaixaPreco.de20a50:
        return preco > 20 && preco <= 50;
      case CortesFaixaPreco.acima50:
        return preco > 50;
    }
  }
}

class CortesFilterSheet extends StatefulWidget {
  final CortesFilter filtroAtual;
  final ValueChanged<CortesFilter> onAplicar;

  const CortesFilterSheet({
    super.key,
    required this.filtroAtual,
    required this.onAplicar,
  });

  static Future<CortesFilter?> show(
    BuildContext context,
    CortesFilter filtroAtual,
  ) {
    return showModalBottomSheet<CortesFilter>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => CortesFilterSheet(
        filtroAtual: filtroAtual,
        onAplicar: (filtro) => Navigator.pop(context, filtro),
      ),
    );
  }

  @override
  State<CortesFilterSheet> createState() => _CortesFilterSheetState();
}

class _CortesFilterSheetState extends State<CortesFilterSheet> {
  static const Color _red = Color(0xFFC0392B);
  static const Color _bg = Color(0xFF2E2E2E);
  static const Color _surface = Color(0xFF3A3A3A);
  static const Color _white = Colors.white;

  late CortesFilter _filtro;

  @override
  void initState() {
    super.initState();
    _filtro = widget.filtroAtual;
  }

  void _limpar() {
    setState(() => _filtro = const CortesFilter());
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: _bg,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
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
                'Filtrar Cortes',
                style: TextStyle(
                  color: _white,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.4,
                ),
              ),
              const Spacer(),
              if (_filtro.temFiltroAtivo)
                GestureDetector(
                  onTap: _limpar,
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
                    child: const Text(
                      'Limpar',
                      style: TextStyle(
                        color: _red,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Icon(Icons.close, color: Colors.white38, size: 22),
              ),
            ],
          ),
          const SizedBox(height: 24),

          _sectionLabel('ORDEM ALFABÉTICA'),
          const SizedBox(height: 8),
          Row(
            children: [
              _ordemChip(
                label: 'A → Z',
                icon: Icons.sort_by_alpha_rounded,
                valor: CortesOrdem.nomeAZ,
              ),
              const SizedBox(width: 10),
              _ordemChip(
                label: 'Z → A',
                icon: Icons.sort_by_alpha_rounded,
                valor: CortesOrdem.nomeZA,
                iconFlipped: true,
              ),
            ],
          ),
          const SizedBox(height: 18),

          _sectionLabel('ORDENAR POR PREÇO'),
          const SizedBox(height: 8),
          Row(
            children: [
              _ordemChip(
                label: 'Maior preço',
                icon: Icons.arrow_upward_rounded,
                valor: CortesOrdem.precoMaior,
              ),
              const SizedBox(width: 10),
              _ordemChip(
                label: 'Menor preço',
                icon: Icons.arrow_downward_rounded,
                valor: CortesOrdem.precoMenor,
              ),
            ],
          ),
          const SizedBox(height: 18),

          _sectionLabel('FAIXA DE PREÇO'),
          const SizedBox(height: 8),
          Row(
            children: [
              _faixaChip(label: 'Até R\$20', valor: CortesFaixaPreco.ate20),
              const SizedBox(width: 8),
              _faixaChip(label: 'R\$20–R\$50', valor: CortesFaixaPreco.de20a50),
              const SizedBox(width: 8),
              _faixaChip(label: 'Acima R\$50', valor: CortesFaixaPreco.acima50),
            ],
          ),
          const SizedBox(height: 28),

          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () => widget.onAplicar(_filtro),
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
        ],
      ),
    );
  }

  Widget _sectionLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        color: Colors.white54,
        fontSize: 11,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.8,
      ),
    );
  }

  Widget _ordemChip({
    required String label,
    required IconData icon,
    required CortesOrdem valor,
    bool iconFlipped = false,
  }) {
    final selected = _filtro.ordem == valor;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _filtro = _filtro.copyWith(ordem: valor)),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
          decoration: BoxDecoration(
            color: selected ? _red : _surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected ? _red : Colors.white12,
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
                  color: selected ? _white : Colors.white54,
                  size: 18,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: selected ? _white : Colors.white70,
                  fontSize: 13,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _faixaChip({required String label, required CortesFaixaPreco valor}) {
    final selected = _filtro.faixaPreco == valor;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() {
          final nova = _filtro.faixaPreco == valor
              ? CortesFaixaPreco.todas
              : valor;
          _filtro = _filtro.copyWith(faixaPreco: nova);
        }),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected ? _red : _surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected ? _red : Colors.white12,
              width: 1.5,
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: selected ? _white : Colors.white70,
                fontSize: 12,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
