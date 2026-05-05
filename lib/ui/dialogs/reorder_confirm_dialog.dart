import 'package:flutter/material.dart';
import 'package:meatshop_mobile/routes/app_routes.dart';

class ReorderItem {
  final String nome;
  final String quantidade;
  const ReorderItem({required this.nome, required this.quantidade});
}

class ReorderConfirmDialog extends StatelessWidget {
  final String acougueNome;
  final List<ReorderItem> itens;
  final String total;

  const ReorderConfirmDialog({
    super.key,
    required this.acougueNome,
    required this.itens,
    required this.total,
  });

  static const Color _red = Color(0xFFBE2C1B);

  static Future<bool?> show(
    BuildContext context, {
    required String acougueNome,
    required List<ReorderItem> itens,
    required String total,
  }) {
    return showDialog<bool>(
      context: context,
      barrierColor: Colors.black54,
      builder: (_) => ReorderConfirmDialog(
        acougueNome: acougueNome,
        itens: itens,
        total: total,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFF2C2C2C),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildIcon(),
            const SizedBox(height: 16),
            _buildTitle(),
            const SizedBox(height: 16),
            _buildItemsList(),
            const SizedBox(height: 10),
            _buildTotalRow(),
            const SizedBox(height: 8),
            _buildPriceWarning(),
            const SizedBox(height: 24),
            _buildConfirmButton(context),
            const SizedBox(height: 10),
            _buildCancelButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildIcon() {
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        color: _red.withValues(alpha: 0.15),
        shape: BoxShape.circle,
      ),
      child: const Icon(Icons.replay_rounded, color: Colors.white, size: 26),
    );
  }

  Widget _buildTitle() {
    return Column(
      children: [
        const Text(
          'Pedir novamente',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          acougueNome,
          style: const TextStyle(color: Colors.white54, fontSize: 13),
        ),
      ],
    );
  }

  Widget _buildItemsList() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF3A3A3A),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: itens.map((item) {
          final isLast = item == itens.last;
          return Padding(
            padding: EdgeInsets.only(bottom: isLast ? 0 : 8),
            child: Row(
              children: [
                SizedBox(
                  width: 52,
                  child: Text(
                    item.quantidade,
                    style: const TextStyle(color: Colors.white54, fontSize: 12),
                  ),
                ),
                Expanded(
                  child: Text(
                    item.nome,
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTotalRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Total do pedido',
          style: TextStyle(color: Colors.white54, fontSize: 13),
        ),
        Text(
          total,
          style: const TextStyle(
            color: _red,
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _buildPriceWarning() {
    return const Row(
      children: [
        Icon(Icons.info_outline_rounded, color: Colors.white38, size: 13),
        SizedBox(width: 5),
        Expanded(
          child: Text(
            'Os preços podem ter mudado desde o último pedido.',
            style: TextStyle(color: Colors.white38, fontSize: 11),
          ),
        ),
      ],
    );
  }

  Widget _buildConfirmButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton.icon(
        onPressed: () {
          Navigator.pop(context);
          Navigator.pushNamed(
            context,
            AppRoutes.addressSchedule,
            arguments: {'total': 0.0},
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: _red,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        icon: const Icon(Icons.add_shopping_cart_rounded, size: 20),
        label: const Text(
          'Adicionar ao carrinho',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _buildCancelButton(BuildContext context) {
    return TextButton(
      onPressed: () => Navigator.pop(context, false),
      child: const Text(
        'Cancelar',
        style: TextStyle(color: Colors.white38, fontSize: 13),
      ),
    );
  }
}
