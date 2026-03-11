import 'package:flutter/material.dart';
import 'package:meatshop_mobile/routes/app_routes.dart';

enum RegisterType { client, deliverer }

class SelectRegisterPage extends StatefulWidget {
  const SelectRegisterPage({super.key});

  @override
  State<SelectRegisterPage> createState() => _SelectRegisterPageState();
}

class _SelectRegisterPageState extends State<SelectRegisterPage>
    with SingleTickerProviderStateMixin {
  RegisterType? _selected;
  late AnimationController _animController;
  late Animation<double> _fadeIn;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeIn = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _onSelect(RegisterType type) {
    setState(() => _selected = type);
  }

  void _onContinue() {
    if (_selected == null) return;
    Navigator.of(context).pushNamed(AppRoutes.register, arguments: _selected);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final sw = size.width;
    final sh = size.height;

    return Scaffold(
      backgroundColor: const Color(0xFF424242),
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeIn,
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: sw * 0.06,
              vertical: sh * 0.03,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(
                    Icons.arrow_back_ios_new,
                    color: Colors.white,
                    size: 20,
                  ),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),

                SizedBox(height: sh * 0.03),

                const Text(
                  'Como deseja\nse cadastrar?',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    height: 1.3,
                  ),
                ),

                SizedBox(height: sh * 0.01),

                const Text(
                  'Escolha o perfil que melhor representa você.',
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),

                SizedBox(height: sh * 0.04),

                Expanded(
                  child: Row(
                    children: [
                      Expanded(
                        child: _TypeCard(
                          type: RegisterType.client,
                          selected: _selected == RegisterType.client,
                          title: 'Cliente',
                          description:
                              'Compre cortes frescos direto dos melhores açougues da sua região.',
                          imagePath: 'assets/images/register_client.png',
                          icon: Icons.shopping_bag_outlined,
                          onTap: () => _onSelect(RegisterType.client),
                        ),
                      ),

                      Container(
                        width: 1,
                        margin: const EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.white24,
                              Colors.white24,
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),

                      Expanded(
                        child: _TypeCard(
                          type: RegisterType.deliverer,
                          selected: _selected == RegisterType.deliverer,
                          title: 'Entregador',
                          description:
                              'Faça entregas flexíveis e ganhe dinheiro no seu próprio horário.',
                          imagePath: 'assets/images/register_deliverer.png',
                          icon: Icons.delivery_dining_outlined,
                          onTap: () => _onSelect(RegisterType.deliverer),
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: sh * 0.03),

                AnimatedOpacity(
                  opacity: _selected != null ? 1.0 : 0.35,
                  duration: const Duration(milliseconds: 300),
                  child: SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: _selected != null ? _onContinue : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFC0392B),
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: const Color(
                          0xFFC0392B,
                        ).withOpacity(0.4),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text(
                        'CONTINUAR',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                  ),
                ),

                SizedBox(height: sh * 0.015),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TypeCard extends StatelessWidget {
  final RegisterType type;
  final bool selected;
  final String title;
  final String description;
  final String imagePath;
  final IconData icon;
  final VoidCallback onTap;

  const _TypeCard({
    required this.type,
    required this.selected,
    required this.title,
    required this.description,
    required this.imagePath,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          color: selected
              ? const Color(0xFFC0392B).withOpacity(0.15)
              : const Color(0xFF525252),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? const Color(0xFFC0392B) : Colors.transparent,
            width: 2,
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                imagePath,
                height: 110,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  height: 110,
                  decoration: BoxDecoration(
                    color: const Color(0xFF3A3A3A),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: Colors.white38, size: 48),
                ),
              ),
            ),

            const SizedBox(height: 16),

            Text(
              title,
              style: TextStyle(
                color: selected ? const Color(0xFFC0392B) : Colors.white,
                fontSize: 17,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              description,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white60,
                fontSize: 12,
                height: 1.5,
              ),
            ),

            const SizedBox(height: 16),

            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: selected ? const Color(0xFFC0392B) : Colors.transparent,
                border: Border.all(
                  color: selected ? const Color(0xFFC0392B) : Colors.white38,
                  width: 2,
                ),
              ),
              child: selected
                  ? const Icon(Icons.check, color: Colors.white, size: 14)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
