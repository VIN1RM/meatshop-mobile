import 'package:flutter/material.dart';
import 'package:meatshop_mobile/providers/delivery/delivery_provider.dart';
import 'package:meatshop_mobile/ui/screens/delivery/active_delivery_screen.dart';
import 'package:meatshop_mobile/ui/widgets/order_card_widget.dart';
import 'package:provider/provider.dart';

class DeliveriesTab extends StatelessWidget {
  const DeliveriesTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<DeliveryProvider>(
      builder: (context, provider, _) {
        // Se há entrega ativa, mostra a tela de entrega em andamento
        if (provider.hasActiveOrder) {
          return const ActiveDeliveryScreen();
        }

        return SafeArea(
          child: Column(
            children: [
              _DeliveriesHeader(provider: provider),
              Expanded(
                child: provider.isAvailable
                    ? _PendingOrdersList(provider: provider)
                    : const _UnavailableState(),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _DeliveriesHeader extends StatelessWidget {
  const _DeliveriesHeader({required this.provider});

  final DeliveryProvider provider;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF2C2C2C),
        border: Border(
          bottom: BorderSide(
            color: Colors.white.withOpacity(0.08),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Entregas',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                provider.isAvailable ? 'Você está disponível' : 'Você está indisponível',
                style: TextStyle(
                  color: provider.isAvailable
                      ? const Color(0xFF2ECC71)
                      : Colors.white38,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const Spacer(),
          _AvailabilityToggle(provider: provider),
        ],
      ),
    );
  }
}

class _AvailabilityToggle extends StatelessWidget {
  const _AvailabilityToggle({required this.provider});

  final DeliveryProvider provider;

  @override
  Widget build(BuildContext context) {
    final isOn = provider.isAvailable;
    return GestureDetector(
      onTap: provider.toggleAvailability,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: 56,
        height: 30,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: isOn ? const Color(0xFF2ECC71) : Colors.white24,
        ),
        child: AnimatedAlign(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          alignment: isOn ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            margin: const EdgeInsets.all(3),
            width: 24,
            height: 24,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}

class _PendingOrdersList extends StatelessWidget {
  const _PendingOrdersList({required this.provider});

  final DeliveryProvider provider;

  @override
  Widget build(BuildContext context) {
    if (provider.pendingOrders.isEmpty) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.inbox_outlined, color: Colors.white24, size: 48),
            SizedBox(height: 12),
            Text(
              'Nenhum pedido disponível',
              style: TextStyle(color: Colors.white38, fontSize: 15),
            ),
            SizedBox(height: 4),
            Text(
              'Aguarde novos pedidos aparecerem aqui',
              style: TextStyle(color: Colors.white24, fontSize: 13),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: provider.pendingOrders.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final order = provider.pendingOrders[index];
        return OrderCardWidget(
          order: order,
          isLoading: provider.isLoading,
          onAccept: () => provider.acceptOrder(order),
          onReject: () => provider.rejectOrder(order.id),
        );
      },
    );
  }
}

class _UnavailableState extends StatelessWidget {
  const _UnavailableState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.pause_circle_outline, color: Colors.white24, size: 56),
          SizedBox(height: 16),
          Text(
            'Você está indisponível',
            style: TextStyle(
              color: Colors.white54,
              fontSize: 17,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 6),
          Text(
            'Ative o toggle acima para começar a receber pedidos',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white38, fontSize: 13),
          ),
        ],
      ),
    );
  }
}