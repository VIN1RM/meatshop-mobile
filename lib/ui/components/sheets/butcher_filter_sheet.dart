import 'package:flutter/material.dart';
import 'package:meatshop_mobile/providers/unit/unit_provider.dart';
import 'package:provider/provider.dart';

enum AcougueOrdem {
  nomeAZ,
  nomeZA,
  avaliacaoMaior,
  avaliacaoMenor,
  precoMaior,
  precoMenor,
  proximidade,
}

class AcougueFilter {
  final AcougueOrdem ordem;
  final bool apenasAbertos;

  const AcougueFilter({
    this.ordem = AcougueOrdem.avaliacaoMaior,
    this.apenasAbertos = false,
  });

  AcougueFilter copyWith({AcougueOrdem? ordem, bool? apenasAbertos}) {
    return AcougueFilter(
      ordem: ordem ?? this.ordem,
      apenasAbertos: apenasAbertos ?? this.apenasAbertos,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is AcougueFilter &&
      other.ordem == ordem &&
      other.apenasAbertos == apenasAbertos;

  @override
  int get hashCode => Object.hash(ordem, apenasAbertos);
}

class AcougueFilterSheet extends StatefulWidget {
  final AcougueFilter filtroAtual;
  final ValueChanged<AcougueFilter> onAplicar;

  const AcougueFilterSheet({
    super.key,
    required this.filtroAtual,
    required this.onAplicar,
  });

  static Future<AcougueFilter?> show(
    BuildContext context,
    AcougueFilter filtroAtual,
  ) {
    return showModalBottomSheet<AcougueFilter>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) => ChangeNotifierProvider.value(
        value: context.read<UnitProvider>(),
        child: AcougueFilterSheet(
          filtroAtual: filtroAtual,
          onAplicar: (f) => Navigator.pop(sheetContext, f),
        ),
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

  late AcougueFilter _filtro;

  @override
  void initState() {
    super.initState();
    _filtro = widget.filtroAtual;
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
                  () => _filtro = _filtro.copyWith(
                    apenasAbertos: !_filtro.apenasAbertos,
                  ),
                ),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: _filtro.apenasAbertos
                        ? const Color(0xFF27AE60).withValues(alpha: 0.1)
                        : _surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _filtro.apenasAbertos
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
                          color: _filtro.apenasAbertos
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
                            color: _filtro.apenasAbertos
                                ? const Color(0xFF1E7E46)
                                : const Color(0xFF555555),
                            fontSize: 14,
                            fontWeight: _filtro.apenasAbertos
                                ? FontWeight.w700
                                : FontWeight.w500,
                          ),
                        ),
                      ),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 180),
                        child: _filtro.apenasAbertos
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
              _sectionLabel('Localização'),
              const SizedBox(height: 10),
              Consumer<UnitProvider>(
                builder: (context, unitProvider, _) {
                  if (!unitProvider.hasLocation) return const SizedBox.shrink();
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          _optionChip(
                            label: 'Mais próximos',
                            icon: Icons.near_me_rounded,
                            valor: AcougueOrdem.proximidade,
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                    ],
                  );
                },
              ),
              _sectionLabel('Ordem Alfabética'),
              const SizedBox(height: 10),
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

              const SizedBox(height: 20),
              _sectionLabel('Avaliação'),
              const SizedBox(height: 10),
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

              const SizedBox(height: 20),
              _sectionLabel('Preço'),
              const SizedBox(height: 10),
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
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _filtro = const AcougueFilter();
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
    required AcougueOrdem valor,
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
