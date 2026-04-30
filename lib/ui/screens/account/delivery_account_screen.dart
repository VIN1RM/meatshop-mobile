import 'package:flutter/material.dart';
import 'package:meatshop_mobile/providers/delivery/delivery_provider.dart';
import 'package:meatshop_mobile/routes/app_routes.dart';
import 'package:provider/provider.dart';

class DeliveryAccountScreen extends StatefulWidget {
  const DeliveryAccountScreen({super.key});

  @override
  State<DeliveryAccountScreen> createState() => _DeliveryAccountScreenState();
}

class _DeliveryAccountScreenState extends State<DeliveryAccountScreen> {
  bool _isLoggingOut = false;

  static const Color _red = Color(0xFFC0392B);
  static const Color _white = Colors.white;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DeliveryProvider>();

    return Stack(
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
              _buildHeader(),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),
                      _pageTitle(),
                      const SizedBox(height: 16),
                      _buildProfileCard(provider),
                      const SizedBox(height: 20),
                      _buildStatsRow(provider),
                      const SizedBox(height: 20),
                      _buildMenuList(context, provider),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      color: Colors.transparent,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
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
                  size: 22,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
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
        'MINHA CONTA',
        style: TextStyle(
          color: _red,
          fontSize: 22,
          fontWeight: FontWeight.w900,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildProfileCard(DeliveryProvider provider) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.fromLTRB(14, 16, 14, 14),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: const Color(0xFFBDBDBD),
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFE0E0E0), width: 2),
                ),
                child: const Icon(Icons.person, color: Colors.white, size: 32),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      provider.deliveryPersonName,
                      style: const TextStyle(
                        color: Color(0xFF1A1A1A),
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        const Icon(
                          Icons.star,
                          color: Color(0xFFFFC107),
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${provider.averageRating} · ${provider.vehicle}',
                          style: const TextStyle(
                            color: Color(0xFF555555),
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1, color: Color(0xFFE0E0E0)),
          const SizedBox(height: 14),
          _infoRow('Veículo:', provider.vehicle),
          const SizedBox(height: 6),
          _infoRow('Avaliação média:', '${provider.averageRating} ★'),
          const SizedBox(height: 6),
          _infoRow('Entregas realizadas:', '${provider.historyOrders.length}'),
        ],
      ),
    );
  }

  Widget _buildStatsRow(DeliveryProvider provider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _StatCard(
            label: 'Entregas',
            value: '${provider.historyOrders.length}',
            icon: Icons.local_shipping_outlined,
          ),
          const SizedBox(width: 12),
          _StatCard(
            label: 'Avaliação',
            value: '${provider.averageRating}',
            icon: Icons.star_outline,
          ),
        ],
      ),
    );
  }

  Widget _buildMenuList(BuildContext context, DeliveryProvider provider) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          _buildMenuItem(
            icon: Icons.chat_bubble_outline,
            label: 'Chats com estabelecimentos',
            onTap: () => Navigator.pushNamed(context, AppRoutes.chatList),
          ),
          const Divider(height: 1, color: Color(0xFFE0E0E0)),
          _buildMenuItem(
            icon: Icons.two_wheeler_outlined,
            label: 'Configurações do veículo',
            onTap: () =>
                Navigator.pushNamed(context, AppRoutes.vehicleSettings),
          ),
          const Divider(height: 1, color: Color(0xFFE0E0E0)),
          _buildMenuItem(
            icon: Icons.settings_outlined,
            label: 'Configurações',
            onTap: () => Navigator.pushNamed(context, AppRoutes.settings),
          ),
          const Divider(height: 1, color: Color(0xFFE0E0E0)),
          _buildMenuItem(
            icon: Icons.swap_horiz_outlined,
            label: 'Modo cliente',
            onTap: () => provider.switchToClientMode(context),
          ),
          const Divider(height: 1, color: Color(0xFFE0E0E0)),
          _buildLogoutRow(context, provider),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFF3A3A3A), size: 22),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  color: Color(0xFF1A1A1A),
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoutRow(BuildContext context, DeliveryProvider provider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: GestureDetector(
        onTap: _isLoggingOut
            ? null
            : () async {
                setState(() => _isLoggingOut = true);
                await Future.delayed(const Duration(milliseconds: 600));
                if (!mounted) return;
                provider.logout(context);
              },
        child: Row(
          children: [
            const Icon(Icons.logout, color: Color(0xFF3A3A3A), size: 22),
            const SizedBox(width: 14),
            const Expanded(
              child: Text(
                'Sair',
                style: TextStyle(
                  color: Color(0xFF1A1A1A),
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            if (_isLoggingOut)
              const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Color(0xFFC0392B),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return RichText(
      text: TextSpan(
        style: const TextStyle(fontSize: 13, color: Color(0xFF555555)),
        children: [
          TextSpan(
            text: '$label ',
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              color: Color(0xFF1A1A1A),
            ),
          ),
          TextSpan(text: value),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFFC0392B), size: 22),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    color: Color(0xFF1A1A1A),
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  label,
                  style: const TextStyle(
                    color: Color(0xFF888888),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
