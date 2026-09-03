import 'package:flutter/material.dart';
import 'package:meatshop_mobile/core/enums/chat_enums.dart';
import 'package:meatshop_mobile/core/enums/order_status_enum.dart';
import 'package:meatshop_mobile/core/utils/chat_args.dart';
import 'package:meatshop_mobile/core/utils/custom_snackbar.dart';
import 'package:meatshop_mobile/models/order_model.dart';
import 'package:meatshop_mobile/providers/auth/auth_provider.dart';
import 'package:meatshop_mobile/routes/app_routes.dart';
import 'package:meatshop_mobile/services/chat_service.dart';
import 'package:meatshop_mobile/data/repositories/realtime_repository.dart';
import 'package:meatshop_mobile/providers/order_provider.dart';
import 'package:meatshop_mobile/ui/components/sheets/cancel_order_sheet.dart';
import 'package:meatshop_mobile/ui/components/sheets/chat_participant_sheet.dart';
import 'package:meatshop_mobile/ui/widgets/app_header.dart';
import 'package:meatshop_mobile/ui/widgets/delivery_person_card.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

class DeliveriesScreen extends StatefulWidget {
  const DeliveriesScreen({super.key});

  @override
  State<DeliveriesScreen> createState() => _DeliveriesScreenState();
}

class _DeliveriesScreenState extends State<DeliveriesScreen> {
  static const Color _red = Color(0xFFBE2C1B);
  static const Color _pageBg = Color(0xFF2E2E2E);

  late String _currentUserId;
  late String _currentUserName;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final auth = Provider.of<AuthProvider>(context, listen: false);
    _currentUserId = auth.currentUser?.uid ?? '';
    _currentUserName = auth.currentUser?.displayName ?? 'Cliente';
  }

  void _showCancelSheet(OrderModel order) {
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
              await context.read<OrderProvider>().cancelOrder(
                orderId: order.id,
                reason: reason.label,
              );
              if (mounted) {
                CustomSnackBar.info(
                  'Pedido cancelado: ${reason.label}',
                  context: context,
                );
              }
            } catch (_) {
              if (mounted) {
                CustomSnackBar.error(
                  'Erro ao cancelar pedido.',
                  context: context,
                );
              }
            }
          },
        ),
      ),
    );
  }

  void _onContactTap(OrderModel order) async {
    final deliveryId = order.deliveryPersonId;
    final participant = await ChatParticipantDialog.show(
      context: context,
      unitName: order.unitName,
      secondaryName: deliveryId == null
          ? null
          : 'Entregador #${_shortId(deliveryId)}',
      secondaryType: ChatParticipantType.delivery,
    );
    if (participant == null || !mounted) return;
    final isUnit = participant == ChatParticipantType.unit;
    final receiverId = isUnit ? order.unitId : deliveryId!;
    final receiverName = isUnit
        ? order.unitName
        : 'Entregador #${_shortId(deliveryId)}';
    final backend = context.read<BackendRealtimeAccess>();
    if (!backend.enabled) {
      final service = ChatService();
      await service.getOrCreateConversation(
        currentUserId: _currentUserId,
        currentUserName: _currentUserName,
        currentUserType: ChatParticipantType.client,
        otherUserId: receiverId,
        otherUserName: receiverName,
        otherUserType: participant,
      );
    }

    if (!mounted) return;
    Navigator.pushNamed(
      context,
      AppRoutes.chat,
      arguments: ChatArgs(
        currentUserId: _currentUserId,
        currentUserName: _currentUserName,
        currentUserType: ChatParticipantType.client,
        otherUserId: receiverId,
        otherUserName: receiverName,
        otherUserType: participant,
        otherUserPhoto: null,
        orderId: int.tryParse(order.id),
      ),
    );
  }

  String _shortId(String? value) {
    if (value == null || value.isEmpty) return '';
    return value.length <= 8 ? value : value.substring(0, 8);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _pageBg,
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: StreamBuilder<List<OrderModel>>(
              stream: context.read<OrderProvider>().activeOrdersStream(),
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const _DeliveriesShimmer();
                }
                if (snap.hasError) {
                  return const Center(
                    child: Text(
                      'Erro ao carregar pedidos.',
                      style: TextStyle(color: Colors.white70),
                    ),
                  );
                }
                final orders = snap.data ?? [];
                if (orders.isEmpty) return _buildEmpty();
                return _buildList(orders);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return SizedBox(
      child: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/background.png',
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) =>
                  Container(color: const Color(0xFF1A1A1A)),
            ),
          ),
          const SafeArea(bottom: false, child: AppHeader()),
        ],
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.receipt_long_outlined, color: Colors.white24, size: 56),
          const SizedBox(height: 16),
          const Text(
            'Nenhum pedido em andamento',
            style: TextStyle(
              color: Colors.white54,
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Seus pedidos ativos aparecerão aqui',
            style: TextStyle(color: Colors.white30, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildList(List<OrderModel> orders) {
    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
      children: [
        const Text(
          'ACOMPANHAR',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '${orders.length} pedido${orders.length > 1 ? 's' : ''} em andamento',
          style: const TextStyle(color: Colors.white38, fontSize: 12),
        ),
        const SizedBox(height: 16),
        ...orders.map(
          (o) => _OrderCard(
            order: o,
            red: _red,
            onCancel: () => _showCancelSheet(o),
            onContact: () => _onContactTap(o),
          ),
        ),
      ],
    );
  }
}

const _kSteps = [
  OrderStatus.confirmed,
  OrderStatus.preparing,
  OrderStatus.ready,
  OrderStatus.outForDelivery,
  OrderStatus.delivered,
];

int _stepIndex(OrderStatus status) {
  final i = _kSteps.indexOf(status);
  return i < 0 ? 0 : i;
}

class _OrderCard extends StatelessWidget {
  const _OrderCard({
    required this.order,
    required this.red,
    required this.onCancel,
    required this.onContact,
  });

  final OrderModel order;
  final Color red;
  final VoidCallback onCancel;
  final VoidCallback onContact;

  static const Color _cardBg = Color(0xFFF0F0F0);
  static const Color _dark = Color(0xFF1A1A1A);

  @override
  Widget build(BuildContext context) {
    final isCancelled = order.isCancelled;
    final statusInfo = _statusInfo(order.status);
    final canCancel = OrderStatusX.fromString(order.status).canCancel;

    return Opacity(
      opacity: isCancelled ? 0.65 : 1.0,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: _cardBg,
          borderRadius: BorderRadius.circular(20),
          border: Border(
            left: BorderSide(
              color: isCancelled ? const Color(0xFF888888) : statusInfo.color,
              width: 4,
            ),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 14, 14, 0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _UnitAvatar(logoUrl: order.unitLogoUrl),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          order.unitName,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                            color: _dark,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                        const SizedBox(height: 3),
                        _StatusBadge(
                          info: statusInfo,
                          isCancelled: isCancelled,
                        ),
                        if (order.orderDate != null) ...[
                          const SizedBox(height: 3),
                          Text(
                            'Pedido em ${_formatDate(order.orderDate!)}',
                            style: const TextStyle(
                              color: Color(0xFF888888),
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        order.formattedTotal,
                        style: TextStyle(
                          color: isCancelled ? const Color(0xFF888888) : _dark,
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _deliveryTypeLabel(order.deliveryType),
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

            if (!isCancelled) ...[
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: _StatusStepper(
                  status: order.status,
                  activeColor: statusInfo.color,
                ),
              ),
              if (order.status == 'OUT_FOR_DELIVERY' &&
                  order.deliveryPersonId != null &&
                  order.deliveryPersonId!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 0, 14, 0),
                  child: DeliveryPersonCard(
                    deliveryPersonId: order.deliveryPersonId!,
                  ),
                ),
            ],

            if (isCancelled) ...[
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black12,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.info_outline_rounded,
                        color: Color(0xFF888888),
                        size: 14,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          order.cancellationReason != null
                              ? 'Cancelado: ${order.cancellationReason}'
                              : 'Este pedido foi cancelado.',
                          style: const TextStyle(
                            color: Color(0xFF888888),
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],

            if (order.items.isNotEmpty) ...[
              const SizedBox(height: 12),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 14),
                child: Divider(height: 1, color: Color(0xFFDDDDDD)),
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: _ItemsList(items: order.items),
              ),
            ],

            if (order.paymentMethod.isNotEmpty) ...[
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Row(
                  children: [
                    const Icon(
                      Icons.payments_outlined,
                      size: 13,
                      color: Color(0xFF888888),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      _paymentLabel(order.paymentMethod),
                      style: const TextStyle(
                        color: Color(0xFF888888),
                        fontSize: 12,
                      ),
                    ),
                    if (order.deliveryFee > 0) ...[
                      const Text(
                        ' · ',
                        style: TextStyle(
                          color: Color(0xFFCCCCCC),
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        'Frete R\$ ${order.deliveryFee.toStringAsFixed(2).replaceAll('.', ',')}',
                        style: const TextStyle(
                          color: Color(0xFF888888),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],

            const SizedBox(height: 14),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 14),
              child: Divider(height: 1, color: Color(0xFFDDDDDD)),
            ),
            const SizedBox(height: 10),

            Padding(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
              child: Row(
                children: [
                  if (canCancel) ...[
                    Expanded(
                      child: _ActionButton(
                        label: 'Cancelar',
                        icon: Icons.cancel_outlined,
                        color: red,
                        bgColor: red.withValues(alpha: 0.08),
                        onTap: onCancel,
                        bordered: true,
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                  Expanded(
                    child: _ActionButton(
                      label: 'Contatar',
                      icon: Icons.chat_bubble_outline_rounded,
                      color: const Color(0xFF1A1A1A),
                      bgColor: const Color(0xFFE0E0E0),
                      onTap: onContact,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _deliveryTypeLabel(String type) =>
      type == 'DELIVERY' ? 'Entrega em casa' : 'Retirada no local';

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
        return method;
    }
  }

  _StatusData _statusInfo(String status) {
    final s = OrderStatusX.fromString(status);
    return _StatusData(s.label, s.color, s.icon);
  }
}

class _StatusStepper extends StatelessWidget {
  const _StatusStepper({required this.status, required this.activeColor});

  final String status;
  final Color activeColor;

  @override
  Widget build(BuildContext context) {
    final parsed = OrderStatusX.fromString(status);
    final current = _stepIndex(parsed);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final total = _kSteps.length;
            final stepW = constraints.maxWidth / total;
            return Stack(
              children: [
                Container(
                  height: 3,
                  decoration: BoxDecoration(
                    color: const Color(0xFFDDDDDD),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),

                AnimatedContainer(
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.easeInOut,
                  height: 3,
                  width: current == 0
                      ? stepW * 0.5
                      : stepW * current + stepW * 0.5,
                  decoration: BoxDecoration(
                    color: activeColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 6),

        Row(
          children: List.generate(_kSteps.length, (i) {
            final done = i <= current;
            return Expanded(
              child: Text(
                _stepLabel(_kSteps[i]),
                textAlign: i == 0
                    ? TextAlign.left
                    : i == _kSteps.length - 1
                    ? TextAlign.right
                    : TextAlign.center,
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: done ? FontWeight.w700 : FontWeight.w400,
                  color: done ? activeColor : const Color(0xFFBBBBBB),
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            );
          }),
        ),
      ],
    );
  }

  String _stepLabel(OrderStatus s) {
    switch (s) {
      case OrderStatus.confirmed:
        return 'Confirmado';
      case OrderStatus.preparing:
        return 'Preparo';
      case OrderStatus.ready:
        return 'Pronto';
      case OrderStatus.outForDelivery:
        return 'Em rota';
      case OrderStatus.delivered:
        return 'Entregue';
      default:
        return '';
    }
  }
}

class _ItemsList extends StatelessWidget {
  const _ItemsList({required this.items});
  final List<OrderItemModel> items;

  static const int _maxVisible = 3;

  @override
  Widget build(BuildContext context) {
    final visible = items.take(_maxVisible).toList();
    final extra = items.length - _maxVisible;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...visible.map(
          (item) => Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              children: [
                SizedBox(
                  width: 48,
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
                Text(
                  'R\$ ${(item.unitPrice * item.quantity).toStringAsFixed(2).replaceAll('.', ',')}',
                  style: const TextStyle(
                    color: Color(0xFF555555),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
        if (extra > 0)
          Text(
            '+$extra item${extra > 1 ? 's' : ''}',
            style: const TextStyle(color: Color(0xFFAAAAAA), fontSize: 11),
          ),
      ],
    );
  }
}

class _UnitAvatar extends StatelessWidget {
  const _UnitAvatar({required this.logoUrl});
  final String logoUrl;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Color(0xFF1A1A1A),
      ),
      child: ClipOval(
        child: logoUrl.isNotEmpty
            ? Image.network(
                logoUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.store, color: Colors.white, size: 20),
              )
            : const Icon(Icons.store, color: Colors.white, size: 20),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.info, required this.isCancelled});
  final _StatusData info;
  final bool isCancelled;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: info.color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(info.icon, size: 11, color: info.color),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              info.label,
              style: TextStyle(
                fontSize: 11,
                color: info.color,
                fontWeight: FontWeight.w700,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.bgColor,
    required this.onTap,
    this.bordered = false,
  });

  final String label;
  final IconData icon;
  final Color color;
  final Color bgColor;
  final VoidCallback onTap;
  final bool bordered;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 38,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(10),
          border: bordered
              ? Border.all(color: color.withValues(alpha: 0.4))
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 15, color: color),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusData {
  final String label;
  final Color color;
  final IconData icon;
  const _StatusData(this.label, this.color, this.icon);
}

String _formatDate(DateTime date) {
  final d = date.toLocal();
  final day = d.day.toString().padLeft(2, '0');
  final month = d.month.toString().padLeft(2, '0');
  final hour = d.hour.toString().padLeft(2, '0');
  final min = d.minute.toString().padLeft(2, '0');
  return '$day/$month às $hour:$min';
}

class _DeliveriesShimmer extends StatelessWidget {
  const _DeliveriesShimmer();

  static const Color _base = Color(0xFFE0E0E0);
  static const Color _highlight = Color(0xFFF5F5F5);

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: _base,
      highlightColor: _highlight,
      child: ListView(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
        children: [
          Container(width: 140, height: 22, color: Colors.white),
          const SizedBox(height: 8),
          Container(width: 100, height: 14, color: Colors.white),
          const SizedBox(height: 20),
          _shimmerCard(),
          _shimmerCard(),
        ],
      ),
    );
  }

  Widget _shimmerCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(height: 14, width: 120, color: Colors.white),
                    const SizedBox(height: 6),
                    Container(height: 12, width: 80, color: Colors.white),
                  ],
                ),
              ),
              Container(width: 60, height: 16, color: Colors.white),
            ],
          ),
          const SizedBox(height: 16),
          Container(height: 3, width: double.infinity, color: Colors.white),
          const SizedBox(height: 14),
          Container(height: 12, width: double.infinity, color: Colors.white),
          const SizedBox(height: 6),
          Container(height: 12, width: 180, color: Colors.white),
          const SizedBox(height: 14),
          Container(
            height: 38,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ],
      ),
    );
  }
}
