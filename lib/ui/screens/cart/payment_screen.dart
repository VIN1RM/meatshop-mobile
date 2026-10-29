import 'package:meatshop_mobile/core/utils/field_validations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../models/cart_item_model.dart';
import '../../../models/checkout_summary_model.dart';
import '../../../providers/cart_provider.dart';
import '../../../providers/order_provider.dart';
import '../../widgets/app_header.dart';
import 'review_order_screen.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({
    super.key,
    required this.total,
    required this.addressId,
    this.unitDeliveryTypes = const {},
    this.isScheduled = false,
    this.scheduledDate,
    this.scheduledTime,
  });

  final double total;
  final String addressId;
  final Map<String, String> unitDeliveryTypes;
  final bool isScheduled;
  final DateTime? scheduledDate;
  final String? scheduledTime;

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  static const _red = Color(0xFFC0392B);
  static const _background = Color(0xFF2E2E2E);
  static const _surface = Color(0xFFF5F5F5);
  final _change = TextEditingController();
  final Map<String, String> _methods = {};
  Map<String, bool> _onlineUnits = {};
  bool _loading = true;
  String? _availabilityError;
  String? _changeError;
  int _loadGeneration = 0;

  bool _isOffline(String method) => method == 'cash' || method == 'machine';

  String _methodFor(String unitId) {
    final method = _methods[unitId] ?? 'cash';
    return !_isOffline(method) && _onlineUnits[unitId] != true
        ? 'cash'
        : method;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    if (!mounted) return;
    final generation = ++_loadGeneration;
    final units = context.read<CartProvider>().itemsByUnit.keys.toList();
    if (units.isEmpty) {
      setState(() {
        _onlineUnits = {};
        _methods.clear();
        _loading = false;
        _availabilityError = null;
      });
      return;
    }
    setState(() {
      _loading = true;
      _availabilityError = null;
    });
    try {
      final availability = await context
          .read<OrderProvider>()
          .paymentAvailability(units);
      if (!mounted || generation != _loadGeneration) return;
      setState(() {
        _onlineUnits = availability;
        _methods.removeWhere((id, _) => !units.contains(id));
        for (final id in units) {
          _methods[id] = _methodFor(id);
        }
      });
    } catch (_) {
      if (!mounted || generation != _loadGeneration) return;
      setState(() {
        _onlineUnits = {};
        _methods.updateAll((_, method) => _isOffline(method) ? method : 'cash');
        _availabilityError =
            'Não foi possível verificar os pagamentos online. Você pode tentar novamente ou escolher pagar na entrega.';
      });
    } finally {
      if (mounted && generation == _loadGeneration) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  void dispose() {
    _change.dispose();
    super.dispose();
  }

  void _choose(String unitId, String method) {
    setState(() {
      _methods[unitId] = method;
      _changeError = null;
    });
  }

  void _continue() {
    final units = context.read<CartProvider>().itemsByUnit.keys.toList();
    if (_loading || units.isEmpty) return;
    final methods = {for (final id in units) id: _methodFor(id)};
    final singleCash = units.length == 1 && methods[units.first] == 'cash';
    final raw = _change.text.trim();
    final amount = FieldValidations.parseMoney(raw);
    if (singleCash &&
        raw.isNotEmpty &&
        (amount == null || !amount.isFinite || amount < widget.total)) {
      setState(
        () => _changeError = 'Informe um valor para troco que cubra o pedido.',
      );
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ReviewOrderScreen(
          summary: CheckoutSummaryModel(
            addressId: widget.addressId,
            unitDeliveryTypes: widget.unitDeliveryTypes,
            isScheduled: widget.isScheduled,
            scheduledDate: widget.scheduledDate,
            scheduledTime: widget.scheduledTime,
            paymentMethod: methods[units.first]!,
            unitPaymentMethods: methods,
            changeFor: singleCash ? amount : null,
          ),
        ),
      ),
    );
  }

  String _money(double value) =>
      'R\$ ${value.toStringAsFixed(2).replaceAll('.', ',')}';

  @override
  Widget build(BuildContext context) {
    final groups = context.watch<CartProvider>().itemsByUnit;
    return Scaffold(
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
                            child: ListView(
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
                                        'PAGAMENTO',
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
                                Text(
                                  groups.length > 1
                                      ? 'Escolha como pagar em cada açougue'
                                      : 'Escolha como deseja pagar',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  groups.length > 1
                                      ? 'Cada açougue recebe separadamente. Você pode escolher uma forma diferente para cada pedido.'
                                      : 'Confira as opções disponíveis para o açougue do seu pedido.',
                                  style: const TextStyle(
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
                                      semanticsLabel:
                                          'Consultando formas de pagamento',
                                    ),
                                  ),
                                if (_availabilityError != null)
                                  _notice(
                                    _availabilityError!,
                                    Icons.wifi_off_outlined,
                                  ),
                                if (groups.isEmpty)
                                  _notice(
                                    'Seu carrinho está vazio. Adicione produtos para escolher como pagar.',
                                    Icons.shopping_bag_outlined,
                                  ),
                                for (final entry in groups.entries)
                                  _unitCard(
                                    entry.key,
                                    entry.value,
                                    groups.length,
                                  ),
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: TextButton.icon(
                                    onPressed: _loading ? null : _load,
                                    style: TextButton.styleFrom(
                                      foregroundColor: Colors.white,
                                      disabledForegroundColor: Colors.white38,
                                    ),
                                    icon: const Icon(Icons.refresh, size: 18),
                                    label: const Text(
                                      'Atualizar disponibilidade',
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          _footer(groups.isNotEmpty),
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
  }

  Widget _unitCard(String unitId, List<CartItemModel> items, int unitCount) {
    final method = _methodFor(unitId);
    final online = _onlineUnits[unitId] == true;
    final onlineSelected = !_isOffline(method);
    final name = items.first.unitName.isEmpty
        ? 'Açougue'
        : items.first.unitName;
    return Container(
      key: ValueKey('payment-unit-$unitId'),
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
                child: Text(
                  name,
                  style: const TextStyle(
                    color: Color(0xFF1A1A1A),
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFE8E8E8),
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.all(4),
            child: Row(
              children: [
                _tab(
                  'Pagar online',
                  Icons.smartphone_outlined,
                  onlineSelected,
                  !_loading && online ? () => _choose(unitId, 'pix') : null,
                ),
                const SizedBox(width: 4),
                _tab(
                  'Na entrega',
                  Icons.delivery_dining_outlined,
                  !onlineSelected,
                  !_loading ? () => _choose(unitId, 'cash') : null,
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          if (!_loading && !online && _availabilityError == null)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.info_outline,
                    size: 16,
                    color: Color(0xFF777777),
                  ),
                  const SizedBox(width: 6),
                  const Expanded(
                    child: Text(
                      'Este açougue está recebendo apenas na entrega no momento.',
                      style: TextStyle(
                        color: Color(0xFF666666),
                        fontSize: 12,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          if (onlineSelected && online) ...[
            _option(
              unitId,
              'pix',
              'Pix',
              'Pelo checkout Mercado Pago',
              Icons.pix,
            ),
            _option(
              unitId,
              'credit',
              'Cartão de crédito',
              'Condições confirmadas no checkout',
              Icons.credit_card,
            ),
            _option(
              unitId,
              'debit',
              'Cartão de débito',
              'Disponibilidade confirmada no checkout',
              Icons.credit_card_outlined,
            ),
            const Padding(
              padding: EdgeInsets.only(top: 8),
              child: Text(
                'Os dados do cartão e as opções de parcelamento são informados no ambiente seguro do Mercado Pago.',
                style: TextStyle(
                  color: Color(0xFF666666),
                  fontSize: 12,
                  height: 1.5,
                ),
              ),
            ),
          ] else ...[
            _option(
              unitId,
              'cash',
              'Dinheiro',
              'Pague ao receber seu pedido',
              Icons.payments_outlined,
            ),
            _option(
              unitId,
              'machine',
              'Maquininha',
              'Cartão na entrega',
              Icons.point_of_sale_outlined,
            ),
            if (method == 'machine')
              const Padding(
                padding: EdgeInsets.only(top: 8),
                child: Text(
                  'Confirme com o açougue a disponibilidade da maquininha e as bandeiras aceitas.',
                  style: TextStyle(
                    color: Color(0xFF666666),
                    fontSize: 12,
                    height: 1.5,
                  ),
                ),
              ),
            if (method == 'cash' && unitCount == 1) ...[
              const SizedBox(height: 12),
              TextField(
                key: const ValueKey('payment-change'),
                controller: _change,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9,.]')),
                ],
                onChanged: (_) {
                  if (_changeError != null) setState(() => _changeError = null);
                },
                style: const TextStyle(color: Color(0xFF1A1A1A)),
                decoration: InputDecoration(
                  labelText: 'Troco para (opcional)',
                  hintText: 'Ex.: 100,00',
                  prefixText: 'R\$ ',
                  filled: true,
                  fillColor: Colors.white,
                  helperText: 'Deixe em branco se for pagar o valor exato.',
                  helperMaxLines: 2,
                  errorText: _changeError,
                  errorMaxLines: 3,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Color(0xFFDDDDDD)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: _red),
                  ),
                ),
              ),
            ],
            if (method == 'cash' && unitCount > 1)
              const Padding(
                padding: EdgeInsets.only(top: 8),
                child: Text(
                  'Separe o valor exato deste pedido. Você confere o total de cada açougue na próxima etapa.',
                  style: TextStyle(
                    color: Color(0xFF666666),
                    fontSize: 12,
                    height: 1.5,
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }

  Widget _tab(
    String label,
    IconData icon,
    bool selected,
    VoidCallback? onPressed,
  ) => Expanded(
    child: Semantics(
      selected: selected,
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          backgroundColor: selected ? _red : Colors.transparent,
          foregroundColor: selected ? Colors.white : const Color(0xFF666666),
          disabledForegroundColor: selected
              ? Colors.white70
              : const Color(0xFF999999),
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 20),
            const SizedBox(height: 4),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    ),
  );

  Widget _option(
    String unitId,
    String value,
    String label,
    String subtitle,
    IconData icon,
  ) {
    final selected = _methodFor(unitId) == value;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Semantics(
        selected: selected,
        button: true,
        child: Material(
          color: selected ? const Color(0xFFFFF0ED) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            key: ValueKey('payment-$unitId-$value'),
            onTap: _loading ? null : () => _choose(unitId, value),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              decoration: BoxDecoration(
                border: Border.all(
                  color: selected ? _red : const Color(0xFFE0E0E0),
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    icon,
                    color: selected ? _red : const Color(0xFF777777),
                    size: 22,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          label,
                          style: TextStyle(
                            color: selected ? _red : const Color(0xFF222222),
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          subtitle,
                          style: const TextStyle(
                            color: Color(0xFF777777),
                            fontSize: 12,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    selected
                        ? Icons.radio_button_checked
                        : Icons.radio_button_off,
                    color: selected ? _red : const Color(0xFF999999),
                    size: 21,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _notice(String message, IconData icon) => Container(
    padding: const EdgeInsets.all(14),
    margin: const EdgeInsets.only(bottom: 16),
    decoration: BoxDecoration(
      color: const Color(0xFF3A3A3A),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Colors.white70, size: 20),
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

  Widget _footer(bool hasItems) => Container(
    width: double.infinity,
    padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
    decoration: const BoxDecoration(
      color: _background,
      border: Border(top: BorderSide(color: Colors.white12)),
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Wrap(
          alignment: WrapAlignment.spaceBetween,
          spacing: 16,
          runSpacing: 6,
          children: [
            const Text(
              'Subtotal dos produtos',
              style: TextStyle(color: Colors.white70, fontSize: 13),
            ),
            Text(
              _money(widget.total),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        const Text(
          'Frete, descontos e total final na revisão.',
          style: TextStyle(color: Colors.white54, fontSize: 12),
        ),
        const SizedBox(height: 12),
        ElevatedButton(
          onPressed: _loading || !hasItems ? null : _continue,
          style: ElevatedButton.styleFrom(
            backgroundColor: _red,
            foregroundColor: Colors.white,
            disabledBackgroundColor: Colors.white12,
            disabledForegroundColor: Colors.white38,
            minimumSize: const Size(double.infinity, 52),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            elevation: 0,
          ),
          child: const Text(
            'Revisar pedido',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
        ),
      ],
    ),
  );
}
