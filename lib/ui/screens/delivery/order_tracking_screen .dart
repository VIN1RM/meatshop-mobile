import 'package:flutter/material.dart';
import 'package:meatshop_mobile/core/enums/order_status_enum.dart';
import 'package:meatshop_mobile/models/active_order_model.dart';
import 'package:meatshop_mobile/routes/app_routes.dart';
import 'package:meatshop_mobile/services/order_service.dart';
import 'package:meatshop_mobile/ui/dialogs/select_unit_chat_dialog.dart';
import 'package:meatshop_mobile/ui/widgets/app_header.dart';
import 'package:meatshop_mobile/ui/dialogs/cancel_order_dialog.dart';

class DeliveriesScreen extends StatefulWidget {
  const DeliveriesScreen({super.key});

  @override
  State<DeliveriesScreen> createState() => _DeliveriesScreenState();
}

class _DeliveriesScreenState extends State<DeliveriesScreen> {
  static const Color _red = Color(0xFFBE2C1B);
  static const Color _pageBg = Color(0xFF2E2E2E);
  static const Color _cardBg = Color(0xFFE6E6E6);
  static const Color _white = Colors.white;

  final OrderService _service = OrderService();
  List<ActiveOrderModel> _latestOrders = [];

  void _showCancelDialog(ActiveOrderModel order) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: CancelOrderDialog(
          onConfirm: (reason) async {
            try {
              await _service.cancelOrder(
                orderId: order.id,
                reason: reason.label,
              );
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Pedido cancelado: ${reason.label}'),
                    backgroundColor: _red,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                );
              }
            } catch (e) {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Erro ao cancelar pedido.'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            }
          },
        ),
      ),
    );
  }

  Color _statusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return const Color(0xFFFFB800);
      case OrderStatus.confirmed:
        return const Color(0xFF4CAF50);
      case OrderStatus.preparing:
        return const Color(0xFF2196F3);
      case OrderStatus.ready:
        return const Color(0xFF9C27B0);
      case OrderStatus.outForDelivery:
        return _red;
      case OrderStatus.delivered:
        return const Color(0xFF4CAF50);
      case OrderStatus.cancelled:
        return const Color(0xFF888888);
    }
  }

  void _onContactTap() {
    final orders = _latestOrders;

    if (orders.isEmpty) return;

    final seen = <String>{};
    final units = <({String unitId, String unitName})>[];
    for (final o in orders) {
      if (seen.add(o.unitId)) {
        units.add((unitId: o.unitId, unitName: o.unitName));
      }
    }

    if (units.length == 1) {
      Navigator.pushNamed(
        context,
        AppRoutes.chat,
        arguments: {'unitId': units.first.unitId},
      );
    } else {
      SelectUnitChatDialog.show(
        context,
        units: units,
        onSelect: (unitId) => Navigator.pushNamed(
          context,
          AppRoutes.chat,
          arguments: {'unitId': unitId},
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _pageBg,
      body: Column(
        children: [
          SizedBox(
            child: Stack(
              children: [
                Positioned.fill(
                  child: Image.asset(
                    'assets/images/background.png',
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) =>
                        Container(color: const Color(0xFF1A1A1A)),
                  ),
                ),
                const SafeArea(bottom: false, child: AppHeader()),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<List<ActiveOrderModel>>(
              stream: _service.activeOrdersTrackingStream(),
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFFBE2C1B),
                      strokeWidth: 2.5,
                    ),
                  );
                }
                if (snap.hasError) {
                  return Center(
                    child: Text(
                      'Erro ao carregar pedidos.',
                      style: const TextStyle(color: Colors.white),
                    ),
                  );
                }
                final orders = snap.data ?? [];
                _latestOrders = orders;
                if (orders.isEmpty) {
                  return const Center(
                    child: Text(
                      'Nenhum pedido em andamento.',
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                  );
                }
                return ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    const SizedBox(height: 20),
                    const Text(
                      'ACOMPANHAR',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 14),
                    ...orders.map((o) => _buildCard(o)),
                    const SizedBox(height: 80),
                  ],
                );
              },
            ),
          ),
          _buildContactButton(),
        ],
      ),
    );
  }

  Widget _buildCard(ActiveOrderModel order) {
    final isCancelled = order.isCancelled;

    return Opacity(
      opacity: isCancelled ? 0.6 : 1.0,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _cardBg,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFF1A1A1A),
                  ),
                  child: ClipOval(
                    child: order.unitLogoUrl.isNotEmpty
                        ? Image.network(
                            order.unitLogoUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => const Icon(
                              Icons.store,
                              color: _white,
                              size: 22,
                            ),
                          )
                        : const Icon(Icons.store, color: _white, size: 22),
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order.unitName,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        color: Color(0xFF1A1A1A),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: _statusColor(order.status),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        order.status.label,
                        style: const TextStyle(
                          color: _white,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Icon(
                  isCancelled
                      ? Icons.cancel_outlined
                      : Icons.two_wheeler_outlined,
                  color: isCancelled ? const Color(0xFF888888) : _red,
                  size: 28,
                ),
              ],
            ),

            const SizedBox(height: 14),

            if (isCancelled)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: Colors.black12,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  order.cancellationReason != null
                      ? 'Cancelado: ${order.cancellationReason}'
                      : 'Este pedido foi cancelado.',
                  style: const TextStyle(
                    color: Color(0xFF888888),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),

            if (order.canCancel) ...[
              const SizedBox(height: 12),
              const Divider(color: Color(0xFFCCCCCC), height: 1),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () => _showCancelDialog(order),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.cancel_outlined,
                      size: 15,
                      color: Color(0xFFBE2C1B),
                    ),
                    SizedBox(width: 6),
                    Text(
                      'Cancelar pedido',
                      style: TextStyle(
                        color: Color(0xFFBE2C1B),
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildContactButton() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      color: _pageBg,
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 62,
          child: ElevatedButton.icon(
            onPressed: _onContactTap,
            style: ElevatedButton.styleFrom(
              backgroundColor: _red,
              foregroundColor: _white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            icon: const Icon(
              Icons.chat_bubble_outline_rounded,
              size: 22,
              color: _white,
            ),
            label: const Text(
              'Contatar estabelecimento',
              style: TextStyle(
                color: _white,
                fontSize: 17,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.2,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
