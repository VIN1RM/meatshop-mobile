import 'package:meatshop_mobile/core/network/api_failure.dart';
import 'package:flutter/material.dart';
import 'package:meatshop_mobile/core/utils/custom_snackbar.dart';
import 'package:meatshop_mobile/models/checkout_summary_model.dart';
import 'package:meatshop_mobile/providers/cart_provider.dart';
import 'package:meatshop_mobile/providers/user/address_provider.dart';
import 'package:meatshop_mobile/ui/screens/fallback/order_processing_screen.dart';
import 'package:meatshop_mobile/ui/widgets/app_header.dart';
import 'package:provider/provider.dart';
import 'package:meatshop_mobile/providers/order_provider.dart';
import 'package:meatshop_mobile/data/repositories/order_repository.dart';

class ReviewOrderScreen extends StatefulWidget {
  final CheckoutSummaryModel summary;
  const ReviewOrderScreen({super.key, required this.summary});

  @override
  State<ReviewOrderScreen> createState() => _ReviewOrderScreenState();
}

class _ReviewOrderScreenState extends State<ReviewOrderScreen> {
  static const Color _red = Color(0xFFC0392B);
  static const Color _white = Colors.white;

  Map<String, double> _feeByUnit = {};
  bool _calculatingFees = true;
  bool _feesReady = false;
  CheckoutQuote? _quote;
  String? _feeError;
  int _quoteGeneration = 0;
  final Map<String, String> _methods = {};
  final Map<String, String> _coupons = {};
  bool _online = false;
  final Map<String, bool> _unitOnline = {};
  String _methodFor(String unit) {
    final chosen = _methods[unit] ?? widget.summary.paymentMethod;
    return !(_unitOnline[unit] ?? _online) &&
            !const {'cash', 'machine'}.contains(chosen)
        ? 'cash'
        : chosen;
  }

  CheckoutSummaryModel get _summary => widget.summary.copyWith(
    clearChange:
        context.read<CartProvider>().itemsByUnit.length != 1 ||
        _methodFor(context.read<CartProvider>().itemsByUnit.keys.first) !=
            'cash',
    methods: {
      for (final unit in context.read<CartProvider>().itemsByUnit.keys)
        unit: _methodFor(unit),
    },
    couponCodes: _coupons,
    defaultMethod:
        !_online &&
            !const {'cash', 'machine'}.contains(widget.summary.paymentMethod)
        ? 'cash'
        : widget.summary.paymentMethod,
  );

  @override
  void initState() {
    super.initState();
    _methods.addAll(widget.summary.unitPaymentMethods);
    _coupons.addAll(widget.summary.coupons);
    WidgetsBinding.instance.addPostFrameCallback((_) => _calculateFees());
  }

  Future<void> _calculateFees() async {
    if (!mounted) return;
    final generation = ++_quoteGeneration;
    setState(() {
      _calculatingFees = true;
      _feesReady = false;
      _quote = null;
      _feeError = null;
      _feeByUnit = {};
    });
    final orderProvider = context.read<OrderProvider>();
    try {
      final recovered = await orderProvider.recoverPending(
        context.read<CartProvider>(),
      );
      if (!mounted || generation != _quoteGeneration) return;
      if (recovered) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const OrderProcessingScreen()),
        );
        return;
      }
      final cart = context.read<CartProvider>();
      await cart.loadCart();
      final activeUnits = cart.itemsByUnit.keys.toSet();
      _coupons.removeWhere((unit, _) => !activeUnits.contains(unit));
      _methods.removeWhere((unit, _) => !activeUnits.contains(unit));
      if (!mounted || generation != _quoteGeneration) return;
      try {
        _online = await orderProvider.onlinePaymentsAvailable();
        final available = await orderProvider.paymentAvailability(
          cart.itemsByUnit.keys.toList(),
        );
        if (!mounted || generation != _quoteGeneration) return;
        _unitOnline
          ..clear()
          ..addAll(available);
      } catch (_) {
        _online = false;
      }
      if (!_online) {
        _methods.updateAll(
          (key, value) =>
              const {'cash', 'machine'}.contains(value) ? value : 'cash',
        );
      }
      final quote = await orderProvider.quote(_summary);
      if (!mounted || generation != _quoteGeneration) return;
      if (generation != _quoteGeneration) return;
      if (quote == null || quote.groups.isEmpty) {
        throw StateError('Incomplete delivery quote');
      }
      setState(() {
        _feeByUnit = {
          for (final group in quote.groups) group.unitId: group.deliveryFee,
        };
        _quote = quote;
        _feesReady = true;
      });
    } catch (error) {
      if (!mounted || generation != _quoteGeneration) return;
      setState(() {
        _feeError = error is ApiFailure
            ? error.message
            : 'Não foi possível calcular a entrega. Tente novamente.';
      });
    } finally {
      if (mounted && generation == _quoteGeneration) {
        setState(() => _calculatingFees = false);
      }
    }
  }

  double get _totalDeliveryFee => _feeByUnit.values.fold(0, (s, f) => s + f);

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final addressProvider = context.watch<AddressProvider>();

    final address = addressProvider.addresses.cast<dynamic>().firstWhere(
      (a) => a.id == widget.summary.addressId,
      orElse: () => null,
    );

    final grandTotal = _quote?.totalAmount ?? 0;
    final reviewedGroups =
        _quote != null && _quote!.groups.every((g) => g.items.isNotEmpty)
        ? {for (final g in _quote!.groups) g.unitId: g.items}
        : cart.itemsByUnit;

    return Scaffold(
      backgroundColor: const Color(0xFF2E2E2E),
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
                errorBuilder: (context, error, stackTrace) =>
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

                        if (address != null) _buildAddressCard(address),
                        const SizedBox(height: 16),

                        if (widget.summary.isScheduled &&
                            widget.summary.scheduledDate != null)
                          _buildScheduleCard(),
                        if (widget.summary.isScheduled)
                          const SizedBox(height: 16),

                        ...reviewedGroups.entries.map(
                          (e) => _buildUnitGroup(e.key, e.value, cart),
                        ),

                        _buildPaymentCard(),
                        const SizedBox(height: 16),

                        if (_feeError != null)
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Column(
                              children: [
                                Text(
                                  _feeError!,
                                  style: const TextStyle(color: Colors.white),
                                ),
                                TextButton(
                                  onPressed: _calculateFees,
                                  child: const Text(
                                    'Tentar calcular novamente',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        _buildTotals(
                          _quote?.groups.fold<double>(
                                0,
                                (sum, g) => sum + g.subtotal,
                              ) ??
                              cart.total,
                          grandTotal,
                        ),
                        const SizedBox(height: 32),
                        _buildConfirmButton(context, grandTotal),
                        const SizedBox(height: 32),
                      ],
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

  Widget _pageTitle() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Text(
        'RESUMO DO PEDIDO',
        style: TextStyle(
          color: _white,
          fontSize: 22,
          fontWeight: FontWeight.w900,
          letterSpacing: 1.0,
        ),
      ),
    );
  }

  Widget _buildAddressCard(dynamic address) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 0),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'EndereÃ§o de entrega',
            style: TextStyle(
              color: Color(0xFF1A1A1A),
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '${address.street}, ${address.number}'
            '${address.complement.isNotEmpty ? ' â€“ ${address.complement}' : ''}\n'
            '${address.neighborhood} Â· ${address.city}, ${address.state}',
            style: const TextStyle(
              color: Color(0xFF555555),
              fontSize: 13,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleCard() {
    final months = [
      '',
      'janeiro',
      'fevereiro',
      'marÃ§o',
      'abril',
      'maio',
      'junho',
      'julho',
      'agosto',
      'setembro',
      'outubro',
      'novembro',
      'dezembro',
    ];
    final d = widget.summary.scheduledDate!;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          const Icon(Icons.calendar_today_outlined, color: _red, size: 20),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Entrega agendada',
                style: TextStyle(
                  color: Color(0xFF1A1A1A),
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
              Text(
                '${d.day} de ${months[d.month]} Â· ${widget.summary.scheduledTime ?? ''}',
                style: const TextStyle(color: Color(0xFF555555), fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUnitGroup(String unitId, List items, CartProvider cart) {
    final unitName = items.isNotEmpty && items.first.unitName.isNotEmpty
        ? items.first.unitName
        : 'AÃ§ougue';
    final official = _quote?.groups
        .where((g) => g.unitId == unitId)
        .firstOrNull;
    final subtotal =
        official?.subtotal ?? items.fold<double>(0, (s, i) => s + i.subtotal);
    final fee = _feeByUnit[unitId];

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 8),
            child: Row(
              children: [
                ClipOval(
                  child: SizedBox(
                    width: 36,
                    height: 36,
                    child: items.first.unitImageUrl.isNotEmpty
                        ? Image.network(
                            items.first.unitImageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(
                                  Icons.storefront_outlined,
                                  color: Color(0xFF888888),
                                  size: 20,
                                ),
                          )
                        : const Icon(
                            Icons.storefront_outlined,
                            color: Color(0xFF888888),
                            size: 20,
                          ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    unitName,
                    style: const TextStyle(
                      color: Color(0xFF1A1A1A),
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Column(
              children: [
                DropdownButtonFormField<String>(
                  isExpanded: true,
                  initialValue: _methodFor(unitId),
                  decoration: const InputDecoration(
                    labelText: 'Pagamento deste açougue',
                  ),
                  items: [
                    const DropdownMenuItem(
                      value: 'cash',
                      child: Text('Dinheiro'),
                    ),
                    const DropdownMenuItem(
                      value: 'machine',
                      child: Text('Maquininha'),
                    ),
                    if (_unitOnline[unitId] ?? _online) ...[
                      const DropdownMenuItem(value: 'pix', child: Text('Pix')),
                      const DropdownMenuItem(
                        value: 'credit',
                        child: Text('Crédito'),
                      ),
                      const DropdownMenuItem(
                        value: 'debit',
                        child: Text('Débito'),
                      ),
                    ],
                  ],
                  onChanged: _calculatingFees
                      ? null
                      : (value) {
                          if (value != null) {
                            _methods[unitId] = value;
                            _calculateFees();
                          }
                        },
                ),
                TextFormField(
                  initialValue: _coupons[unitId],
                  decoration: const InputDecoration(
                    labelText: 'Cupom deste açougue',
                    helperText: 'Digite e confirme para atualizar a cotação',
                  ),
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (value) {
                    final code = value.trim();
                    if (code.isEmpty) {
                      _coupons.remove(unitId);
                    } else {
                      _coupons[unitId] = code;
                    }
                    _calculateFees();
                  },
                ),
                if (official != null && official.discountAmount > 0)
                  Text('Desconto: ${_fmt(official.discountAmount)}'),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFE0E0E0)),

          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 4),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: SizedBox(
                      width: 52,
                      height: 52,
                      child: item.productImageUrl.isNotEmpty
                          ? Image.network(
                              item.productImageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  _imageFallback(),
                            )
                          : _imageFallback(),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      item.productName,
                      style: const TextStyle(
                        color: Color(0xFF1A1A1A),
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Text(
                    item.quantityLabel,
                    style: const TextStyle(
                      color: _red,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const Divider(height: 1, color: Color(0xFFE0E0E0)),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Subtotal',
                      style: TextStyle(color: Color(0xFF555555), fontSize: 13),
                    ),
                    Text(
                      _fmt(subtotal),
                      style: const TextStyle(
                        color: Color(0xFF1A1A1A),
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Taxa de entrega',
                      style: TextStyle(color: Color(0xFF555555), fontSize: 13),
                    ),
                    _calculatingFees
                        ? const SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(
                              color: _red,
                              strokeWidth: 1.5,
                            ),
                          )
                        : Text(
                            fee != null ? _fmt(fee) : 'IndisponÃ­vel',
                            style: TextStyle(
                              color: fee != null
                                  ? const Color(0xFF1A1A1A)
                                  : Colors.grey,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentCard() {
    String label;
    IconData icon;

    switch (widget.summary.paymentMethod) {
      case 'pix':
        label = 'Pix';
        icon = Icons.pix;
        break;
      case 'credit':
        label = 'Cartão de crédito no Mercado Pago';
        icon = Icons.credit_card;
        break;
      case 'debit':
        label = 'Cartão de débito no Mercado Pago';
        icon = Icons.credit_card_outlined;
        break;
      case 'cash':
        label = 'Dinheiro na entrega';
        icon = Icons.money;
        break;
      case 'machine':
        label = 'Maquininha na entrega';
        icon = Icons.point_of_sale;
        break;
      default:
        label = widget.summary.paymentMethod;
        icon = Icons.payment;
    }

    if (_summary.unitPaymentMethods.isNotEmpty) {
      label = 'Confira as formas escolhidas para cada açougue acima';
      icon = Icons.payment;
    }
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(icon, color: _red, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Forma de pagamento',
                  style: TextStyle(
                    color: Color(0xFF1A1A1A),
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
                Text(
                  label,
                  style: const TextStyle(
                    color: Color(0xFF555555),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTotals(double subtotal, double grandTotal) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Subtotal',
                style: TextStyle(color: Colors.white54, fontSize: 15),
              ),
              Text(
                _fmt(subtotal),
                style: const TextStyle(color: Colors.white54, fontSize: 15),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Entrega',
                style: TextStyle(color: Colors.white54, fontSize: 15),
              ),
              _calculatingFees
                  ? const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(
                        color: _red,
                        strokeWidth: 1.5,
                      ),
                    )
                  : Text(
                      _feesReady ? _fmt(_totalDeliveryFee) : 'Indisponível',
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 15,
                      ),
                    ),
            ],
          ),
          if ((_quote?.groups.fold<double>(
                    0,
                    (sum, g) => sum + g.discountAmount,
                  ) ??
                  0) >
              0)
            Text(
              'Desconto: ${_fmt(_quote!.groups.fold<double>(0, (sum, g) => sum + g.discountAmount))}',
              style: const TextStyle(color: Colors.white),
            ),
          const SizedBox(height: 10),
          const Divider(color: Colors.white12),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total',
                style: TextStyle(
                  color: _white,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                _feesReady ? _fmt(grandTotal) : 'Aguardando entrega',
                style: const TextStyle(
                  color: _white,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmButton(BuildContext context, double grandTotal) {
    final orderProvider = context.watch<OrderProvider>();
    final cart = context.read<CartProvider>();
    final canConfirm =
        _feesReady && !_calculatingFees && !orderProvider.isLoading;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ElevatedButton(
        onPressed: canConfirm
            ? () async {
                if (_quote?.expiresAt?.isBefore(DateTime.now()) ?? false) {
                  await _calculateFees();
                  return;
                }
                final success = await orderProvider.placeOrder(
                  summary: _summary,
                  quoteToken: _quote?.token,
                  items: cart.items,
                  total: grandTotal,
                  feeByUnit: _feeByUnit,
                  cartProvider: cart,
                );

                if (!context.mounted) return;

                if (success) {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                      builder: (_) => const OrderProcessingScreen(),
                    ),
                    (route) => route.isFirst,
                  );
                } else {
                  CustomSnackBar.error(
                    orderProvider.error ?? 'Erro ao confirmar pedido',
                    context: context,
                  );
                  await _calculateFees();
                }
              }
            : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: _red,
          disabledBackgroundColor: _red.withValues(alpha: 0.4),
          foregroundColor: _white,
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 0,
        ),
        child: orderProvider.isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  color: _white,
                  strokeWidth: 2.5,
                ),
              )
            : const Text(
                'Confirmar pedido',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
      ),
    );
  }

  Widget _imageFallback() => Container(
    color: const Color(0xFFE0E0E0),
    child: const Icon(Icons.image_outlined, color: Color(0xFFBDBDBD), size: 26),
  );

  String _fmt(double value) {
    final s = value.toStringAsFixed(2).replaceAll('.', ',');
    final parts = s.split(',');
    final inteiro = parts[0].replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]}.',
    );
    return 'R\$$inteiro,${parts[1]}';
  }
}
