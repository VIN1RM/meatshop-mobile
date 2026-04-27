import 'package:flutter/material.dart';
import 'package:meatshop_mobile/core/enums/delivery_enums.dart';
import 'package:meatshop_mobile/providers/delivery/delivery_provider.dart';
import 'package:meatshop_mobile/routes/app_routes.dart';
import 'package:meatshop_mobile/ui/widgets/buttons_widget.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class ActiveDeliveryScreen extends StatelessWidget {
  const ActiveDeliveryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<DeliveryProvider>(
      builder: (context, provider, _) {
        final order = provider.activeOrder;
        if (order == null) return const SizedBox.shrink();

        final isPickup = order.step == DeliveryStep.pickup;

        return SafeArea(
          child: Column(
            children: [
              _ActiveDeliveryHeader(orderId: order.id, isPickup: isPickup),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _StepCard(
                        stepNumber: 1,
                        label: 'RETIRADA',
                        title: order.unitName,
                        subtitle:
                            '${order.unitAddress.street}, ${order.unitAddress.number}',
                        neighborhood: order.unitAddress.neighborhood,
                        icon: Icons.storefront_outlined,
                        isActive: isPickup,
                        isDone: !isPickup,
                        accentColor: const Color(0xFFC0392B),
                        lat: order.unitLat,
                        lng: order.unitLng,
                        address: order.unitAddress.fullAddress,
                      ),

                      const SizedBox(height: 8),

                      _RouteConnector(isPickup: isPickup),

                      const SizedBox(height: 8),

                      _StepCard(
                        stepNumber: 2,
                        label: 'ENTREGA',
                        title: order.clientName,
                        subtitle:
                            '${order.address.street}, ${order.address.number}',
                        neighborhood: order.address.neighborhood,
                        icon: Icons.location_on_outlined,
                        isActive: !isPickup,
                        isDone: false,
                        accentColor: const Color(0xFF27AE60),
                        lat: order.destLat,
                        lng: order.destLng,
                        address: order.address.fullAddress,
                      ),

                      const SizedBox(height: 20),

                      _OrderItemsCard(items: order.items, total: order.total),

                      const SizedBox(height: 24),

                      if (isPickup)
                        PrimaryButton(
                          label: 'Confirmar retirada no açougue',
                          isLoading: provider.isLoading,
                          onPressed: () => _onConfirmPickup(context, provider),
                        )
                      else
                        PrimaryButton(
                          label: 'Confirmar entrega ao cliente',
                          isLoading: provider.isLoading,
                          onPressed: () =>
                              _onConfirmDelivery(context, provider),
                        ),

                      const SizedBox(height: 12),

                      SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: ElevatedButton.icon(
                          onPressed: () =>
                              Navigator.pushNamed(context, AppRoutes.chat),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white.withValues(
                              alpha: 0.06,
                            ),
                            foregroundColor: Colors.white54,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          icon: const Icon(Icons.chat_bubble_outline, size: 20),
                          label: const Text(
                            'Falar com o estabelecimento',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _onConfirmPickup(
    BuildContext context,
    DeliveryProvider provider,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF2C2C2C),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Retirou o pedido?',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'Confirme que você retirou o pedido no açougue e está a caminho do cliente.',
          style: TextStyle(color: Colors.white54),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text(
              'Cancelar',
              style: TextStyle(color: Colors.white38),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFC0392B),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await provider.confirmPickup();
    }
  }

  Future<void> _onConfirmDelivery(
    BuildContext context,
    DeliveryProvider provider,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF2C2C2C),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Confirmar entrega?',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'Confirme apenas após entregar o pedido ao cliente.',
          style: TextStyle(color: Colors.white54),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text(
              'Cancelar',
              style: TextStyle(color: Colors.white38),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFC0392B),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await provider.confirmDelivery();
    }
  }
}

class _ActiveDeliveryHeader extends StatelessWidget {
  const _ActiveDeliveryHeader({required this.orderId, required this.isPickup});

  final int orderId;
  final bool isPickup;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      color: const Color(0xFF2C2C2C),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: const BoxDecoration(
              color: Color(0xFF27AE60),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 10),
          Text(
            isPickup ? 'Indo buscar o pedido' : 'Entrega em andamento',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          Text(
            '#$orderId',
            style: const TextStyle(color: Colors.white38, fontSize: 14),
          ),
        ],
      ),
    );
  }
}

class _StepCard extends StatelessWidget {
  const _StepCard({
    required this.stepNumber,
    required this.label,
    required this.title,
    required this.subtitle,
    required this.neighborhood,
    required this.icon,
    required this.isActive,
    required this.isDone,
    required this.accentColor,
    required this.address,
    this.lat,
    this.lng,
  });

  final int stepNumber;
  final String label;
  final String title;
  final String subtitle;
  final String neighborhood;
  final IconData icon;
  final bool isActive;
  final bool isDone;
  final Color accentColor;
  final double? lat;
  final double? lng;
  final String address;

  @override
  Widget build(BuildContext context) {
    final opacity = isDone ? 0.4 : 1.0;

    return Opacity(
      opacity: opacity,
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF2C2C2C),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isActive
                ? accentColor.withValues(alpha: 0.5)
                : Colors.white.withValues(alpha: 0.06),
            width: isActive ? 1.5 : 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: isActive ? 0.2 : 0.08),
                  shape: BoxShape.circle,
                ),
                child: isDone
                    ? Icon(Icons.check, color: accentColor, size: 20)
                    : Icon(icon, color: accentColor, size: 20),
              ),
              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        color: accentColor,
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.1,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '$subtitle · $neighborhood',
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),

              if (isActive)
                GestureDetector(
                  onTap: () => _openNavigation(lat, lng, address),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: accentColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.navigation_outlined,
                          color: accentColor,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Navegar',
                          style: TextStyle(
                            color: accentColor,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _openNavigation(double? lat, double? lng, String address) async {
    if (lat != null && lng != null) {
      try {
        final wazeUri = Uri.parse('waze://?ll=$lat,$lng&navigate=yes');
        final canWaze = await canLaunchUrl(wazeUri);
        if (canWaze) {
          await launchUrl(wazeUri);
          return;
        }
      } catch (_) {}
    }

    try {
      final Uri mapsUri;
      if (lat != null && lng != null) {
        mapsUri = Uri.parse(
          'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng&travelmode=driving',
        );
      } else {
        final encoded = Uri.encodeComponent(address);
        mapsUri = Uri.parse(
          'https://www.google.com/maps/dir/?api=1&destination=$encoded&travelmode=driving',
        );
      }
      await launchUrl(mapsUri, mode: LaunchMode.externalApplication);
    } catch (e) {
      debugPrint('Erro ao abrir navegação: $e');
    }
  }
}

class _RouteConnector extends StatelessWidget {
  const _RouteConnector({required this.isPickup});
  final bool isPickup;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 36),
      child: Row(
        children: [
          Column(
            children: List.generate(
              4,
              (i) => Container(
                width: 2,
                height: 6,
                margin: const EdgeInsets.symmetric(vertical: 2),
                decoration: BoxDecoration(
                  color: isPickup ? Colors.white12 : const Color(0xFF27AE60),
                  borderRadius: BorderRadius.circular(1),
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Text(
            isPickup ? 'A caminho do açougue' : 'A caminho do cliente',
            style: const TextStyle(color: Colors.white24, fontSize: 11),
          ),
        ],
      ),
    );
  }
}

class _OrderItemsCard extends StatelessWidget {
  const _OrderItemsCard({required this.items, required this.total});
  final String items;
  final double total;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2C2C2C),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'ITENS DO PEDIDO',
            style: TextStyle(
              color: Colors.white38,
              fontSize: 10,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.1,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(
                Icons.fastfood_outlined,
                color: Colors.white38,
                size: 16,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  items,
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Divider(color: Colors.white12, height: 1),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total',
                style: TextStyle(color: Colors.white54, fontSize: 13),
              ),
              Text(
                'R\$ ${total.toStringAsFixed(2)}',
                style: const TextStyle(
                  color: Color(0xFF2ECC71),
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
