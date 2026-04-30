import 'package:flutter/material.dart';
import 'package:meatshop_mobile/providers/delivery/delivery_provider.dart';
import 'package:meatshop_mobile/ui/screens/delivery/active_delivery_screen.dart';
import 'package:meatshop_mobile/ui/dialogs/reject_order_dialog.dart';
import 'package:meatshop_mobile/ui/widgets/card/order_card_widget.dart';
import 'package:provider/provider.dart';

class DeliveriesTab extends StatelessWidget {
  const DeliveriesTab({super.key});

  static const Color _red = Color(0xFFC0392B);

  @override
  Widget build(BuildContext context) {
    return Consumer<DeliveryProvider>(
      builder: (context, provider, _) {
        if (provider.activeOrder != null) {
          return const ActiveDeliveryScreen();
        }

        return Stack(
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(context, provider),
                  Expanded(
                    child: provider.pendingOrders.isEmpty
                        ? _buildEmpty()
                        : _buildOrderList(context, provider),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, DeliveryProvider provider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: const BoxDecoration(
              color: Colors.white,
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
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
          const Spacer(),
          Switch(
            value: provider.isOnline,
            onChanged: (_) => provider.toggleOnline(),
            activeThumbColor: const Color(0xFF27AE60),
            activeTrackColor: const Color(0xFF27AE60).withValues(alpha: 0.4),
            inactiveThumbColor: Colors.white38,
            inactiveTrackColor: Colors.white12,
          ),
          const SizedBox(width: 4),
          Text(
            provider.isOnline ? 'Online' : 'Offline',
            style: TextStyle(
              color: provider.isOnline
                  ? const Color(0xFF27AE60)
                  : Colors.white38,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Icon(Icons.delivery_dining_outlined, color: Colors.white12, size: 64),
          SizedBox(height: 16),
          Text(
            'Nenhum pedido disponível',
            style: TextStyle(color: Colors.white38, fontSize: 16),
          ),
          SizedBox(height: 6),
          Text(
            'Fique online para receber pedidos.',
            style: TextStyle(color: Colors.white24, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderList(BuildContext context, DeliveryProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 20, 16, 12),
          child: Text(
            'PEDIDOS DISPONÍVEIS',
            style: TextStyle(
              color: _red,
              fontSize: 13,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.1,
            ),
          ),
        ),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            physics: const BouncingScrollPhysics(),
            itemCount: provider.pendingOrders.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (_, i) {
              final order = provider.pendingOrders[i];
              return OrderCardWidget(
                order: order,
                isLoading: provider.isLoading,
                onAccept: () => provider.acceptOrder(order),
                onReject: () async {
                  final reasons = await RejectOrderDialog.show(context);
                  if (reasons != null && reasons.isNotEmpty) {
                    provider.rejectOrder(order.id, reasons);
                  }
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
