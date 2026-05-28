import 'package:flutter/material.dart';
import 'package:meatshop_mobile/models/delivery_order_model.dart';

class DeliveryDetailsSheet extends StatelessWidget {
  const DeliveryDetailsSheet({super.key, required this.order});

  final DeliveryOrder order;

  static void show(BuildContext context, DeliveryOrder order) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => DeliveryDetailsSheet(order: order),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF2C2C2C),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SheetHandle(),
          const SizedBox(height: 20),
          _SheetHeader(order: order),
          const SizedBox(height: 24),
          Divider(color: Colors.white.withOpacity(0.08)),
          const SizedBox(height: 16),
          _SheetUnitSection(order: order),
          const SizedBox(height: 14),
          Divider(color: Colors.white.withOpacity(0.08)),
          const SizedBox(height: 14),
          _SheetDeliverySection(order: order),
          const SizedBox(height: 28),
          _SheetCloseButton(onTap: () => Navigator.pop(context)),
        ],
      ),
    );
  }
}

class _SheetHandle extends StatelessWidget {
  const _SheetHandle();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 36,
        height: 4,
        decoration: BoxDecoration(
          color: Colors.white12,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }
}

class _SheetHeader extends StatelessWidget {
  const _SheetHeader({required this.order});

  final DeliveryOrder order;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: const Color(0xFF2ECC71).withOpacity(0.12),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.check_circle_outline,
            color: Color(0xFF2ECC71),
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Pedido #${order.id}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Text(
              'Entregue',
              style: TextStyle(color: Color(0xFF2ECC71), fontSize: 13),
            ),
          ],
        ),
        const Spacer(),
        Text(
          'R\$ ${order.total.toStringAsFixed(2)}',
          style: const TextStyle(
            color: Color(0xFF2ECC71),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

class _SheetUnitSection extends StatelessWidget {
  const _SheetUnitSection({required this.order});

  final DeliveryOrder order;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionLabel(text: 'AÇOUGUE'),
        const SizedBox(height: 10),
        _DetailRow(
          icon: Icons.storefront_outlined,
          label: 'Unidade',
          value: order.unitName,
        ),
        const SizedBox(height: 14),
        _DetailRow(
          icon: Icons.location_on_outlined,
          label: 'Endereço do açougue',
          value: order.unitAddress.fullAddress,
        ),
      ],
    );
  }
}

class _SheetDeliverySection extends StatelessWidget {
  const _SheetDeliverySection({required this.order});

  final DeliveryOrder order;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionLabel(text: 'ENTREGA'),
        const SizedBox(height: 10),
        _DetailRow(
          icon: Icons.person_outline,
          label: 'Cliente',
          value: order.clientName,
        ),
        const SizedBox(height: 14),
        _DetailRow(
          icon: Icons.location_on_outlined,
          label: 'Endereço de entrega',
          value: order.address.fullAddress,
        ),
        const SizedBox(height: 14),
        _DetailRow(
          icon: Icons.fastfood_outlined,
          label: 'Itens',
          value: order.items,
        ),
      ],
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: Colors.white38,
        fontSize: 10,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.2,
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Colors.white38, size: 18),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(color: Colors.white38, fontSize: 11),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(color: Colors.white, fontSize: 14),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SheetCloseButton extends StatelessWidget {
  const _SheetCloseButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.white54,
          side: BorderSide(color: Colors.white.withOpacity(0.15)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 14),
        ),
        child: const Text('Fechar'),
      ),
    );
  }
}