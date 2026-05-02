import 'package:flutter/material.dart';
import 'package:meatshop_mobile/routes/app_routes.dart';
import 'package:meatshop_mobile/ui/widgets/app_header.dart';

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
  static const Color _pageBg = Color(0xFF2E2E2E);
  static const Color _cardBg = Color(0xFFE6E6E6);
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
          SizedBox(
            child: Stack(
              children: [
                Positioned.fill(
                  child: Image.asset(
                    'assets/images/background.png',
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) =>
                        Container(color: const Color(0xFF1A1A1A)),
                  ),
                ),
                SafeArea(bottom: false, child: const AppHeader()),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                const SizedBox(height: 20),
                const Text(
                  'ACOMPANHAR',
                  style: TextStyle(
                    color: Color.fromARGB(255, 255, 255, 255),
                    fontSize: 20,
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
          _buildContactButton(context),
        ],
      ),
    );
  }

  Widget _buildCard(Delivery delivery) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFF1A1A1A),
                ),
                child: ClipOval(
                  child: Image.asset(
                    delivery.logoAsset,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) =>
                        const Icon(Icons.store, color: _white, size: 22),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Column(
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
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: _red,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'Em rota',
                      style: TextStyle(
                        color: _white,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const Spacer(),
              const Icon(Icons.two_wheeler_outlined, color: _red, size: 28),
            ],
          ),

          const SizedBox(height: 14),

          Row(
            children: [
              Expanded(
                child: _buildInfoChip('Tempo de espera', delivery.tempoEspera),
              ),
              const SizedBox(width: 8),
              Expanded(child: _buildInfoChip('Previsão', delivery.previsao)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: Color(0xFF888888),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1A1A1A),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactButton(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      color: _pageBg,
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 62,
          child: ElevatedButton.icon(
            onPressed: () => Navigator.pushNamed(context, AppRoutes.chat),
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
      ),
    );
  }
}
