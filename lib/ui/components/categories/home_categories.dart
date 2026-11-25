import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/repositories/marketplace_context.dart';
import '../../../routes/app_routes.dart';
import '../../screens/cuts/cuts_screen.dart';
import 'category_browser_sheet.dart';

class HomeCategories extends StatelessWidget {
  const HomeCategories({super.key});
  static const _shortcuts = [
    (name: 'Bovinos', image: 'vaca', route: AppRoutes.beefCuts),
    (name: 'Suínos', image: 'porco', route: AppRoutes.porkCuts),
    (name: 'Aves', image: 'frango', route: AppRoutes.poultryCuts),
    (name: 'Peixes', image: 'peixe', route: AppRoutes.fishCuts),
  ];

  Future<void> _openAll(BuildContext context) async {
    final repository = context.read<MarketplaceContext>().repository;
    final category = await CategoryBrowserSheet.show(context, repository);
    if (!context.mounted || category == null) return;
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => CutsScreen(
          title: category.name.toUpperCase(),
          categoryName: category.name,
          categoryIds: category.ids,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: double.infinity,
          child: Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 12,
            children: [
              const Text(
                'CATEGORIAS',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.2,
                ),
              ),
              TextButton(
                onPressed: () => _openAll(context),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  minimumSize: const Size(0, 44),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Ver todas',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(width: 2),
                    Icon(Icons.chevron_right_rounded, size: 18),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        LayoutBuilder(
          builder: (context, constraints) {
            final columns = MediaQuery.textScalerOf(context).scale(12) > 16
                ? 2
                : 4;
            final width = (constraints.maxWidth - 8 * (columns - 1)) / columns;
            return Wrap(
              spacing: 8,
              runSpacing: 14,
              children: _shortcuts
                  .map(
                    (category) => SizedBox(
                      width: width,
                      child: Semantics(
                        button: true,
                        label: 'Ver categoria ${category.name}',
                        excludeSemantics: true,
                        child: InkWell(
                          onTap: () =>
                              Navigator.pushNamed(context, category.route),
                          borderRadius: BorderRadius.circular(14),
                          child: Column(
                            children: [
                              AspectRatio(
                                aspectRatio: 1.05,
                                child: DecoratedBox(
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFE0E0E0),
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(14),
                                    child: Image.asset(
                                      'assets/images/${category.image}.png',
                                      fit: BoxFit.contain,
                                      errorBuilder: (_, _, _) => const Icon(
                                        Icons.category_outlined,
                                        color: Color(0xFF3A3A3A),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                category.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  )
                  .toList(),
            );
          },
        ),
      ],
    ),
  );
}
