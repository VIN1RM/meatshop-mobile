import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:meatshop_mobile/core/enums/order_status_enum.dart';
import 'package:meatshop_mobile/models/order_model.dart';
import 'package:meatshop_mobile/routes/app_routes.dart';
import 'package:meatshop_mobile/services/order_service.dart';
import 'package:meatshop_mobile/ui/screens/cart/write_product_review_screen.dart';
import 'package:meatshop_mobile/ui/widgets/app_header.dart';
import 'package:meatshop_mobile/ui/dialogs/reorder_confirm_dialog.dart';
import 'package:meatshop_mobile/ui/screens/orders/review_screen.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  static const Color _red = Color(0xFFC0392B);
  final OrderService _service = OrderService();

  Future<void> _onReorder(BuildContext context, OrderModel order) async {
    await ReorderConfirmDialog.show(
      context,
      acougueNome: order.unitName,
      itens: order.items
          .map(
            (i) =>
                ReorderItem(nome: i.productName, quantidade: i.quantityLabel),
          )
          .toList(),
      total: order.formattedTotal,
    );
  }

  @override
  Widget build(BuildContext context) {
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
              errorBuilder: (_, _, _) =>
                  Container(color: const Color(0xFF1A1A1A)),
            ),
          ),
        ),
        SafeArea(
          child: Column(
            children: [
              const AppHeader(),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),
                      _pageTitle(),
                      const SizedBox(height: 20),
                      _groupTitle('Em andamento'),
                      const SizedBox(height: 10),
                      _ActiveOrdersSection(
                        service: _service,
                        onReorder: _onReorder,
                        red: _red,
                      ),
                      const SizedBox(height: 28),
                      _groupTitle('Finalizados'),
                      const SizedBox(height: 4),
                      _groupSubtitle(
                        'Últimos 3 meses · Concluídos e Cancelados',
                      ),
                      const SizedBox(height: 10),
                      _FinishedOrdersSection(
                        service: _service,
                        onReorder: _onReorder,
                        red: _red,
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _pageTitle() => const Padding(
    padding: EdgeInsets.symmetric(horizontal: 16),
    child: Text(
      'PEDIDOS',
      style: TextStyle(
        color: Colors.white,
        fontSize: 22,
        fontWeight: FontWeight.w900,
        letterSpacing: 1.2,
      ),
    ),
  );

  Widget _groupTitle(String label) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    child: Text(
      label,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 16,
        fontWeight: FontWeight.w700,
      ),
    ),
  );

  Widget _groupSubtitle(String label) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    child: Text(
      label,
      style: const TextStyle(
        color: Color(0xAAFFFFFF),
        fontSize: 12,
        fontWeight: FontWeight.w400,
      ),
    ),
  );
}

class _ActiveOrdersSection extends StatelessWidget {
  const _ActiveOrdersSection({
    required this.service,
    required this.onReorder,
    required this.red,
  });

  final OrderService service;
  final Future<void> Function(BuildContext, OrderModel) onReorder;
  final Color red;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<OrderModel>>(
      stream: service.activeOrdersStream(),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting)
          return const _Loading();
        if (snap.hasError) return const _ErrorTile();
        final orders = snap.data ?? [];
        if (orders.isEmpty)
          return const _EmptyTile(message: 'Nenhum pedido em andamento.');
        return Column(
          children: orders
              .map(
                (o) =>
                    _ActiveOrderCard(order: o, red: red, onReorder: onReorder),
              )
              .toList(),
        );
      },
    );
  }
}

class _FinishedOrdersSection extends StatelessWidget {
  const _FinishedOrdersSection({
    required this.service,
    required this.onReorder,
    required this.red,
  });

  final OrderService service;
  final Future<void> Function(BuildContext, OrderModel) onReorder;
  final Color red;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<OrderModel>>(
      stream: service.finishedOrdersStream(),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting)
          return const _Loading();
        if (snap.hasError) return const _ErrorTile();
        final orders = snap.data ?? [];
        if (orders.isEmpty) {
          return const _EmptyTile(
            message: 'Nenhum pedido finalizado nos últimos 3 meses.',
          );
        }
        return Column(
          children: orders
              .map(
                (o) => _FinishedOrderCard(
                  order: o,
                  red: red,
                  onReorder: onReorder,
                ),
              )
              .toList(),
        );
      },
    );
  }
}

class _ActiveOrderCard extends StatelessWidget {
  const _ActiveOrderCard({
    required this.order,
    required this.red,
    required this.onReorder,
  });

  final OrderModel order;
  final Color red;
  final Future<void> Function(BuildContext, OrderModel) onReorder;

  @override
  Widget build(BuildContext context) {
    final statusInfo = _activeStatusInfo(order.status, order.deliveryStatus);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(16),
        border: Border(left: BorderSide(color: statusInfo.color, width: 4)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _UnitAvatar(logoUrl: order.unitLogoUrl, size: 40),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order.unitName,
                        style: const TextStyle(
                          color: Color(0xFF1A1A1A),
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                      const SizedBox(height: 2),
                      _ActiveStatusBadge(statusInfo: statusInfo),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      order.formattedTotal,
                      style: const TextStyle(
                        color: Color(0xFF1A1A1A),
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (order.orderDate != null)
                      Text(
                        DateFormat('HH:mm').format(order.orderDate!),
                        style: const TextStyle(
                          color: Color(0xFF888888),
                          fontSize: 11,
                        ),
                      ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 12),
            const Divider(height: 1, color: Color(0xFFE0E0E0)),
            const SizedBox(height: 10),

            ...order.items
                .take(2)
                .map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(bottom: 3),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 52,
                          child: Text(
                            item.quantityLabel,
                            style: const TextStyle(
                              color: Color(0xFF555555),
                              fontSize: 12,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Text(
                            item.productName,
                            style: const TextStyle(
                              color: Color(0xFF1A1A1A),
                              fontSize: 13,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

            if (order.items.length > 2)
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text(
                  '+${order.items.length - 2} item(s)',
                  style: const TextStyle(
                    color: Color(0xFFAAAAAA),
                    fontSize: 11,
                  ),
                ),
              ),

            const SizedBox(height: 12),

            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: [
                _InfoChip(
                  icon: Icons.local_shipping_outlined,
                  label: order.deliveryType == 'DELIVERY'
                      ? 'Entrega'
                      : 'Retirada',
                ),
                if (order.isScheduled)
                  _InfoChip(
                    icon: Icons.schedule_rounded,
                    label: 'Agendado',
                    color: const Color(0xFF1565C0),
                    bgColor: const Color(0xFFE3F2FD),
                  ),
              ],
            ),

            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              height: 40,
              child: ElevatedButton.icon(
                onPressed: () =>
                    Navigator.pushNamed(context, AppRoutes.deliveries),
                icon: Icon(Icons.location_on_rounded, size: 16, color: red),
                label: Text(
                  'Acompanhar entrega',
                  style: TextStyle(
                    color: red,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: red.withValues(alpha: 0.08),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  _StatusInfo _activeStatusInfo(String status, String deliveryStatus) {
    if (deliveryStatus == 'ON_THE_WAY') {
      return _StatusInfo(
        label: 'A caminho',
        color: const Color(0xFF1565C0),
        icon: Icons.delivery_dining_rounded,
      );
    }
    final s = OrderStatusX.fromString(status);
    return _StatusInfo(label: s.label, color: s.color, icon: s.icon);
  }
}

class _ActiveStatusBadge extends StatelessWidget {
  const _ActiveStatusBadge({required this.statusInfo});
  final _StatusInfo statusInfo;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: statusInfo.color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(statusInfo.icon, size: 11, color: statusInfo.color),
          const SizedBox(width: 4),
          Text(
            statusInfo.label,
            style: TextStyle(
              fontSize: 11,
              color: statusInfo.color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _FinishedOrderCard extends StatefulWidget {
  const _FinishedOrderCard({
    required this.order,
    required this.red,
    required this.onReorder,
  });

  final OrderModel order;
  final Color red;
  final Future<void> Function(BuildContext, OrderModel) onReorder;

  @override
  State<_FinishedOrderCard> createState() => _FinishedOrderCardState();
}

class _FinishedOrderCardState extends State<_FinishedOrderCard>
    with SingleTickerProviderStateMixin {
  bool _expanded = false;
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
    );
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() => _expanded = !_expanded);
    _expanded ? _ctrl.forward() : _ctrl.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final order = widget.order;
    final red = widget.red;
    final isCancelled = order.isCancelled;
    final statusColor = isCancelled ? red : const Color(0xFF27AE60);
    final formattedDate = order.orderDate != null
        ? DateFormat("d 'de' MMM 'de' yyyy", 'pt_BR').format(order.orderDate!)
        : null;

    return GestureDetector(
      onTap: _toggle,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(16),
          border: Border(left: BorderSide(color: statusColor, width: 4)),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _UnitAvatar(logoUrl: order.unitLogoUrl, size: 40),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          order.unitName,
                          style: const TextStyle(
                            color: Color(0xFF1A1A1A),
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Wrap(
                          crossAxisAlignment: WrapCrossAlignment.center,
                          spacing: 3,
                          children: [
                            Icon(
                              isCancelled
                                  ? Icons.cancel_outlined
                                  : Icons.check_circle_outline,
                              size: 11,
                              color: statusColor,
                            ),
                            Text(
                              isCancelled ? 'Cancelado' : 'Concluído',
                              style: TextStyle(
                                fontSize: 11,
                                color: statusColor,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            if (formattedDate != null)
                              Text(
                                '· $formattedDate',
                                style: const TextStyle(
                                  color: Color(0xFF888888),
                                  fontSize: 11,
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        order.formattedTotal,
                        style: const TextStyle(
                          color: Color(0xFF1A1A1A),
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      AnimatedRotation(
                        turns: _expanded ? 0.5 : 0,
                        duration: const Duration(milliseconds: 220),
                        child: const Icon(
                          Icons.keyboard_arrow_down_rounded,
                          color: Color(0xFFAAAAAA),
                          size: 18,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 10),
              ...order.items
                  .take(_expanded ? 999 : 2)
                  .map(
                    (item) => Padding(
                      padding: const EdgeInsets.only(bottom: 3),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 52,
                            child: Text(
                              item.quantityLabel,
                              style: const TextStyle(
                                color: Color(0xFF555555),
                                fontSize: 12,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              item.productName,
                              style: const TextStyle(
                                color: Color(0xFF1A1A1A),
                                fontSize: 13,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

              if (!_expanded && order.items.length > 2)
                Text(
                  '+${order.items.length - 2} item(s)',
                  style: const TextStyle(
                    color: Color(0xFFAAAAAA),
                    fontSize: 11,
                  ),
                ),

              SizeTransition(
                sizeFactor: _anim,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 12),
                    const Divider(height: 1, color: Color(0xFFE0E0E0)),
                    const SizedBox(height: 12),

                    Row(
                      children: [
                        Expanded(
                          child: _DetailItem(
                            icon: Icons.payments_outlined,
                            label: 'Pagamento',
                            value: _paymentLabel(order.paymentMethod),
                          ),
                        ),
                        Expanded(
                          child: _DetailItem(
                            icon: Icons.local_shipping_outlined,
                            label: 'Entrega',
                            value: order.deliveryType == 'DELIVERY'
                                ? 'Entrega em casa'
                                : 'Retirada no local',
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    Row(
                      children: [
                        Expanded(
                          child: _DetailItem(
                            icon: Icons.receipt_outlined,
                            label: 'Subtotal',
                            value:
                                'R\$ ${order.subtotal.toStringAsFixed(2).replaceAll('.', ',')}',
                          ),
                        ),
                        if (order.deliveryFee > 0)
                          Expanded(
                            child: _DetailItem(
                              icon: Icons.two_wheeler_rounded,
                              label: 'Taxa de entrega',
                              value:
                                  'R\$ ${order.deliveryFee.toStringAsFixed(2).replaceAll('.', ',')}',
                            ),
                          ),
                      ],
                    ),

                    if (order.discountAmount > 0) ...[
                      const SizedBox(height: 10),
                      _DetailItem(
                        icon: Icons.local_offer_outlined,
                        label: 'Desconto',
                        value:
                            '- R\$ ${order.discountAmount.toStringAsFixed(2).replaceAll('.', ',')}',
                        valueColor: const Color(0xFF27AE60),
                      ),
                    ],

                    if (isCancelled && order.cancellationReason != null) ...[
                      const SizedBox(height: 10),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: red.withValues(alpha: 0.07),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_outline_rounded,
                              color: red,
                              size: 14,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                'Motivo: ${order.cancellationReason}',
                                style: TextStyle(color: red, fontSize: 12),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: 12),
                    const Divider(height: 1, color: Color(0xFFE0E0E0)),
                    const SizedBox(height: 12),
                  ],
                ),
              ),

              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  if (!isCancelled && !order.reviewed)
                    GestureDetector(
                      onTap: () => Navigator.pushNamed(
                        context,
                        AppRoutes.review,
                        arguments: ReviewArgs(
                          order: order,
                          deliveryPersonId: order.deliveryPersonId ?? '',
                          unitImageUrl: order.unitLogoUrl,
                          deliveryPersonPhotoUrl: '',
                        ),
                      ),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 8,
                          horizontal: 12,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF8E1),
                          border: Border.all(color: const Color(0xFFFFB800)),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.star_rounded,
                              color: Color(0xFFFFB800),
                              size: 13,
                            ),
                            SizedBox(width: 4),
                            Text(
                              'Açougue',
                              style: TextStyle(
                                color: Color(0xFFE6A000),
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  if (!isCancelled && !order.productsReviewed)
                    GestureDetector(
                      onTap: () => Navigator.pushNamed(
                        context,
                        AppRoutes.writeProductReview,
                        arguments: WriteProductReviewScreenArgs(
                          order: order,
                          items: order.items,
                        ),
                      ),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 8,
                          horizontal: 12,
                        ),
                        decoration: BoxDecoration(
                          color: red.withValues(alpha: 0.15),
                          border: Border.all(color: red),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.local_offer_outlined,
                              color: red,
                              size: 13,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Produtos',
                              style: TextStyle(
                                color: red,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  GestureDetector(
                    onTap: () => widget.onReorder(context, order),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 12,
                      ),
                      decoration: BoxDecoration(
                        color: red,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.replay_rounded,
                            color: Colors.white,
                            size: 13,
                          ),
                          const SizedBox(width: 4),
                          const Text(
                            'Pedir novamente',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
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

  String _paymentLabel(String method) {
    switch (method.toUpperCase()) {
      case 'PIX':
        return 'Pix';
      case 'CREDIT_CARD':
        return 'Cartão de crédito';
      case 'DEBIT_CARD':
        return 'Cartão de débito';
      case 'CASH':
        return 'Dinheiro';
      default:
        return method.isEmpty ? '—' : method;
    }
  }
}

class _UnitAvatar extends StatelessWidget {
  const _UnitAvatar({required this.logoUrl, this.size = 36});
  final String logoUrl;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(shape: BoxShape.circle),
      child: ClipOval(
        child: logoUrl.isNotEmpty
            ? Image.network(
                logoUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => _placeholder(),
              )
            : _placeholder(),
      ),
    );
  }

  Widget _placeholder() => Container(
    color: const Color(0xFFE0E0E0),
    child: const Icon(
      Icons.storefront_outlined,
      color: Color(0xFFBDBDBD),
      size: 18,
    ),
  );
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({
    required this.icon,
    required this.label,
    this.color = const Color(0xFF555555),
    this.bgColor = const Color(0xFFEAEAEA),
  });

  final IconData icon;
  final String label;
  final Color color;
  final Color bgColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailItem extends StatelessWidget {
  const _DetailItem({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor = const Color(0xFF1A1A1A),
  });

  final IconData icon;
  final String label;
  final String value;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 14, color: const Color(0xFF888888)),
        const SizedBox(width: 6),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(color: Color(0xFF888888), fontSize: 11),
              ),
              Text(
                value,
                style: TextStyle(
                  color: valueColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StatusInfo {
  final String label;
  final Color color;
  final IconData icon;

  const _StatusInfo({
    required this.label,
    required this.color,
    required this.icon,
  });
}

class _Loading extends StatelessWidget {
  const _Loading();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Center(
        child: CircularProgressIndicator(
          color: Color(0xFFC0392B),
          strokeWidth: 2.5,
        ),
      ),
    );
  }
}

class _EmptyTile extends StatelessWidget {
  const _EmptyTile({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(
        child: Text(
          message,
          style: const TextStyle(color: Color(0xFFAAAAAA), fontSize: 13),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

class _ErrorTile extends StatelessWidget {
  const _ErrorTile();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF0F0),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Center(
        child: Text(
          'Erro ao carregar pedidos.',
          style: TextStyle(color: Color(0xFFC0392B), fontSize: 13),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
