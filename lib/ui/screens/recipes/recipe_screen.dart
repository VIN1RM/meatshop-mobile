import 'package:flutter/material.dart';
import 'package:meatshop_mobile/models/recipe_model.dart';
import 'package:meatshop_mobile/routes/app_routes.dart';
import 'package:meatshop_mobile/ui/screens/recipes/recipe_details_screen.dart';
import 'package:meatshop_mobile/ui/widgets/app_header.dart';

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
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                const AppHeader(),
                _buildSubtitle(),
                Expanded(child: _buildList(context)),
              ],
            ),
          ),

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
            'RECEITAS DA SEMANA',
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
          color: const Color(0xFFF5F5F5),
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
                        color: const Color(0xFF1A1A1A),
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      tip.subtitle,
                      style: const TextStyle(
                        color: Color.fromARGB(255, 85, 85, 85),
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
                color: const Color(0xFFBDBDBD),

                size: 22,
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  void _showDetail(BuildContext context, _Tip tip) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => RecipeDetailsScreen(recipe: _tipToModel(tip)),
      ),
    );
  }

  RecipeModel _tipToModel(_Tip tip) {
    return RecipeModel(
      id: tip.title.toLowerCase().replaceAll(' ', '_'),
      unitId: '',
      title: tip.title,
      description: tip.subtitle,
      tag: tip.tag,
      imageUrl: '',
      videoUrl: '',
      steps: tip.steps
          .asMap()
          .entries
          .map(
            (e) => RecipeStepModel(stepNumber: e.key + 1, description: e.value),
          )
          .toList(),
      ingredients: [],
    );
  }
}
