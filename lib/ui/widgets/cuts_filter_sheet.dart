import 'package:flutter/material.dart';

enum CortesOrdem {
  nomeAZ,
  nomeZA,
  precoMaior,
  precoMenor,
}

class CortesFilterSheet extends StatefulWidget {
  final CortesOrdem ordemAtual;
  final ValueChanged<CortesOrdem> onAplicar;

  const CortesFilterSheet({
    super.key,
    required this.ordemAtual,
    required this.onAplicar,
  });

  static Future<CortesOrdem?> show(
    BuildContext context,
    CortesOrdem ordemAtual,
  ) {
    return showModalBottomSheet<CortesOrdem>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => CortesFilterSheet(
        ordemAtual: ordemAtual,
        onAplicar: (ordem) => Navigator.pop(context, ordem),
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

  late CortesOrdem _selecionado;

  @override
  void initState() {
    super.initState();
    _selecionado = widget.ordemAtual;
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
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Icon(Icons.close, color: Colors.white38, size: 22),
              ),
            ],
          ),
          const SizedBox(height: 20),

          _sectionLabel('Ordem Alfabética'),
          const SizedBox(height: 8),
          Row(
            children: [
              _optionChip(
                label: 'A → Z',
                icon: Icons.sort_by_alpha_rounded,
                valor: CortesOrdem.nomeAZ,
              ),
              const SizedBox(width: 10),
              _optionChip(
                label: 'Z → A',
                icon: Icons.sort_by_alpha_rounded,
                valor: CortesOrdem.nomeZA,
                iconFlipped: true,
              ),
            ],
          ),
          const SizedBox(height: 18),

          _sectionLabel('Preço'),
          const SizedBox(height: 8),
          Row(
            children: [
              _optionChip(
                label: 'Maior preço',
                icon: Icons.attach_money_rounded,
                valor: CortesOrdem.precoMaior,
              ),
              const SizedBox(width: 10),
              _optionChip(
                label: 'Menor preço',
                icon: Icons.money_off_rounded,
                valor: CortesOrdem.precoMenor,
              ),
            ],
          ),
          const SizedBox(height: 28),

          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () => widget.onAplicar(_selecionado),
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
        fontSize: 12,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.8,
      ),
    );
  }

  Widget _optionChip({
    required String label,
    required IconData icon,
    required CortesOrdem valor,
    bool iconFlipped = false,
  }) {
    final selected = _selecionado == valor;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selecionado = valor),
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
}