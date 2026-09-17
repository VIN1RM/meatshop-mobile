import 'package:flutter/material.dart';
import 'package:meatshop_mobile/models/recipe_model.dart';
import 'package:meatshop_mobile/routes/app_routes.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:meatshop_mobile/data/repositories/marketplace_context.dart';
import 'package:provider/provider.dart';
import 'package:meatshop_mobile/models/product_model.dart';

class RecipeDetailsScreen extends StatelessWidget {
  const RecipeDetailsScreen({super.key, required this.recipe});

  final RecipeModel recipe;
  static const Color _bg = Color(0xFF2E2E2E);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _RecipeAppBar(recipe: recipe),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _TagAndTitle(recipe: recipe),
                  const SizedBox(height: 12),
                  _Description(text: recipe.description),
                  if (recipe.videoUrl.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    _VideoButton(url: recipe.videoUrl),
                  ],
                  if (recipe.featuredProduct != null) ...[
                    const SizedBox(height: 24),
                    _FeaturedProductBanner(product: recipe.featuredProduct!),
                  ],
                  const SizedBox(height: 28),
                  _SectionHeader(
                    icon: Icons.shopping_basket_outlined,
                    label: 'Ingredientes',
                  ),
                  const SizedBox(height: 12),
                  _IngredientsList(ingredients: recipe.ingredients),
                  const SizedBox(height: 28),
                  _SectionHeader(
                    icon: Icons.format_list_numbered_rounded,
                    label: 'Modo de preparo',
                  ),
                  const SizedBox(height: 12),
                  _StepsList(steps: recipe.steps),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RecipeAppBar extends StatelessWidget {
  const _RecipeAppBar({required this.recipe});

  final RecipeModel recipe;

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 280,
      pinned: true,
      backgroundColor: const Color(0xFF2E2E2E),
      leading: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.black45,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.white,
            size: 18,
          ),
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            recipe.imageUrl.isNotEmpty
                ? Image.network(
                    recipe.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => _ImageFallback(),
                  )
                : _ImageFallback(),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: const [0.5, 1.0],
                  colors: [Colors.transparent, const Color(0xFF2E2E2E)],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ImageFallback extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFF3A3A3A),
      child: const Center(
        child: Icon(Icons.restaurant_rounded, color: Colors.white24, size: 64),
      ),
    );
  }
}

class _TagAndTitle extends StatelessWidget {
  const _TagAndTitle({required this.recipe});

  final RecipeModel recipe;

  static const Color _red = Color(0xFFC0392B);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: _red.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            recipe.tag,
            style: const TextStyle(
              color: _red,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          recipe.title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.w900,
            height: 1.2,
          ),
        ),
      ],
    );
  }
}

class _Description extends StatelessWidget {
  const _Description({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(color: Colors.white60, fontSize: 14, height: 1.6),
    );
  }
}

class _VideoButton extends StatelessWidget {
  const _VideoButton({required this.url});

  final String url;

  static const Color _red = Color(0xFFC0392B);

  Future<void> _openVideo() async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _openVideo,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFF3A3A3A),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _red.withValues(alpha: 0.4)),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: _red,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.play_arrow_rounded,
                color: Colors.white,
                size: 26,
              ),
            ),
            const SizedBox(width: 14),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Dicas e Indicações',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Abre no YouTube',
                    style: TextStyle(color: Colors.white38, fontSize: 12),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.open_in_new_rounded,
              color: Colors.white38,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}

class _FeaturedProductBanner extends StatelessWidget {
  const _FeaturedProductBanner({required this.product});

  final RecipeFeaturedProduct product;

  Future<void> _navigateToProduct(BuildContext context) async {
    if (product.productId.isEmpty) return;
    try {
      final repository = context.read<MarketplaceContext>().repository;
      final results = await repository.search(product.productName, limit: 20);
      final match = results.items.where(
        (item) => item.id == product.productId && item.payload is ProductModel,
      );
      if (match.isEmpty || !context.mounted) return;
      final productModel = match.first.payload! as ProductModel;
      Navigator.pushNamed(
        context,
        AppRoutes.productDetail,
        arguments: {'product': productModel},
      );
    } catch (_) {}
  }

  static const Color _red = Color(0xFFC0392B);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [_red.withValues(alpha: 0.25), _red.withValues(alpha: 0.08)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _red.withValues(alpha: 0.35)),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: SizedBox(
              width: 56,
              height: 56,
              child: product.productImageUrl != null
                  ? Image.network(
                      product.productImageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => _productIconFallback(),
                    )
                  : _productIconFallback(),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.callToAction,
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
                const SizedBox(height: 4),
                Text(
                  product.productName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (product.price != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    'R\$ ${product.price!.toStringAsFixed(2).replaceAll('.', ',')}',
                    style: const TextStyle(
                      color: _red,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: _red,
              borderRadius: BorderRadius.circular(10),
            ),
            child: GestureDetector(
              onTap: () => _navigateToProduct(context),
              child: const Text(
                'Ver produto',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _productIconFallback() {
    return Container(
      color: const Color(0xFF4A4A4A),
      child: const Icon(
        Icons.storefront_outlined,
        color: Colors.white38,
        size: 28,
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.icon, required this.label});

  final IconData icon;
  final String label;

  static const Color _red = Color(0xFFC0392B);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 3,
          height: 18,
          decoration: BoxDecoration(
            color: _red,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 10),
        Icon(icon, color: _red, size: 20),
        const SizedBox(width: 8),
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.1,
          ),
        ),
      ],
    );
  }
}

class _IngredientsList extends StatelessWidget {
  const _IngredientsList({required this.ingredients});

  final List<RecipeIngredientModel> ingredients;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: ingredients
          .map((ing) => _IngredientTile(ingredient: ing))
          .toList(),
    );
  }
}

class _IngredientTile extends StatelessWidget {
  const _IngredientTile({required this.ingredient});

  final RecipeIngredientModel ingredient;

  static const Color _red = Color(0xFFC0392B);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF3A3A3A),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.check_circle_outline_rounded,
                color: _red,
                size: 16,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  ingredient.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFF2E2E2E),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  ingredient.quantity,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StepsList extends StatelessWidget {
  const _StepsList({required this.steps});

  final List<RecipeStepModel> steps;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        steps.length,
        (i) => _StepTile(step: steps[i], isLast: i == steps.length - 1),
      ),
    );
  }
}

class _StepTile extends StatelessWidget {
  const _StepTile({required this.step, required this.isLast});

  final RecipeStepModel step;
  final bool isLast;

  static const Color _red = Color(0xFFC0392B);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF3A3A3A),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: const BoxDecoration(
                  color: _red,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '${step.stepNumber}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              if (!isLast)
                Container(
                  width: 2,
                  height: 40,
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  decoration: BoxDecoration(
                    color: _red.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(1),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  step.description,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
                if (step.spiceTip != null) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF932215),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.white12),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.spa_outlined,
                          color: Color.fromARGB(255, 255, 255, 255),
                          size: 14,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            step.spiceTip!,
                            style: const TextStyle(
                              color: Color.fromARGB(255, 255, 255, 255),
                              fontSize: 12,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
