import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../providers/order_provider.dart';
import '../../../models/order_model.dart';
import '../../widgets/app_header.dart';

class OrderProcessingScreen extends StatefulWidget {
  const OrderProcessingScreen({super.key, this.orderIds = const []});
  final List<String> orderIds;
  @override
  State<OrderProcessingScreen> createState() => _OrderProcessingScreenState();
}

class _OrderProcessingScreenState extends State<OrderProcessingScreen>
    with WidgetsBindingObserver {
  static const _red = Color(0xFFC0392B);
  static const _background = Color(0xFF2E2E2E);
  static const _surface = Color(0xFFF5F5F5);
  Timer? _timer;
  List<OrderModel> _orders = [];
  bool _loading = false;
  String? _paying;
  String? _error;
  late final List<String> _ids;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _ids = widget.orderIds.isEmpty
        ? context
              .read<OrderProvider>()
              .lastCheckoutOrders
              .map((o) => o.id)
              .toList()
        : widget.orderIds;
    _refresh();
    _timer = Timer.periodic(const Duration(seconds: 10), (_) => _refresh());
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _refresh(reconcile: true);
    }
  }

  Future<void> _refresh({bool reconcile = false}) async {
    if (!mounted || _loading) return;
    setState(() => _loading = true);
    try {
      final provider = context.read<OrderProvider>();
      final orders = await Future.wait(
        _ids.map(
          (id) =>
              reconcile ? provider.refreshPayment(id) : provider.getOrder(id),
        ),
      );
      if (mounted) {
        setState(() {
          _orders = orders;
          _error = null;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(
          () => _error =
              'Não foi possível atualizar. Seu pedido continua salvo; tente novamente.',
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _pay(OrderModel order) async {
    setState(() {
      _paying = order.id;
      _error = null;
    });
    try {
      final url = Uri.parse(
        await context.read<OrderProvider>().payOrder(order.id),
      );
      if (url.scheme != 'https' ||
          !(url.host == 'mercadopago.com.br' ||
              url.host.endsWith('.mercadopago.com.br'))) {
        throw StateError('Invalid payment URL');
      }
      if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
        throw StateError('Could not open checkout');
      }
    } catch (_) {
      if (mounted) {
        setState(
          () => _error =
              'Não foi possível abrir o pagamento. Atualize o pedido e tente novamente.',
        );
      }
    } finally {
      if (mounted) setState(() => _paying = null);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: _background,
    body: Stack(
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
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 640),
                    child: Column(
                      children: [
                        Expanded(
                          child: RefreshIndicator(
                            color: _red,
                            onRefresh: () => _refresh(reconcile: true),
                            child: ListView(
                              physics: const AlwaysScrollableScrollPhysics(),
                              padding: const EdgeInsets.fromLTRB(
                                16,
                                12,
                                16,
                                24,
                              ),
                              children: [
                                Row(
                                  children: [
                                    IconButton.outlined(
                                      onPressed: () => Navigator.pop(context),
                                      tooltip: 'Voltar',
                                      style: IconButton.styleFrom(
                                        foregroundColor: Colors.white,
                                        side: const BorderSide(
                                          color: Colors.white54,
                                        ),
                                      ),
                                      icon: const Icon(
                                        Icons.arrow_back,
                                        size: 20,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    const Expanded(
                                      child: Text(
                                        'PAGAMENTOS',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 22,
                                          fontWeight: FontWeight.w900,
                                          letterSpacing: 1,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                const Text(
                                  'Acompanhe seus pedidos',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  'Seus pedidos ficam salvos. Confira abaixo a forma de pagamento e a situação de cada açougue.',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 13,
                                    height: 1.5,
                                  ),
                                ),
                                const SizedBox(height: 20),
                                if (_loading)
                                  const Padding(
                                    padding: EdgeInsets.only(bottom: 16),
                                    child: LinearProgressIndicator(
                                      color: _red,
                                      backgroundColor: Colors.white12,
                                      semanticsLabel: 'Atualizando pagamentos',
                                    ),
                                  ),
                                if (_error != null)
                                  _notice(_error!, error: true),
                                if (_ids.isEmpty)
                                  _notice(
                                    'Abra um pedido em Meus pedidos para consultar o pagamento.',
                                  ),
                                for (final order in _orders) _orderCard(order),
                              ],
                            ),
                          ),
                        ),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
                          decoration: const BoxDecoration(
                            color: _background,
                            border: Border(
                              top: BorderSide(color: Colors.white12),
                            ),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const Text(
                                'Os pagamentos são atualizados automaticamente.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white54,
                                  fontSize: 12,
                                  height: 1.4,
                                ),
                              ),
                              const SizedBox(height: 12),
                              ElevatedButton.icon(
                                onPressed: _loading || _ids.isEmpty
                                    ? null
                                    : () => _refresh(reconcile: true),
                                icon: const Icon(Icons.refresh, size: 20),
                                label: const Text(
                                  'Atualizar pagamentos',
                                  textAlign: TextAlign.center,
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: _red,
                                  foregroundColor: Colors.white,
                                  disabledBackgroundColor: Colors.white12,
                                  disabledForegroundColor: Colors.white38,
                                  minimumSize: const Size(double.infinity, 52),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  textStyle: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                  ),
                                  elevation: 0,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );

  Color _statusColor(OrderModel order) {
    if (order.refundStatus == 'PENDING' || order.refundStatus == 'FAILED') {
      return const Color(0xFF9A6700);
    }
    return switch (order.paymentStatus) {
      'PAID' => const Color(0xFF247A46),
      'REJECTED' || 'CHARGED_BACK' => _red,
      _ => const Color(0xFF666666),
    };
  }

  String _description(OrderModel order) {
    if (order.status == 'CANCELLED') {
      return 'Este pedido foi cancelado. Confira aqui a situação do pagamento e de eventuais devoluções.';
    }
    if (order.refundStatus == 'FAILED') {
      return 'Entre em contato com o açougue para acompanhar a devolução.';
    }
    if (order.refundStatus == 'PENDING') {
      return 'A devolução foi solicitada. Acompanhe a confirmação por aqui.';
    }
    if (order.paymentStatus == 'PAID') {
      return 'Pagamento confirmado. Acompanhe o andamento em Meus pedidos.';
    }
    if (order.isOfflinePayment && order.paymentStatus == 'PENDING') {
      return 'Pague ao receber. A confirmação aparece aqui após o registro do açougue.';
    }
    if (order.canPay) {
      return 'Conclua o pagamento no Mercado Pago. Ao voltar, atualizamos a situação do pedido.';
    }
    if (order.paymentStatus == 'PENDING' &&
        order.paymentDueAt != null &&
        order.paymentDueAt!.isBefore(DateTime.now())) {
      return 'O prazo de pagamento terminou. Atualize para consultar a situação do pedido.';
    }
    return 'Consulte os detalhes do pedido e acompanhe as atualizações por aqui.';
  }

  String _deadline(DateTime date) {
    final local = date.toLocal();
    String pad(int value) => value.toString().padLeft(2, '0');
    return '${pad(local.day)}/${pad(local.month)} às ${pad(local.hour)}:${pad(local.minute)}';
  }

  Widget _orderCard(OrderModel order) {
    final color = _statusColor(order);
    return Container(
      key: ValueKey('order-payment-${order.id}'),
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(9),
                decoration: BoxDecoration(
                  color: _red.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.storefront_outlined,
                  color: _red,
                  size: 22,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order.unitName.isEmpty ? 'Açougue' : order.unitName,
                      style: const TextStyle(
                        color: Color(0xFF1A1A1A),
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Pedido #${order.id}',
                      style: const TextStyle(
                        color: Color(0xFF777777),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1, color: Color(0xFFDDDDDD)),
          const SizedBox(height: 16),
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            spacing: 16,
            runSpacing: 12,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Total do pedido',
                    style: TextStyle(color: Color(0xFF777777), fontSize: 12),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    order.formattedTotal,
                    style: const TextStyle(
                      color: Color(0xFF1A1A1A),
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  order.paymentStatusLabel,
                  style: TextStyle(
                    color: color,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Icon(
                order.isOfflinePayment
                    ? Icons.payments_outlined
                    : Icons.account_balance_wallet_outlined,
                size: 18,
                color: const Color(0xFF777777),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  order.paymentMethodLabel,
                  style: const TextStyle(
                    color: Color(0xFF555555),
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (order.status == 'CANCELLED')
            const Padding(
              padding: EdgeInsets.only(bottom: 8),
              child: Text(
                'Pedido cancelado',
                style: TextStyle(
                  color: _red,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ),
          Text(
            _description(order),
            style: const TextStyle(
              color: Color(0xFF666666),
              fontSize: 12,
              height: 1.5,
            ),
          ),
          if (order.refundedAmount > 0)
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Text(
                'Valor devolvido: R\$ ${order.refundedAmount.toStringAsFixed(2).replaceAll('.', ',')}',
                style: const TextStyle(
                  color: Color(0xFF555555),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          if (order.paymentDueAt != null && order.canPay)
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Text(
                'Pague até ${_deadline(order.paymentDueAt!)}',
                style: const TextStyle(
                  color: _red,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          if (order.canPay)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _paying == null ? () => _pay(order) : null,
                  icon: const Icon(Icons.open_in_new, size: 18),
                  label: Text(
                    _paying == order.id ? 'Abrindo…' : 'Pagar este açougue',
                    textAlign: TextAlign.center,
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _red,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                    elevation: 0,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _notice(String message, {bool error = false}) => Container(
    margin: const EdgeInsets.only(bottom: 16),
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: const Color(0xFF3A3A3A),
      borderRadius: BorderRadius.circular(12),
      border: error ? Border.all(color: const Color(0xFFE19A90)) : null,
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          error ? Icons.error_outline : Icons.info_outline,
          color: Colors.white70,
          size: 20,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            message,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              height: 1.5,
            ),
          ),
        ),
      ],
    ),
  );
}
