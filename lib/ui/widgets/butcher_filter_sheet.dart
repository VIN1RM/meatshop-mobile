import 'package:flutter/material.dart';

enum AcougueOrdem {
  nomeAZ,
  nomeZA,
  avaliacaoMaior,
  avaliacaoMenor,
  precoMaior,
  precoMenor,
}

class AcougueFilterSheet extends StatefulWidget {
  final AcougueOrdem ordemAtual;
  final ValueChanged<AcougueOrdem> onAplicar;

  const AcougueFilterSheet({
    super.key,
    required this.ordemAtual,
    required this.onAplicar,
  });

  static Future<AcougueOrdem?> show(
    BuildContext context,
    AcougueOrdem ordemAtual,
  ) {
    return showModalBottomSheet<AcougueOrdem>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => AcougueFilterSheet(
        ordemAtual: ordemAtual,
        onAplicar: (ordem) => Navigator.pop(context, ordem),
      ),
    );
  }

  @override
  State<AcougueFilterSheet> createState() => _AcougueFilterSheetState();
}

class _AcougueFilterSheetState extends State<AcougueFilterSheet> {
  static const Color _red = Color(0xFFC0392B);
  static const Color _bg = Color(0xFFF5F5F5);
  static const Color _surface = Color(0xFFEAEAEA);
  static const Color _white = Colors.white;

  late AcougueOrdem _selecionado;

  @override
  void initState() {
    super.initState();
    _selecionado = widget.ordemAtual;
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
                      color: const Color(0xFF1A1A1A),
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
                      color: const Color(0xFFAAAAAA),
                      size: 22,
                    ),
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
                    valor: AcougueOrdem.nomeAZ,
                  ),
                  const SizedBox(width: 10),
                  _optionChip(
                    label: 'Z → A',
                    icon: Icons.sort_by_alpha_rounded,
                    valor: AcougueOrdem.nomeZA,
                    iconFlipped: true,
                  ),
                ],
              ),
              const SizedBox(height: 18),

              _sectionLabel('Avaliação'),
              const SizedBox(height: 8),
              Row(
                children: [
                  _optionChip(
                    label: 'Maior ★',
                    icon: Icons.star_rounded,
                    valor: AcougueOrdem.avaliacaoMaior,
                  ),
                  const SizedBox(width: 10),
                  _optionChip(
                    label: 'Menor ★',
                    icon: Icons.star_outline_rounded,
                    valor: AcougueOrdem.avaliacaoMenor,
                  ),
                ],
              ),
              const SizedBox(height: 18),

              _sectionLabel('Preço'),
              const SizedBox(height: 8),
              Row(
                children: [
                  _optionChip(
                    label: 'Maior \$\$',
                    icon: Icons.attach_money_rounded,
                    valor: AcougueOrdem.precoMaior,
                  ),
                  const SizedBox(width: 10),
                  _optionChip(
                    label: 'Menor \$',
                    icon: Icons.money_off_rounded,
                    valor: AcougueOrdem.precoMenor,
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
        ),
      ),
    );
  }

  Widget _sectionLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        color: const Color(0xFF888888),
        fontSize: 12,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.8,
      ),
    );
  }

  Widget _optionChip({
    required String label,
    required IconData icon,
    required AcougueOrdem valor,
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
              Text(
                label,
                style: TextStyle(
                  color: selected ? _white : const Color(0xFF555555),
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
