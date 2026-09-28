import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/checkout_summary_model.dart';
import '../../../providers/order_provider.dart';
import 'review_order_screen.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({
    super.key,
    required this.total,
    required this.addressId,
    this.isScheduled = false,
    this.scheduledDate,
    this.scheduledTime,
  });
  final double total;
  final String addressId;
  final bool isScheduled;
  final DateTime? scheduledDate;
  final String? scheduledTime;
  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  String _method = 'cash';
  bool? _online;
  String? _error;
  final _change = TextEditingController();
  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final enabled = await context
          .read<OrderProvider>()
          .onlinePaymentsAvailable();
      if (mounted) {
        setState(() {
          _online = enabled;
          _error = null;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _online = false;
          _error =
              'Não foi possível consultar os pagamentos online. Tente novamente.';
        });
      }
    }
  }

  @override
  void dispose() {
    _change.dispose();
    super.dispose();
  }

  void _continue() {
    final raw = _change.text.trim();
    final amount = double.tryParse(raw.replaceAll(',', '.'));
    if (_method == 'cash' &&
        raw.isNotEmpty &&
        (amount == null || !amount.isFinite || amount < widget.total)) {
      setState(
        () => _error = 'Informe um valor para troco que cubra o pedido.',
      );
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ReviewOrderScreen(
          summary: CheckoutSummaryModel(
            addressId: widget.addressId,
            isScheduled: widget.isScheduled,
            scheduledDate: widget.scheduledDate,
            scheduledTime: widget.scheduledTime,
            paymentMethod: _method,
            changeFor: _method == 'cash' ? amount : null,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Pagamento')),
    body: ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text(
          'Escolha como pagar',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        const Text(
          'Cada açougue recebe diretamente. Se houver mais de um açougue no carrinho, você concluirá um pagamento para cada pedido.',
        ),
        if (_online == null) const LinearProgressIndicator(),
        if (_online == true) ...[
          _option('pix', 'Pix no Mercado Pago', Icons.pix),
          _option(
            'credit',
            'Cartão de crédito no Mercado Pago',
            Icons.credit_card,
          ),
          _option(
            'debit',
            'Cartão de débito no Mercado Pago',
            Icons.credit_card,
          ),
          const Text(
            'Os dados do cartão e as opções de parcelamento são informados apenas no checkout seguro. A disponibilidade final dos meios é confirmada pelo Mercado Pago.',
          ),
        ] else if (_online == false)
          const Text('Pagamento online indisponível no momento.'),
        _option('cash', 'Dinheiro na entrega', Icons.payments_outlined),
        _option('machine', 'Cartão na entrega', Icons.point_of_sale),
        if (_method == 'machine')
          const Text(
            'Confirme com o açougue a disponibilidade de maquininha para sua entrega.',
          ),
        if (_method == 'cash')
          TextField(
            controller: _change,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: 'Troco para (opcional)',
              helperText:
                  'Para vários açougues, utilize o valor exato de cada pedido.',
            ),
          ),
        if (_error != null)
          Text(_error!, style: const TextStyle(color: Colors.red)),
        TextButton(
          onPressed: _load,
          child: const Text('Atualizar disponibilidade'),
        ),
        const SizedBox(height: 20),
        FilledButton(
          onPressed: _online == null ? null : _continue,
          child: const Text('Revisar pedido'),
        ),
      ],
    ),
  );
  Widget _option(String value, String label, IconData icon) => ListTile(
    leading: Icon(icon),
    title: Text(label),
    trailing: Icon(
      _method == value ? Icons.radio_button_checked : Icons.radio_button_off,
    ),
    onTap: () => setState(() {
      _method = value;
      _error = null;
    }),
  );
}
