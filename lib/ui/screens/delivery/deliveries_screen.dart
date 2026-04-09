import 'package:flutter/material.dart';

class Delivery {
  final String acougue;
  final String tempoEspera;
  final String previsao;
  final String logoAsset;

  const Delivery({
    required this.acougue,
    required this.tempoEspera,
    required this.previsao,
    this.logoAsset = '',
  });
}

class DeliveriesScreen extends StatelessWidget {
  const DeliveriesScreen({super.key});

  static const Color _red = Color(0xFFBE2C1B);
  static const Color _headerBg = Color(0xFF3A3A3A);
  static const Color _pageBg = Color(0xFFEFEFEF);
  static const Color _cardBg = Color(0xFFE6E6E6);
  static const Color _textDark = Color(0xFF525252);
  static const Color _white = Colors.white;

  static final List<Delivery> _deliveries = [
    const Delivery(
      acougue: 'Master Carnes',
      tempoEspera: '15-20 min',
      previsao: '20:35 - 20:40',
      logoAsset: 'assets/images/logo_master.png',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _pageBg,
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                const SizedBox(height: 20),
                const Text(
                  'ENTREGA',
                  style: TextStyle(
                    color: _red,
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 14),
                ..._deliveries.map(_buildCard),
                const SizedBox(height: 80),
              ],
            ),
          ),
          _buildContactButton(),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      color: _headerBg,
      padding: const EdgeInsets.only(top: 52, left: 16, right: 16, bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Icon(Icons.arrow_back, color: _white, size: 24),
              ),
              const SizedBox(width: 12),

              Container(
                width: 36,
                height: 36,
                decoration: const BoxDecoration(
                  color: _white,
                  shape: BoxShape.circle,
                ),
                child: ClipOval(
                  child: Image.asset(
                    'assets/images/logo1.png',
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => const Icon(
                      Icons.storefront_outlined,
                      color: _red,
                      size: 20,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'MeatShop',
                style: TextStyle(
                  color: _white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
              const Spacer(),

              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  border: Border.all(color: _white, width: 1.5),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.help_outline, color: _white, size: 20),
              ),
            ],
          ),
          const SizedBox(height: 14),
        ],
      ),
    );
  }

  Widget _buildCard(Delivery delivery) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(shape: BoxShape.circle),
            child: ClipOval(
              child: Image.asset(
                delivery.logoAsset,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: const Color(0xFF1A1A1A),
                  child: const Icon(Icons.store, color: _white, size: 22),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),

          Expanded(
            child: Column(
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
                const SizedBox(height: 6),

                RichText(
                  text: TextSpan(
                    style: const TextStyle(fontSize: 13, color: _textDark),
                    children: [
                      const TextSpan(
                        text: 'Tempo de espera:  ',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                      TextSpan(text: delivery.tempoEspera),
                    ],
                  ),
                ),
                const SizedBox(height: 3),

                RichText(
                  text: TextSpan(
                    style: const TextStyle(fontSize: 13, color: _textDark),
                    children: [
                      const TextSpan(
                        text: 'Previsão de entrega:  ',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                      TextSpan(text: delivery.previsao),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactButton() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 116),
      color: _pageBg,
      child: SizedBox(
        height: 62,
        child: ElevatedButton.icon(
          onPressed: () {},
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
    );
  }
}
