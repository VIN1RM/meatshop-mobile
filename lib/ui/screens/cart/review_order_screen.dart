import 'package:flutter/material.dart';
import 'package:meatshop_mobile/models/checkout_summary_model.dart';
import 'package:meatshop_mobile/providers/cart_provider.dart';
import 'package:meatshop_mobile/providers/payment_provider.dart';
import 'package:meatshop_mobile/providers/user/address_provider.dart';
import 'package:meatshop_mobile/ui/screens/fallback/order_processing_screen.dart';
import 'package:meatshop_mobile/ui/widgets/app_header.dart';
import 'package:provider/provider.dart';

class ReviewOrderScreen extends StatelessWidget {
  final CheckoutSummaryModel summary;
  const ReviewOrderScreen({super.key, required this.summary});

  static const Color _red = Color(0xFFC0392B);
  static const Color _white = Colors.white;

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final addressProvider = context.watch<AddressProvider>();
    final paymentProvider = context.watch<PaymentProvider>();

    final address = addressProvider.addresses.cast<dynamic>().firstWhere(
      (a) => a.id == summary.addressId,
      orElse: () => null,
    );

    final savedCard = summary.savedCardId != null
        ? paymentProvider.cards.cast<dynamic>().firstWhere(
            (c) => c.id == summary.savedCardId,
            orElse: () => null,
          )
        : null;

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

                        if (summary.isScheduled &&
                            summary.scheduledDate != null)
                          _buildScheduleCard(),
                        if (summary.isScheduled) const SizedBox(height: 16),

                        ...cart.itemsByUnit.entries.map(
                          (e) => _buildUnitGroup(e.key, e.value, cart),
                        ),

                        _buildPaymentCard(savedCard),
                        const SizedBox(height: 16),

                        _buildTotal(cart.total),
                        const SizedBox(height: 32),
                        _buildConfirmarButton(context, cart.total),
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
      margin: const EdgeInsets.symmetric(horizontal: 16),
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
    final d = summary.scheduledDate!;
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
                '${d.day} de ${months[d.month]} · ${summary.scheduledTime ?? ''}',
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
                const Icon(
                  Icons.storefront_outlined,
                  color: Color(0xFF888888),
                  size: 20,
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
            child: Row(
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
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentCard(dynamic savedCard) {
    String label;
    IconData icon;

    switch (summary.paymentMethod) {
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
        label = summary.cardBrand != null
            ? 'Maquininha · ${summary.cardBrand}'
            : 'Maquininha na entrega';
        icon = Icons.point_of_sale;
        break;
      default:
        label = summary.paymentMethod;
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

  Widget _buildTotal(double total) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
      child: Row(
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
            _fmt(total),
            style: const TextStyle(
              color: _white,
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmarButton(BuildContext context, double total) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ElevatedButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const OrderProcessingScreen()),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: _red,
          foregroundColor: _white,
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Confirmar pedido',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            const SizedBox(width: 8),
            Text(
              '· ${_fmt(total)}',
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
            ),
          ],
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
