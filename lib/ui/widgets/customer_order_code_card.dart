import 'package:flutter/material.dart';
import '../../models/order_model.dart';

/// Shows only the customer handoff code returned by the authorized order API.
class CustomerOrderCodeCard extends StatelessWidget {
  const CustomerOrderCodeCard({
    super.key,
    required this.order,
    this.dark = false,
    this.onOpen,
  });
  final OrderModel order;
  final bool dark;
  final VoidCallback? onOpen;
  @override
  Widget build(BuildContext context) {
    if (!order.canShowCustomerCode) return const SizedBox.shrink();
    final code = order.deliveryCode?.trim();
    final available = code != null && RegExp(r'^\d{6}$').hasMatch(code);
    final accent = dark ? const Color(0xFFFFA99F) : const Color(0xFFB53225);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: dark ? const Color(0xFF3D302E) : const Color(0xFFFFEFEC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: dark ? const Color(0xFF73504A) : const Color(0xFFF1D6D0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.verified_user_outlined, size: 18, color: accent),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  order.isPickup ? 'Código de retirada' : 'Código de entrega',
                  style: TextStyle(
                    color: accent,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ),
              Text(
                '#${order.id}',
                style: TextStyle(color: accent, fontSize: 12),
              ),
            ],
          ),
          if (available) ...[
            const SizedBox(height: 10),
            Center(
              child: SelectableText(
                code,
                style: TextStyle(
                  color: dark ? Colors.white : const Color(0xFF282828),
                  fontWeight: FontWeight.w800,
                  fontSize: 28,
                  letterSpacing: 5,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              order.isPickup
                  ? 'Apresente no balcão somente ao receber seu pedido.'
                  : 'Informe ao entregador somente depois de receber seu pedido.',
              style: TextStyle(
                color: dark ? Colors.white70 : const Color(0xFF6E514A),
                fontSize: 12,
                height: 1.4,
              ),
            ),
          ] else ...[
            const SizedBox(height: 8),
            Text(
              'Abra o acompanhamento para consultar ou gerar um novo código.',
              style: TextStyle(
                color: dark ? Colors.white70 : const Color(0xFF6E514A),
                fontSize: 12,
                height: 1.4,
              ),
            ),
            if (onOpen != null)
              TextButton.icon(
                onPressed: onOpen,
                icon: const Icon(Icons.key_outlined, size: 18),
                label: const Text('Ver código'),
                style: TextButton.styleFrom(foregroundColor: accent),
              ),
          ],
        ],
      ),
    );
  }
}
