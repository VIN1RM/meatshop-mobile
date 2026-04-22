import 'package:flutter/material.dart';
import 'package:meatshop_mobile/routes/app_routes.dart';

class _Tip {
  final String title;
  final String subtitle;
  final String tag;
  final IconData icon;
  final List<String> steps;
  const _Tip({
    required this.title,
    required this.subtitle,
    required this.tag,
    required this.icon,
    required this.steps,
  });
}

class RecipeTipsScreen extends StatelessWidget {
  const RecipeTipsScreen({super.key});

  static const Color _surface = Color(0xFF3A3A3A);
  static const Color _red = Color(0xFFC0392B);
  static const Color _white = Colors.white;
  static const Color _cardDark = Color(0xFF4A4A4A);

  static const List<_Tip> _tips = [
    _Tip(
      title: 'Picanha na brasa',
      subtitle: 'O segredo do churrasco perfeito',
      tag: 'Bovino',
      icon: Icons.local_fire_department_rounded,
      steps: [
        'Deixe a carne em temperatura ambiente por 30 min antes de grelhar.',
        'Tempere apenas com sal grosso — não exagere.',
        'Grelhe com a gordura para baixo primeiro por 5 min.',
        'Vire e finalize por mais 4 min para ponto mal passado.',
        'Deixe descansar 3 min antes de fatiar.',
      ],
    ),
    _Tip(
      title: 'Frango suculento',
      subtitle: 'Como não ressecar o peito de frango',
      tag: 'Frango',
      icon: Icons.water_drop_rounded,
      steps: [
        'Faça uma salmoura: água + sal + açúcar por 30 min.',
        'Seque bem antes de temperar.',
        'Use fogo médio, nunca alto.',
        'Cubra a frigideira nos últimos 2 min.',
        'Corte sempre contra a fibra.',
      ],
    ),
    _Tip(
      title: 'Costela no forno',
      subtitle: 'Macia e soltando do osso',
      tag: 'Bovino',
      icon: Icons.timer_rounded,
      steps: [
        'Tempere na véspera com alho, sal e pimenta.',
        'Embrulhe em papel alumínio bem vedado.',
        'Asse a 160°C por 4 horas.',
        'Retire o papel e aumente para 220°C por 20 min.',
        'Sirva com farofa e vinagrete.',
      ],
    ),
    _Tip(
      title: 'Lombo suíno',
      subtitle: 'Macio por dentro, dourado por fora',
      tag: 'Suíno',
      icon: Icons.star_rounded,
      steps: [
        'Marine com laranja, alho e azeite por 2h.',
        'Sele em fogo alto por todos os lados.',
        'Finalize no forno a 180°C por 25 min.',
        'Use o caldo da marinada para regar.',
        'Deixe descansar 5 min antes de fatiar.',
      ],
    ),
    _Tip(
      title: 'Salmão grelhado',
      subtitle: 'Rápido, saudável e saboroso',
      tag: 'Peixe',
      icon: Icons.set_meal_rounded,
      steps: [
        'Seque o filé com papel toalha.',
        'Tempere com limão, sal e endro.',
        'Grelhe com a pele para baixo por 4 min.',
        'Vire apenas uma vez e cozinhe por 2 min.',
        'Sirva imediatamente com legumes.',
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2A2A2A),
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
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                _buildHeader(context),
                _buildSubtitle(),
                Expanded(child: _buildList(context)),
              ],
            ),
          ),
          // FAB chatbot
          Positioned(
            bottom: 24,
            right: 20,
            child: GestureDetector(
              onTap: () => Navigator.pushNamed(context, AppRoutes.recipeChat),
              child: Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: _red,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: _red.withOpacity(0.5),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.smart_toy_rounded,
                  color: _white,
                  size: 26,
                ),
              ),
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

  Widget _buildSubtitle() {
    return Container(
      width: double.infinity,
      color: _surface,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: const Row(
        children: [
          Icon(Icons.menu_book_rounded, color: _red, size: 20),
          SizedBox(width: 8),
          Text(
            'DICAS DE RECEITAS',
            style: TextStyle(
              color: _white,
              fontSize: 13,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildList(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
      itemCount: _tips.length,
      itemBuilder: (_, i) => _buildCard(context, _tips[i]),
    );
  }

  Widget _buildCard(BuildContext context, _Tip tip) {
    return GestureDetector(
      onTap: () => _showDetail(context, tip),
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: _cardDark,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: _red.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(tip.icon, color: _red, size: 28),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tip.title,
                      style: const TextStyle(
                        color: _white,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      tip.subtitle,
                      style: const TextStyle(
                        color: Colors.white54,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: _red.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        tip.tag,
                        style: const TextStyle(
                          color: _red,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: Colors.white38,
                size: 22,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDetail(BuildContext context, _Tip tip) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _TipDetailSheet(tip: tip),
    );
  }
}

class _TipDetailSheet extends StatelessWidget {
  final _Tip tip;
  const _TipDetailSheet({required this.tip});

  static const Color _red = Color(0xFFC0392B);
  static const Color _white = Colors.white;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 60),
      decoration: const BoxDecoration(
        color: Color(0xFF3A3A3A),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: _red.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(tip.icon, color: _red, size: 26),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tip.title,
                        style: const TextStyle(
                          color: _white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        tip.subtitle,
                        style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const Divider(color: Colors.white12),
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
              itemCount: tip.steps.length,
              itemBuilder: (_, i) => Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 26,
                      height: 26,
                      margin: const EdgeInsets.only(right: 12, top: 1),
                      decoration: const BoxDecoration(
                        color: _red,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '${i + 1}',
                          style: const TextStyle(
                            color: _white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        tip.steps[i],
                        style: const TextStyle(
                          color: _white,
                          fontSize: 14,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
