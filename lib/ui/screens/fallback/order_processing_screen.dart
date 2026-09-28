import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../providers/order_provider.dart';
import '../../../models/order_model.dart';

class OrderProcessingScreen extends StatefulWidget {
  const OrderProcessingScreen({super.key, this.orderIds = const []});
  final List<String> orderIds;
  @override
  State<OrderProcessingScreen> createState() => _OrderProcessingScreenState();
}

class _OrderProcessingScreenState extends State<OrderProcessingScreen>
    with WidgetsBindingObserver {
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
    if (_loading) return;
    _loading = true;
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
      _loading = false;
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
    appBar: AppBar(title: const Text('Pagamentos dos pedidos')),
    body: RefreshIndicator(
      onRefresh: () => _refresh(reconcile: true),
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text(
            'Pedidos registrados',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const Text(
            'A confirmação do pagamento é feita pelo servidor. Pague cada açougue abaixo e volte ao app para acompanhar. Dinheiro e cartão na entrega ficam a pagar até o recebimento.',
          ),
          if (_orders.isEmpty && _ids.isNotEmpty && _error == null)
            const LinearProgressIndicator(),
          if (_ids.isEmpty)
            const Text('Abra um pedido na lista para consultar seu pagamento.'),
          for (final order in _orders)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${order.unitName} · Pedido #${order.id}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(order.formattedTotal),
                    Text(order.paymentStatusLabel),
                    if (order.status == 'CANCELLED')
                      const Text('Pedido cancelado'),
                    if (order.paymentDueAt != null && order.canPay)
                      Text('Pague até ${order.paymentDueAt!.toLocal()}'),
                    if (order.refundedAmount > 0)
                      Text(
                        'Valor devolvido: R\$ ${order.refundedAmount.toStringAsFixed(2)}',
                      ),
                    if (order.canPay)
                      FilledButton(
                        onPressed: _paying == null ? () => _pay(order) : null,
                        child: Text(
                          _paying == order.id
                              ? 'Abrindo…'
                              : 'Pagar este açougue',
                        ),
                      ),
                  ],
                ),
              ),
            ),
          if (_error != null)
            Text(_error!, style: const TextStyle(color: Colors.red)),
          TextButton(
            onPressed: () => _refresh(reconcile: true),
            child: const Text('Atualizar pagamentos'),
          ),
        ],
      ),
    ),
  );
}
