import 'package:flutter/material.dart';
import 'package:meatshop_mobile/models/delivery_order_model.dart';
import 'package:meatshop_mobile/providers/delivery/delivery_provider.dart';
import 'package:meatshop_mobile/ui/components/sheets/delivery_details_sheet.dart';
import 'package:meatshop_mobile/ui/widgets/app_header.dart';
import 'package:provider/provider.dart';

class DeliveryHistoryScreen extends StatefulWidget {
  const DeliveryHistoryScreen({super.key});

  @override
  State<DeliveryHistoryScreen> createState() => _DeliveryHistoryScreenState();
}

class _DeliveryHistoryScreenState extends State<DeliveryHistoryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DeliveryProvider>().loadHistory();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DeliveryProvider>(
      builder: (context, provider, _) {
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
                  children: [
                    const AppHeader(),
                    _HistoryHeader(onRefresh: provider.loadHistory),
                    Expanded(child: _HistoryBody(provider: provider)),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _HistoryHeader extends StatelessWidget {
  const _HistoryHeader({required this.onRefresh});

  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 8, 12),
      child: Row(
        children: [
          const Expanded(
            child: Text(
              'HISTÓRICO DE ENTREGAS',
              style: TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.1,
              ),
            ),
          ),
          IconButton(
            onPressed: onRefresh,
            icon: const Icon(Icons.refresh, color: Colors.white54, size: 20),
            tooltip: 'Atualizar',
          ),
        ],
      ),
    );
  }
}

class _HistoryBody extends StatelessWidget {
  const _HistoryBody({required this.provider});

  final DeliveryProvider provider;

  @override
  Widget build(BuildContext context) {
    if (provider.isLoadingHistory) {
      return const _LoadingHistory();
    }

    if (provider.historyError != null) {
      return _ErrorHistory(
        message: provider.historyError!,
        onRetry: provider.loadHistory,
      );
    }

    if (provider.historyOrders.isEmpty) {
      return const _EmptyHistory();
    }

    return _HistoryList(orders: provider.historyOrders);
  }
}

class _LoadingHistory extends StatelessWidget {
  const _LoadingHistory();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(
        color: Color(0xFFC0392B),
        strokeWidth: 2.5,
      ),
    );
  }
}

class _ErrorHistory extends StatelessWidget {
  const _ErrorHistory({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.cloud_off, color: Colors.white24, size: 48),
          const SizedBox(height: 12),
          Text(
            message,
            style: const TextStyle(color: Colors.white54, fontSize: 15),
          ),
          const SizedBox(height: 16),
          TextButton(
            onPressed: onRetry,
            child: const Text(
              'Tentar novamente',
              style: TextStyle(color: Color(0xFFC0392B)),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyHistory extends StatelessWidget {
  const _EmptyHistory();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.history, color: Colors.white12, size: 56),
          SizedBox(height: 16),
          Text(
            'Nenhuma entrega ainda',
            style: TextStyle(
              color: Colors.white54,
              fontSize: 17,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 6),
          Text(
            'Suas entregas do último mês aparecerão aqui',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white38, fontSize: 13),
          ),
        ],
      ),
    );
  }
}

class _HistoryList extends StatelessWidget {
  const _HistoryList({required this.orders});

  final List<DeliveryOrder> orders;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: orders.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (_, index) => _HistoryCard(order: orders[index]),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  const _HistoryCard({required this.order});

  final DeliveryOrder order;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => DeliveryDetailsSheet.show(context, order),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _CardHeader(order: order),
            const Divider(color: Color(0xFFE0E0E0), height: 1),
            _CardAddress(address: order.address.fullAddress),
          ],
        ),
      ),
    );
  }
}

class _CardHeader extends StatelessWidget {
  const _CardHeader({required this.order});

  final DeliveryOrder order;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      child: Row(
        children: [
          const _StatusIcon(),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Pedido #${order.id}',
                  style: const TextStyle(
                    color: Color(0xFF1A1A1A),
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  order.clientName,
                  style: const TextStyle(
                    color: Color(0xFF555555),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          _CardTotal(total: order.total),
        ],
      ),
    );
  }
}

class _StatusIcon extends StatelessWidget {
  const _StatusIcon();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: const Color(0xFF2ECC71).withValues(alpha: 0.12),
        shape: BoxShape.circle,
      ),
      child: const Icon(
        Icons.check_circle_outline,
        color: Color(0xFF2ECC71),
        size: 20,
      ),
    );
  }
}

class _CardTotal extends StatelessWidget {
  const _CardTotal({required this.total});

  final double total;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          'R\$ ${total.toStringAsFixed(2)}',
          style: const TextStyle(
            color: Color(0xFF2ECC71),
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
        const Text(
          'Entregue',
          style: TextStyle(color: Color(0xFF888888), fontSize: 11),
        ),
      ],
    );
  }
}

class _CardAddress extends StatelessWidget {
  const _CardAddress({required this.address});

  final String address;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.location_on_outlined,
            color: Color(0xFF888888),
            size: 15,
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              address,
              style: const TextStyle(color: Color(0xFF888888), fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}
