import 'package:flutter/material.dart';
import 'package:meatshop_mobile/core/utils/custom_snackbar.dart';
import 'package:meatshop_mobile/providers/delivery/delivery_provider.dart';
import 'package:meatshop_mobile/ui/screens/delivery/active_delivery_screen.dart';
import 'package:meatshop_mobile/ui/dialogs/reject_order_dialog.dart';
import 'package:meatshop_mobile/ui/widgets/app_header.dart';
import 'package:meatshop_mobile/ui/widgets/card/order_card_widget.dart';
import 'package:provider/provider.dart';

class DeliveriesTab extends StatelessWidget {
  const DeliveriesTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<DeliveryProvider>(
      builder: (context, provider, _) {
        if (provider.activeOrder != null) {
          return const ActiveDeliveryScreen();
        }

        return Material(
          color: const Color(0xFF2E2E2E),
          child: Stack(
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
                    errorBuilder: (_, _, _) =>
                        Container(color: const Color(0xFF1A1A1A)),
                  ),
                ),
              ),
              SafeArea(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const AppHeader(),
                    Expanded(
                      child: provider.pendingOrders.isEmpty
                          ? _buildEmpty(provider)
                          : _buildOrderList(context, provider),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmpty(DeliveryProvider provider) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.delivery_dining_outlined,
            color: Color.fromARGB(174, 255, 255, 255),
            size: 64,
          ),
          const SizedBox(height: 16),
          const Text(
            'Nenhum pedido disponível',
            style: TextStyle(
              color: Color.fromARGB(255, 255, 255, 255),
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Aguarde e Confie',
            style: TextStyle(
              color: Color.fromARGB(181, 255, 255, 255),
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 24),
          ReloadButton(provider: provider),
        ],
      ),
    );
  }

  Widget _buildOrderList(BuildContext context, DeliveryProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'PEDIDOS DISPONÍVEIS',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.1,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            physics: const BouncingScrollPhysics(),
            itemCount: provider.pendingOrders.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (_, i) {
              final order = provider.pendingOrders[i];
              return OrderCardWidget(
                order: order,
                isLoading: provider.isLoading,
                onAccept: () async {
                  await provider.acceptOrder(order);
                  if (!context.mounted || !provider.hasActiveOrder) {
                    return;
                  }
                  final consent = await showDialog<bool>(
                    context: context,
                    barrierDismissible: false,
                    builder: (dialogContext) => AlertDialog(
                      title: const Text('Compartilhar localização?'),
                      content: const Text(
                        'Durante esta entrega, sua localização precisa poderá ser acompanhada pelo cliente e pela unidade. O envio termina ao concluir ou sair da entrega.',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(dialogContext, false),
                          child: const Text('Agora não'),
                        ),
                        FilledButton(
                          onPressed: () => Navigator.pop(dialogContext, true),
                          child: const Text('Permitir durante a entrega'),
                        ),
                      ],
                    ),
                  );
                  await provider.startLocationSharing(
                    consent: consent ?? false,
                  );
                },
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

class ReloadButton extends StatelessWidget {
  final DeliveryProvider provider;
  final bool compact;

  const ReloadButton({super.key, required this.provider, this.compact = false});

  Future<void> _reload(BuildContext context) async {
    final success = await provider.reloadOrders();
    if (!context.mounted) return;

    success
        ? CustomSnackBar.success(
            'Lista atualizada!',
            context: context,
            duration: const Duration(seconds: 2),
          )
        : CustomSnackBar.error(
            'Erro ao atualizar.',
            context: context,
            duration: const Duration(seconds: 2),
          );
  }

  @override
  Widget build(BuildContext context) {
    if (provider.isReloading) {
      return compact
          ? const SizedBox(
              width: 34,
              height: 34,
              child: Padding(
                padding: EdgeInsets.all(8),
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white54,
                ),
              ),
            )
          : const SizedBox(
              height: 40,
              child: Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white38,
                  ),
                ),
              ),
            );
    }

    if (compact) {
      return SizedBox(
        width: 44,
        height: 44,
        child: ElevatedButton(
          onPressed: () => _reload(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFC0392B),
            foregroundColor: Colors.white,
            elevation: 0,
            padding: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Icon(Icons.refresh_rounded, size: 20),
        ),
      );
    }

    return GestureDetector(
      onTap: () => _reload(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFC0392B),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFF8B1A1A), width: 1.5),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.refresh_rounded, color: Colors.white, size: 18),
            SizedBox(width: 8),
            Text(
              'Atualizar',
              style: TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
