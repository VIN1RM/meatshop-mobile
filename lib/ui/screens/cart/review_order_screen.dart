import 'package:flutter/material.dart';
import 'package:meatshop_mobile/core/utils/custom_snackbar.dart';
import 'package:meatshop_mobile/models/checkout_summary_model.dart';
import 'package:meatshop_mobile/models/address_model.dart';
import 'package:meatshop_mobile/providers/cart_provider.dart';
import 'package:meatshop_mobile/providers/payment_provider.dart';
import 'package:meatshop_mobile/providers/user/address_provider.dart';
import 'package:meatshop_mobile/services/delivery_fee_service.dart';
import 'package:meatshop_mobile/services/geocoding_service.dart';
import 'package:meatshop_mobile/ui/screens/fallback/order_processing_screen.dart';
import 'package:meatshop_mobile/ui/widgets/app_header.dart';
import 'package:provider/provider.dart';
import 'package:meatshop_mobile/providers/order_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
  bool _calculatingFees = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _calculateFees());
  }

  Future<void> _calculateFees() async {
    setState(() => _calculatingFees = true);

    try {
      final addressProvider = context.read<AddressProvider>();
      final cart = context.read<CartProvider>();

      final address = addressProvider.addresses
          .cast<AddressModel?>()
          .firstWhere(
            (a) => a?.id == widget.summary.addressId,
            orElse: () => null,
          );

      if (address == null) return;

      double? destLat = address.lat;
      double? destLng = address.lng;

      if (destLat == null || destLng == null) {
        final coords = await GeocodingService.instance.geocode(
          street: address.street,
          number: address.number,
          city: address.city,
          state: address.state,
          zipCode: address.zipCode,
        );
        destLat = coords?.lat;
        destLng = coords?.lng;
      }

      if (destLat == null || destLng == null) return;

      final fees = <String, double>{};

      for (final unitId in cart.itemsByUnit.keys) {
        final unitDoc = await FirebaseFirestore.instance
            .collection('units')
            .doc(unitId)
            .get();

        final data = unitDoc.data();
        if (data == null) continue;

        final unitLat = (data['lat'] as num?)?.toDouble();
        final unitLng = (data['lng'] as num?)?.toDouble();

        if (unitLat == null || unitLng == null) {
          final coords = await GeocodingService.instance.geocode(
            street: data['street'] as String? ?? '',
            number: data['number'] as String? ?? '',
            city: data['city'] as String? ?? '',
            state: data['state'] as String? ?? '',
            zipCode: data['zip_code'] as String? ?? '',
          );
          if (coords == null) continue;

          fees[unitId] = DeliveryFeeService.instance.calculate(
            unitLat: coords.lat,
            unitLng: coords.lng,
            destLat: destLat,
            destLng: destLng,
          );
        } else {
          fees[unitId] = DeliveryFeeService.instance.calculate(
            unitLat: unitLat,
            unitLng: unitLng,
            destLat: destLat,
            destLng: destLng,
          );
        }
      }

      if (mounted) setState(() => _feeByUnit = fees);
    } finally {
      if (mounted) setState(() => _calculatingFees = false);
    }
  }

  double get _totalDeliveryFee => _feeByUnit.values.fold(0, (s, f) => s + f);

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final addressProvider = context.watch<AddressProvider>();
    final paymentProvider = context.watch<PaymentProvider>();

    final address = addressProvider.addresses.cast<dynamic>().firstWhere(
      (a) => a.id == widget.summary.addressId,
      orElse: () => null,
    );

    final savedCard = widget.summary.savedCardId != null
        ? paymentProvider.cards.cast<dynamic>().firstWhere(
            (c) => c.id == widget.summary.savedCardId,
            orElse: () => null,
          )
        : null;

    final grandTotal = cart.total + _totalDeliveryFee;

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
                errorBuilder: (_, __, ___) =>
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

                        ...cart.itemsByUnit.entries.map(
                          (e) => _buildUnitGroup(e.key, e.value, cart),
                        ),

                        _buildPaymentCard(savedCard),
                        const SizedBox(height: 16),

                        _buildTotals(cart.total, grandTotal),
                        const SizedBox(height: 32),
                        _buildConfirmarButton(context, grandTotal),
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
            'Endereço de entrega',
            style: TextStyle(
              color: Color(0xFF1A1A1A),
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
                '${d.day} de ${months[d.month]} · ${widget.summary.scheduledTime ?? ''}',
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
        : 'Açougue';
    final subtotal = items.fold<double>(0, (s, i) => s + i.subtotal);
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
                            errorBuilder: (_, __, ___) => const Icon(
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
                              errorBuilder: (_, __, ___) => _imageFallback(),
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
                    '${item.quantity % 1 == 0 ? item.quantity.toInt() : item.quantity.toStringAsFixed(1)} ${item.unitOfMeasure.toUpperCase()}',
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
                            fee != null ? _fmt(fee) : 'Indisponível',
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

  Widget _buildPaymentCard(dynamic savedCard) {
    String label;
    IconData icon;

    switch (widget.summary.paymentMethod) {
      case 'pix':
        label = 'Pix';
        icon = Icons.pix;
        break;
      case 'credit':
        label = savedCard != null
            ? '${savedCard.brand.toUpperCase()} •••• ${savedCard.lastFour}'
            : 'Cartão de crédito';
        icon = Icons.credit_card;
        break;
      case 'debit':
        label = savedCard != null
            ? '${savedCard.brand.toUpperCase()} •••• ${savedCard.lastFour}'
            : 'Cartão de débito';
        icon = Icons.credit_card_outlined;
        break;
      case 'cash':
        label = 'Dinheiro na entrega';
        icon = Icons.money;
        break;
      case 'machine':
        label = widget.summary.cardBrand != null
            ? 'Maquininha · ${widget.summary.cardBrand}'
            : 'Maquininha na entrega';
        icon = Icons.point_of_sale;
        break;
      default:
        label = widget.summary.paymentMethod;
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
          Column(
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
                style: const TextStyle(color: Color(0xFF555555), fontSize: 12),
              ),
            ],
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
                      _fmt(_totalDeliveryFee),
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 15,
                      ),
                    ),
            ],
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
                _fmt(grandTotal),
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

  Widget _buildConfirmarButton(BuildContext context, double grandTotal) {
    final orderProvider = context.watch<OrderProvider>();
    final cart = context.read<CartProvider>();
    final canConfirm = !_calculatingFees && !orderProvider.isLoading;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ElevatedButton(
        onPressed: canConfirm
            ? () async {
                final success = await orderProvider.placeOrder(
                  summary: widget.summary,
                  items: cart.items,
                  total: grandTotal,
                  feeByUnit: _feeByUnit,
                  cartProvider: cart,
                );

                if (!context.mounted) return;

                if (success) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const OrderProcessingScreen(),
                    ),
                  );
                } else {
                  CustomSnackBar.error(
                    orderProvider.error ?? 'Erro ao confirmar pedido',
                    context: context,
                  );
                }
              }
            : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: _red,
          disabledBackgroundColor: _red.withOpacity(0.4),
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

  String _fmt(double valor) {
    final s = valor.toStringAsFixed(2).replaceAll('.', ',');
    final parts = s.split(',');
    final inteiro = parts[0].replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]}.',
    );
    return 'R\$$inteiro,${parts[1]}';
  }
}
