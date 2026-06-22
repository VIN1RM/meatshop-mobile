import 'package:flutter/material.dart';
import 'package:meatshop_mobile/models/order_model.dart';
import 'package:meatshop_mobile/routes/app_routes.dart';
import 'package:meatshop_mobile/services/order_service.dart';
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
                      const SizedBox(height: 16),

                      _groupTitle('Em andamento'),
                      const SizedBox(height: 10),
                      _ActiveOrdersSection(
                        service: _service,
                        onReorder: _onReorder,
                        red: _red,
                      ),

                      const SizedBox(height: 24),

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

                      const SizedBox(height: 24),
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
        if (snap.connectionState == ConnectionState.waiting) {
          return _Loading();
        }
        if (snap.hasError) {
          return _ErrorTile(message: snap.error.toString());
        }
        final orders = snap.data ?? [];
        if (orders.isEmpty) {
          return _EmptyTile(message: 'Nenhum pedido em andamento.');
        }
        return _OrderGroup(
          orders: orders,
          isActive: true,
          red: red,
          onReorder: onReorder,
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
        if (snap.connectionState == ConnectionState.waiting) {
          return _Loading();
        }
        if (snap.hasError) {
          return _ErrorTile(message: snap.error.toString());
        }
        final orders = snap.data ?? [];
        if (orders.isEmpty) {
          return _EmptyTile(
            message: 'Nenhum pedido finalizado nos últimos 3 meses.',
          );
        }
        return _OrderGroup(
          orders: orders,
          isActive: false,
          red: red,
          onReorder: onReorder,
        );
      },
    );
  }
}

class _Loading extends StatelessWidget {
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
  const _ErrorTile({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF0F0),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(
        child: Text(
          'Erro ao carregar pedidos.',
          style: const TextStyle(color: Color(0xFFC0392B), fontSize: 13),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

class _OrderGroup extends StatelessWidget {
  const _OrderGroup({
    required this.orders,
    required this.isActive,
    required this.red,
    required this.onReorder,
  });

  final List<OrderModel> orders;
  final bool isActive;
  final Color red;
  final Future<void> Function(BuildContext, OrderModel) onReorder;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: List.generate(orders.length, (i) {
          final isLast = i == orders.length - 1;
          return Column(
            children: [
              _OrderCard(
                order: orders[i],
                isActive: isActive,
                red: red,
                onReorder: onReorder,
              ),
              if (!isLast)
                const Divider(
                  height: 1,
                  thickness: 1,
                  color: Color(0xFFE0E0E0),
                ),
            ],
          );
        }),
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  const _OrderCard({
    required this.order,
    required this.isActive,
    required this.red,
    required this.onReorder,
  });

  final OrderModel order;
  final bool isActive;
  final Color red;
  final Future<void> Function(BuildContext, OrderModel) onReorder;

  static const int _maxVisible = 2;

  @override
  Widget build(BuildContext context) {
    final visibleItems = order.items.take(_maxVisible).toList();
    final extraCount = order.items.length - _maxVisible;
    final hasMore = extraCount > 0;

    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _UnitAvatar(logoUrl: order.unitLogoUrl),
              const SizedBox(width: 8),
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

                    if (!isActive) _StatusBadge(order: order, red: red),
                  ],
                ),
              ),
              Text(
                order.formattedTotal,
                style: const TextStyle(
                  color: Color(0xFF1A1A1A),
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          ...visibleItems.map(
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
                        fontSize: 13,
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
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 6),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (isActive)
                GestureDetector(
                  onTap: () =>
                      Navigator.pushNamed(context, AppRoutes.deliveries),
                  child: Text(
                    'Acompanhar Entrega',
                    style: TextStyle(
                      color: red,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      decoration: TextDecoration.underline,
                      decorationColor: red,
                    ),
                  ),
                )
              else if (hasMore)
                Text(
                  '+$extraCount item(s)',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFFAAAAAA),
                  ),
                )
              else
                const SizedBox.shrink(),

              if (!isActive)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (!order.isCancelled && !order.reviewed)
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
                          margin: const EdgeInsets.only(right: 8),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 7,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFF8E1),
                            border: Border.all(color: const Color(0xFFFFB800)),
                            borderRadius: BorderRadius.circular(8),
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
                                'Avaliar',
                                style: TextStyle(
                                  color: Color(0xFFFFB800),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                    GestureDetector(
                      onTap: () => onReorder(context, order),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          color: red,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.replay_rounded,
                              color: Colors.white,
                              size: 13,
                            ),
                            SizedBox(width: 5),
                            Text(
                              'Pedir novamente',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
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

          if (order.isCancelled && order.cancellationReason != null) ...[
            const SizedBox(height: 6),
            Text(
              'Cancelado: ${order.cancellationReason}',
              style: const TextStyle(
                color: Color(0xFFC0392B),
                fontSize: 11,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _UnitAvatar extends StatelessWidget {
  const _UnitAvatar({required this.logoUrl});
  final String logoUrl;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
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

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.order, required this.red});
  final OrderModel order;
  final Color red;

  @override
  Widget build(BuildContext context) {
    final isCancelled = order.isCancelled;
    return Row(
      children: [
        Icon(
          isCancelled ? Icons.cancel_outlined : Icons.check_circle_outline,
          size: 11,
          color: isCancelled ? red : const Color(0xFF27AE60),
        ),
        const SizedBox(width: 3),
        Text(
          isCancelled ? 'Cancelado' : 'Concluído',
          style: TextStyle(
            fontSize: 11,
            color: isCancelled ? red : const Color(0xFF27AE60),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
