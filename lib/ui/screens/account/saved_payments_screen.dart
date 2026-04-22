import 'package:flutter/material.dart';
import 'package:meatshop_mobile/ui/components/sheets/payment_card_form_sheet.dart';

class _SavedCard {
  final String id;
  final String brand;
  final String lastFour;
  final String holderName;
  final String expiration;
  final bool isDefault;

  const _SavedCard({
    required this.id,
    required this.brand,
    required this.lastFour,
    required this.holderName,
    required this.expiration,
    this.isDefault = false,
  });
}

class SavedPaymentsScreen extends StatefulWidget {
  const SavedPaymentsScreen({super.key});

  @override
  State<SavedPaymentsScreen> createState() => _SavedPaymentsScreenState();
}

class _SavedPaymentsScreenState extends State<SavedPaymentsScreen> {
  static const Color _red = Color(0xFFC0392B);
  static const Color _white = Colors.white;

  bool _isLoading = false;

  final List<_SavedCard> _cards = const [
    _SavedCard(
      id: 'mp_card_001',
      brand: 'visa',
      lastFour: '4242',
      holderName: 'ANA CLARA GOES',
      expiration: '08/27',
      isDefault: true,
    ),
    _SavedCard(
      id: 'mp_card_002',
      brand: 'mastercard',
      lastFour: '1234',
      holderName: 'ANA CLARA GOES',
      expiration: '03/26',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
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
                _buildHeader(context),
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 20),
                        _pageTitle(),
                        const SizedBox(height: 6),
                        _buildSubtitle(),
                        const SizedBox(height: 20),

                        if (_isLoading)
                          const Center(
                            child: Padding(
                              padding: EdgeInsets.all(40),
                              child: CircularProgressIndicator(color: _red),
                            ),
                          )
                        else if (_cards.isEmpty)
                          _buildEmptyState()
                        else ...[
                          _sectionLabel('CARTÕES SALVOS'),
                          const SizedBox(height: 10),
                          ..._cards.map((c) => _buildCardItem(c)),
                        ],

                        const SizedBox(height: 20),
                        _sectionLabel('OUTRAS FORMAS'),
                        const SizedBox(height: 10),
                        _buildOtherMethods(),
                        const SizedBox(height: 24),
                        _buildAddCardButton(),
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

  Widget _buildHeader(BuildContext context) {
    return Container(
      color: Colors.transparent,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                border: Border.all(color: _white, width: 1.5),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.arrow_back, color: _white, size: 20),
            ),
          ),
          const SizedBox(width: 12),
          const Text(
            'MeatShop',
            style: TextStyle(
              color: _white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
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
        'FORMAS DE PAGAMENTO',
        style: TextStyle(
          color: _red,
          fontSize: 22,
          fontWeight: FontWeight.w900,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildSubtitle() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Text(
        'Seus cartões são armazenados com segurança pelo Mercado Pago.',
        style: TextStyle(color: Color(0xFF9E9E9E), fontSize: 12, height: 1.4),
      ),
    );
  }

  Widget _buildCardItem(_SavedCard card) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(16),
        border: card.isDefault
            ? Border.all(color: _red.withOpacity(0.4), width: 1.5)
            : null,
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 32,
            decoration: BoxDecoration(
              color: const Color(0xFFE0E0E0),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Center(
              child: Icon(
                _brandIcon(card.brand),
                color: _brandColor(card.brand),
                size: 22,
              ),
            ),
          ),
          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      '•••• •••• •••• ${card.lastFour}',
                      style: const TextStyle(
                        color: Color(0xFF1A1A1A),
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1,
                      ),
                    ),
                    if (card.isDefault) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: _red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'padrão',
                          style: TextStyle(
                            color: _red,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  '${card.holderName}  •  ${card.expiration}',
                  style: const TextStyle(
                    color: Color(0xFF9E9E9E),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          GestureDetector(
            onTap: () => _showCardOptions(card),
            child: const Icon(
              Icons.more_vert,
              color: Color(0xFF9E9E9E),
              size: 20,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOtherMethods() {
    final methods = [
      _PaymentMethod(Icons.pix, 'Pix', 'Pagamento instantâneo'),
      _PaymentMethod(Icons.money, 'Dinheiro', 'Pague na entrega'),
    ];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: List.generate(methods.length, (i) {
          final isLast = i == methods.length - 1;
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                child: Row(
                  children: [
                    Icon(
                      methods[i].icon,
                      color: const Color(0xFF3A3A3A),
                      size: 22,
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            methods[i].label,
                            style: const TextStyle(
                              color: Color(0xFF1A1A1A),
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            methods[i].subtitle,
                            style: const TextStyle(
                              color: Color(0xFF9E9E9E),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.check_circle_outline,
                      color: Color(0xFFBDBDBD),
                      size: 20,
                    ),
                  ],
                ),
              ),
              if (!isLast)
                const Divider(height: 1, color: Color(0xFFE0E0E0), indent: 16),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildAddCardButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GestureDetector(
        onTap: _openCardSheet,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: _red,
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add_card_outlined, color: _white, size: 20),
              SizedBox(width: 10),
              Text(
                'Adicionar novo cartão',
                style: TextStyle(
                  color: _white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openCardSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      useSafeArea: true,
      useRootNavigator: true,
      builder: (_) => PaymentCardFormSheet(
        onSave: (cardData) {
          setState(() {
            _cards.add(
              _SavedCard(
                id: 'mp_card_${DateTime.now().millisecondsSinceEpoch}',
                brand: _detectBrand(cardData.cardNumber),
                lastFour: cardData.cardNumber.substring(
                  cardData.cardNumber.length - 4,
                ),
                holderName: cardData.holderName,
                expiration:
                    '${cardData.expirationMonth}/${cardData.expirationYear.substring(2)}',
                isDefault: cardData.isDefault,
              ),
            );
          });
        },
      ),
    );
  }

  String _detectBrand(String number) {
    if (number.startsWith('4')) return 'visa';
    if (number.startsWith('5') || number.startsWith('2')) return 'mastercard';
    if (number.startsWith('6362') || number.startsWith('6363')) return 'elo';
    return 'credit_card';
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
      child: Column(
        children: [
          Icon(Icons.credit_card_off_outlined, color: Colors.white24, size: 64),
          const SizedBox(height: 16),
          const Text(
            'Nenhum cartão salvo',
            style: TextStyle(
              color: Colors.white54,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Adicione um cartão para agilizar seus próximos pedidos.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white38, fontSize: 13, height: 1.4),
          ),
        ],
      ),
    );
  }

  Widget _sectionLabel(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Text(
        text,
        style: const TextStyle(
          color: Color(0xFF9E9E9E),
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.4,
        ),
      ),
    );
  }

  IconData _brandIcon(String brand) {
    switch (brand) {
      case 'visa':
      case 'mastercard':
      case 'elo':
      case 'hipercard':
        return Icons.credit_card;
      default:
        return Icons.credit_card;
    }
  }

  Color _brandColor(String brand) {
    switch (brand) {
      case 'visa':
        return const Color(0xFF1A1F71);
      case 'mastercard':
        return const Color(0xFFEB001B);
      case 'elo':
        return const Color(0xFFFFD000);
      case 'hipercard':
        return const Color(0xFFB3131B);
      default:
        return const Color(0xFF3A3A3A);
    }
  }

  void _showCardOptions(_SavedCard card) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFFF5F5F5),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFBDBDBD),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            if (!card.isDefault)
              ListTile(
                leading: const Icon(
                  Icons.star_outline,
                  color: Color(0xFF3A3A3A),
                ),
                title: const Text('Definir como padrão'),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
            ListTile(
              leading: const Icon(
                Icons.delete_outline,
                color: Color(0xFFC0392B),
              ),
              title: const Text(
                'Remover cartão',
                style: TextStyle(color: Color(0xFFC0392B)),
              ),
              onTap: () {
                Navigator.pop(context);
                _showRemoveConfirmation(card);
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _showRemoveConfirmation(_SavedCard card) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Remover cartão',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Deseja remover o cartão terminado em ${card.lastFour}? Esta ação não pode ser desfeita.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancelar',
              style: TextStyle(color: Color(0xFF3A3A3A)),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text(
              'Remover',
              style: TextStyle(
                color: Color(0xFFC0392B),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PaymentMethod {
  final IconData icon;
  final String label;
  final String subtitle;
  const _PaymentMethod(this.icon, this.label, this.subtitle);
}
