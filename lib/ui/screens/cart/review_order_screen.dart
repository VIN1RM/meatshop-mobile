import '../../widgets/chat_participant_avatar.dart';
import '../../../core/enums/chat_enums.dart';
import '../../widgets/checkout_step_header.dart';
import 'package:meatshop_mobile/ui/widgets/checkout_coupon_field.dart';
import 'package:meatshop_mobile/ui/widgets/app_surface.dart';
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
  String? _feeErrorCode;
  int _quoteGeneration = 0;
  final Map<String, String> _methods = {};
  final Map<String, String> _coupons = {};
  final Set<String> _couponDrafts = {};
  final Map<String, String> _couponErrors = {};
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
      _feeErrorCode = null;
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
        _feeErrorCode = error is ApiFailure ? error.code : null;
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

  Future<void> _applyCoupon(String unitId, String code) async {
    if (_calculatingFees) return;
    final generation = ++_quoteGeneration;
    final candidate = {..._coupons};
    if (code.isEmpty) {
      candidate.remove(unitId);
    } else {
      candidate[unitId] = code;
    }
    setState(() {
      _calculatingFees = true;
      _couponErrors.remove(unitId);
    });
    try {
      final quote = await context.read<OrderProvider>().quote(
        _summary.copyWith(couponCodes: candidate),
      );
      if (!mounted || generation != _quoteGeneration) return;
      if (quote == null || quote.groups.isEmpty) {
        throw StateError('Incomplete quote');
      }
      setState(() {
        _coupons
          ..clear()
          ..addAll(candidate);
        _quote = quote;
        _feeByUnit = {
          for (final group in quote.groups) group.unitId: group.deliveryFee,
        };
        _feesReady = true;
        _feeError = null;
        _feeErrorCode = null;
        _couponDrafts.remove(unitId);
      });
    } catch (error) {
      if (!mounted || generation != _quoteGeneration) return;
      setState(() {
        _couponDrafts.add(unitId);
        _couponErrors[unitId] =
            error is ApiFailure && error.code?.startsWith('COUPON_') == true
            ? error.message
            : 'Não foi possível validar este cupom. Tente novamente ou remova o código.';
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

                        if (!_summary.pickupOnly && address != null)
                          _buildAddressCard(address),
                        if (_summary.unitDeliveryTypes.containsValue('PICKUP'))
                          const Padding(
                            padding: EdgeInsets.all(16),
                            child: Text(
                              'Retire no açougue e apresente o código disponível nos detalhes do pedido. Sem taxa de entrega.',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              style: _reviewActionStyle,
                              onPressed: () =>
                                  Navigator.pop(context, 'edit-fulfilment'),
                              icon: const Icon(
                                Icons.edit_location_alt_outlined,
                              ),
                              label: const Text('Alterar entrega ou retirada'),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        if (widget.summary.isScheduled &&
                            widget.summary.scheduledDate != null)
                          _buildScheduleCard(),
                        if (widget.summary.isScheduled)
                          const SizedBox(height: 16),

                        ...reviewedGroups.entries.map(
                          (e) => _buildUnitGroup(e.key, e.value, cart),
                        ),

                        const SizedBox(height: 16),

                        if (_feeError != null)
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 16),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFF422F2D),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: const Color(0xFFF2C9C4),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.info_outline,
                                      color: Color(0xFFFFA99F),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        _feeErrorCode ==
                                                'UNIT_LOCATION_CONFIRMATION_REQUIRED'
                                            ? 'Localização do açougue pendente'
                                            : 'Revise antes de confirmar',
                                        style: const TextStyle(
                                          color: Color(0xFFFFFFFF),
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  _feeError!,
                                  style: const TextStyle(
                                    color: Color(0xFFFFC4BB),
                                    height: 1.5,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                SizedBox(
                                  width: double.infinity,
                                  child: FilledButton.icon(
                                    style: FilledButton.styleFrom(
                                      backgroundColor: _red,
                                      foregroundColor: Colors.white,
                                      minimumSize: const Size(0, 48),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    onPressed: _calculateFees,
                                    icon: const Icon(Icons.refresh),
                                    label: const Text('Atualizar cotação'),
                                  ),
                                ),
                                if (_feeErrorCode?.startsWith(
                                          'DELIVERY_LOCATION',
                                        ) ==
                                        true ||
                                    _feeErrorCode ==
                                        'UNIT_LOCATION_CONFIRMATION_REQUIRED')
                                  Padding(
                                    padding: const EdgeInsets.only(top: 10),
                                    child: SizedBox(
                                      width: double.infinity,
                                      child: OutlinedButton.icon(
                                        style: _reviewActionStyle,
                                        onPressed: () => Navigator.of(
                                          context,
                                        ).pop('edit-fulfilment'),
                                        icon: const Icon(
                                          Icons.edit_location_alt_outlined,
                                        ),
                                        label: Text(
                                          _feeErrorCode ==
                                                  'UNIT_LOCATION_CONFIRMATION_REQUIRED'
                                              ? 'Ver opções de recebimento'
                                              : 'Voltar e revisar a entrega',
                                        ),
                                      ),
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
                        if (_couponDrafts.isNotEmpty)
                          const Padding(
                            padding: EdgeInsets.all(16),
                            child: Text(
                              'Aplique ou remova o cupom digitado para confirmar o pedido.',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
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

  ButtonStyle get _reviewActionStyle => OutlinedButton.styleFrom(
    foregroundColor: Colors.white,
    backgroundColor: const Color(0xFF383838),
    side: const BorderSide(color: Colors.white30),
    minimumSize: const Size(0, 48),
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    textStyle: const TextStyle(fontWeight: FontWeight.w700),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  );

  Widget _pageTitle() => const Padding(
    padding: EdgeInsets.symmetric(horizontal: 16),
    child: CheckoutStepHeader(title: 'RESUMO DO PEDIDO'),
  );

  Widget _buildAddressCard(dynamic address) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 0),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF383838),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Endereço de entrega',
            style: TextStyle(
              color: Color(0xFFFFFFFF),
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '${address.street}, ${address.number}'
            '${address.complement.isNotEmpty ? ' – ${address.complement}' : ''}\n'
            '${address.neighborhood} · ${address.city}, ${address.state}',
            style: const TextStyle(
              color: Color(0xFFBBBBBB),
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
      'março',
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
        color: const Color(0xFF383838),
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
                  color: Color(0xFFFFFFFF),
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
              Text(
                '${d.day} de ${months[d.month]} · ${widget.summary.scheduledTime ?? ''}',
                style: const TextStyle(color: Color(0xFFBBBBBB), fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUnitGroup(String unitId, List items, CartProvider cart) => Theme(
    data: appDarkSurfaceTheme(context),
    child: _unitGroup(unitId, items, cart),
  );

  Widget _unitGroup(String unitId, List items, CartProvider cart) {
    final unitName = items.isNotEmpty && items.first.unitName.isNotEmpty
        ? items.first.unitName
        : 'Açougue';
    final official = _quote?.groups
        .where((g) => g.unitId == unitId)
        .firstOrNull;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      decoration: BoxDecoration(
        color: const Color(0xFF383838),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 8),
            child: Row(
              children: [
                ChatParticipantAvatar(
                  photoUrl: items.first.unitImageUrl,
                  type: ChatParticipantType.unit,
                  size: 40,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    unitName,
                    style: const TextStyle(
                      color: Color(0xFFFFFFFF),
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
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(
                    Icons.payments_outlined,
                    color: Colors.white70,
                  ),
                  title: Text(
                    switch (_methodFor(unitId)) {
                      'cash' => 'Dinheiro',
                      'machine' => 'Maquininha',
                      'pix' => 'Pix',
                      'credit' => 'Cartão de crédito',
                      _ => 'Cartão de débito',
                    },
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  subtitle: Text(
                    widget.summary.unitDeliveryTypes[unitId] == 'PICKUP'
                        ? 'Retirada no açougue'
                        : 'Entrega no endereço',
                    style: const TextStyle(color: Colors.white70),
                  ),
                  trailing: TextButton(
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFFFFA99F),
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Alterar'),
                  ),
                ),
                ExpansionTile(
                  tilePadding: EdgeInsets.zero,
                  iconColor: Colors.white70,
                  collapsedIconColor: Colors.white70,
                  title: const Text(
                    'Adicionar cupom',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                  children: [
                    CheckoutCouponField(
                      key: ValueKey('coupon-$unitId'),
                      code: _coupons[unitId],
                      error: _couponErrors[unitId],
                      busy: _calculatingFees,
                      discount: official?.discountAmount ?? 0,
                      onDraftChanged: (dirty) => setState(() {
                        _couponErrors.remove(unitId);
                        if (dirty) {
                          _couponDrafts.add(unitId);
                        } else {
                          _couponDrafts.remove(unitId);
                        }
                      }),
                      onApply: (code) => _applyCoupon(unitId, code),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFF4B4B4B)),

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
                        color: Color(0xFFFFFFFF),
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

          const SizedBox(height: 14),
        ],
      ),
    );
  }

  Widget _buildTotals(double subtotal, double grandTotal) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      child: Column(
        children: [
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Valores do pedido',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Subtotal',
                style: TextStyle(color: Colors.white, fontSize: 15),
              ),
              Text(
                _fmt(subtotal),
                style: const TextStyle(color: Colors.white, fontSize: 15),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Entrega',
                style: TextStyle(color: Colors.white, fontSize: 15),
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
                      widget.summary.pickupOnly
                          ? 'Sem taxa'
                          : _feesReady
                          ? _fmt(_totalDeliveryFee)
                          : 'Indisponível',
                      style: const TextStyle(color: Colors.white, fontSize: 15),
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
                _feesReady ? _fmt(grandTotal) : 'A calcular',
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
        _feesReady &&
        _couponDrafts.isEmpty &&
        !_calculatingFees &&
        !orderProvider.isLoading;

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
    color: const Color(0xFF4B4B4B),
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
