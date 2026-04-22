import 'package:flutter/material.dart';
import 'package:meatshop_mobile/routes/app_routes.dart';
import 'package:meatshop_mobile/services/version_service.dart';
import 'package:meatshop_mobile/ui/dialogs/release_notes_dialog.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  static const Color _red = Color(0xFFC0392B);
  static const Color _white = Colors.white;

  bool _notifOrders = true;
  bool _notifDelivery = true;
  bool _notifPromotions = false;
  bool _notifSystem = true;
  String _appVersion = '...';

  @override
  void initState() {
    super.initState();
    VersionService().getAppVersion().then((v) {
      if (mounted) setState(() => _appVersion = 'v$v');
    });
  }

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
                        const SizedBox(height: 20),
                        _sectionLabel('NOTIFICAÇÕES'),
                        const SizedBox(height: 10),
                        _buildCard(
                          children: [
                            _buildToggle(
                              icon: Icons.receipt_long_outlined,
                              label: 'Pedidos',
                              subtitle: 'Atualizações sobre seus pedidos',
                              value: _notifOrders,
                              onChanged: (v) =>
                                  setState(() => _notifOrders = v),
                            ),
                            _divider(),
                            _buildToggle(
                              icon: Icons.delivery_dining_outlined,
                              label: 'Entrega',
                              subtitle: 'Status do entregador em tempo real',
                              value: _notifDelivery,
                              onChanged: (v) =>
                                  setState(() => _notifDelivery = v),
                            ),
                            _divider(),
                            _buildToggle(
                              icon: Icons.local_offer_outlined,
                              label: 'Promoções',
                              subtitle: 'Ofertas e descontos exclusivos',
                              value: _notifPromotions,
                              onChanged: (v) =>
                                  setState(() => _notifPromotions = v),
                            ),
                            _divider(),
                            _buildToggle(
                              icon: Icons.info_outline,
                              label: 'Sistema',
                              subtitle: 'Avisos importantes do aplicativo',
                              value: _notifSystem,
                              onChanged: (v) =>
                                  setState(() => _notifSystem = v),
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        _sectionLabel('CONTA'),
                        const SizedBox(height: 10),
                        _buildCard(
                          children: [
                            _buildNavItem(
                              icon: Icons.lock_outline,
                              label: 'Alterar senha',
                              onTap: () => Navigator.pushNamed(
                                context,
                                AppRoutes.changePassword,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        _sectionLabel('SOBRE'),
                        const SizedBox(height: 10),
                        _buildCard(
                          children: [
                            _buildNavItem(
                              icon: Icons.description_outlined,
                              label: 'Termos de uso',
                              onTap: () {},
                            ),
                            _divider(),
                            _buildNavItem(
                              icon: Icons.privacy_tip_outlined,
                              label: 'Política de privacidade',
                              onTap: () {},
                            ),
                            _divider(),
                            _buildNavItem(
                              icon: Icons.info_outline,
                              label: 'Versão do app',
                              trailing: Text(
                                _appVersion,
                                style: const TextStyle(
                                  color: Color(0xFF9E9E9E),
                                  fontSize: 13,
                                ),
                              ),
                              onTap: () {
                                final version = _appVersion.replaceFirst(
                                  'v',
                                  '',
                                );
                                ReleaseNotesDialog.show(context, version);
                              },
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        _sectionLabel('GERENCIAMENTO DE CONTA'),
                        const SizedBox(height: 10),
                        _buildCard(
                          children: [
                            _buildNavItem(
                              icon: Icons.delete_outline,
                              label: 'Excluir minha conta',
                              labelColor: _red,
                              iconColor: _red,
                              onTap: () => _showDeleteAccountDialog(context),
                            ),
                          ],
                        ),

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
        'CONFIGURAÇÕES',
        style: TextStyle(
          color: _red,
          fontSize: 22,
          fontWeight: FontWeight.w900,
          letterSpacing: 1.2,
        ),
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

  Widget _buildCard({required List<Widget> children}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(children: children),
    );
  }

  Widget _divider() =>
      const Divider(height: 1, color: Color(0xFFE0E0E0), indent: 16);

  Widget _buildToggle({
    required IconData icon,
    required String label,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF3A3A3A), size: 22),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: Color(0xFF1A1A1A),
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Color(0xFF9E9E9E),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Switch(value: value, onChanged: onChanged, activeColor: _red),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Widget? trailing,
    Color? labelColor,
    Color? iconColor,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Row(
          children: [
            Icon(icon, color: iconColor ?? const Color(0xFF3A3A3A), size: 22),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: labelColor ?? const Color(0xFF1A1A1A),
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            trailing ??
                const Icon(
                  Icons.chevron_right,
                  color: Color(0xFFBDBDBD),
                  size: 20,
                ),
          ],
        ),
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Excluir conta',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'Tem certeza que deseja excluir sua conta? Essa ação não pode ser desfeita.',
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
              'Excluir',
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
