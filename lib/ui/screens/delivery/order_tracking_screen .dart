import 'package:flutter/material.dart';
import 'package:meatshop_mobile/routes/app_routes.dart';
import 'package:meatshop_mobile/ui/widgets/app_header.dart';
import 'package:meatshop_mobile/ui/dialogs/cancel_order_dialog.dart';

enum OrderStatus {
  pending,
  confirmed,
  preparing,
  ready,
  outForDelivery,
  delivered,
  cancelled,
}

class Delivery {
  final String acougue;
  final String tempoEspera;
  final String previsao;
  final String logoAsset;
  final OrderStatus status;

  const Delivery({
    required this.acougue,
    required this.tempoEspera,
    required this.previsao,
    this.logoAsset = '',
    this.status = OrderStatus.confirmed,
  });

  bool get canCancel =>
      status == OrderStatus.pending || status == OrderStatus.confirmed;

  String get statusLabel {
    switch (status) {
      case OrderStatus.pending:
        return 'Aguardando confirmação';
      case OrderStatus.confirmed:
        return 'Confirmado';
      case OrderStatus.preparing:
        return 'Em preparo';
      case OrderStatus.ready:
        return 'Pronto para entrega';
      case OrderStatus.outForDelivery:
        return 'Em rota';
      case OrderStatus.delivered:
        return 'Entregue';
      case OrderStatus.cancelled:
        return 'Cancelado';
    }
  }

  Color statusColor(Color red) {
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
        return red;
      case OrderStatus.delivered:
        return const Color(0xFF4CAF50);
      case OrderStatus.cancelled:
        return const Color(0xFF888888);
    }
  }
}

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

  late List<Delivery> _deliveries;

  @override
  void initState() {
    super.initState();
    _deliveries = [
      const Delivery(
        acougue: 'Master Carnes',
        tempoEspera: '15-20 min',
        previsao: '20:35 - 20:40',
        logoAsset: 'assets/images/logo_master.png',
        status: OrderStatus.confirmed,
      ),
    ];
  }

  void _showCancelDialog(int index) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: CancelOrderDialog(
          onConfirm: (reason) {
            setState(() {
              final d = _deliveries[index];
              _deliveries[index] = Delivery(
                acougue: d.acougue,
                tempoEspera: d.tempoEspera,
                previsao: d.previsao,
                logoAsset: d.logoAsset,
                status: OrderStatus.cancelled,
              );
            });

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
          },
        ),
      ),
    );
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
            child: ListView(
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
                ..._deliveries.asMap().entries.map(
                  (e) => _buildCard(e.value, e.key),
                ),
                const SizedBox(height: 80),
              ],
            ),
          ),
          _buildContactButton(),
        ],
      ),
    );
  }

  Widget _buildCard(Delivery delivery, int index) {
    final isCancelled = delivery.status == OrderStatus.cancelled;

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
                    child: Image.asset(
                      delivery.logoAsset,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          const Icon(Icons.store, color: _white, size: 22),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      delivery.acougue,
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
                        color: delivery.statusColor(_red),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        delivery.statusLabel,
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

            if (!isCancelled)
              Row(
                children: [
                  Expanded(
                    child: _buildInfoChip(
                      'Tempo de espera',
                      delivery.tempoEspera,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildInfoChip('Previsão', delivery.previsao),
                  ),
                ],
              ),

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
                child: const Text(
                  'Este pedido foi cancelado.',
                  style: TextStyle(
                    color: Color(0xFF888888),
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),

            if (delivery.canCancel) ...[
              const SizedBox(height: 12),
              const Divider(color: Color(0xFFCCCCCC), height: 1),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () => _showCancelDialog(index),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
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

  Widget _buildInfoChip(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: Color(0xFF888888),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1A1A1A),
            ),
          ),
        ],
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
            onPressed: () => Navigator.pushNamed(context, AppRoutes.chat),
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
