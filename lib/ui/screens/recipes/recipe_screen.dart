import 'package:flutter/material.dart';
import 'package:meatshop_mobile/models/recipe_model.dart';
import 'package:meatshop_mobile/providers/recipe_provider.dart';
import 'package:meatshop_mobile/routes/app_routes.dart';
import 'package:meatshop_mobile/ui/screens/recipes/recipe_details_screen.dart';
import 'package:meatshop_mobile/ui/widgets/app_header.dart';
import 'package:provider/provider.dart';

class RecipeTipsScreen extends StatefulWidget {
  const RecipeTipsScreen({super.key});

  @override
  State<RecipeTipsScreen> createState() => _RecipeTipsScreenState();
}

class _RecipeTipsScreenState extends State<RecipeTipsScreen> {
  static const Color _surface = Color(0xFF3A3A3A);
  static const Color _red = Color(0xFFC0392B);
  static const Color _white = Colors.white;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<RecipeProvider>();
      if (provider.state == RecipeLoadState.idle) {
        provider.loadAllRecipes();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RecipeProvider>();

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
                Expanded(child: _buildBody(context, provider)),
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
                      color: _red.withValues(alpha: 0.5),
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

  Widget _buildBody(BuildContext context, RecipeProvider provider) {
    switch (provider.state) {
      case RecipeLoadState.loading:
      case RecipeLoadState.idle:
        return const Center(
          child: CircularProgressIndicator(color: Color(0xFFC0392B)),
        );
      case RecipeLoadState.error:
        return Center(
          child: Text(
            provider.errorMessage ?? 'Erro ao carregar receitas.',
            style: const TextStyle(color: Colors.white70),
          ),
        );
      case RecipeLoadState.loaded:
        if (provider.recipes.isEmpty) {
          return const Center(
            child: Text(
              'Nenhuma receita disponível.',
              style: TextStyle(color: Colors.white70),
            ),
          );
        }
        return _buildList(context, provider.recipes);
    }
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

  Widget _buildList(BuildContext context, List<RecipeModel> recipes) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
      itemCount: recipes.length,
      itemBuilder: (_, i) => _buildCard(context, recipes[i]),
    );
  }

  Widget _buildCard(BuildContext context, RecipeModel recipe) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => RecipeDetailsScreen(recipe: recipe)),
      ),
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
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: recipe.imageUrl.isNotEmpty
                    ? Image.network(
                        recipe.imageUrl,
                        width: 52,
                        height: 52,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => _buildImageFallback(),
                      )
                    : _buildImageFallback(),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      recipe.title,
                      style: const TextStyle(
                        color: Color(0xFF1A1A1A),
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      recipe.description,
                      style: const TextStyle(
                        color: Color(0xFF555555),
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
                        color: _red.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        recipe.tag,
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
                color: Color(0xFFBDBDBD),
                size: 22,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageFallback() {
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        color: _red.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Icon(Icons.menu_book_rounded, color: _red, size: 28),
    );
  }
}
