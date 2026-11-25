import 'package:flutter/material.dart';
import '../../../data/repositories/marketplace_repository.dart';
import '../../../models/category_model.dart';
import '../../../services/category_service.dart';
import '../../widgets/app_surface.dart';
import '../../widgets/buttons_widget.dart';

const categoryGroupLabels = {
  'BEEF': 'Bovinos',
  'PORK': 'Suínos',
  'POULTRY': 'Aves',
  'FISH': 'Peixes',
};

String categorySearchKey(String value) {
  var result = value.trim().toLowerCase();
  const accents = {
    'á': 'a',
    'à': 'a',
    'â': 'a',
    'ã': 'a',
    'é': 'e',
    'ê': 'e',
    'í': 'i',
    'ó': 'o',
    'ô': 'o',
    'õ': 'o',
    'ú': 'u',
    'ü': 'u',
    'ç': 'c',
  };
  accents.forEach((from, to) => result = result.replaceAll(from, to));
  return result;
}

class CategoryChoice {
  const CategoryChoice({
    required this.name,
    required this.group,
    required this.ids,
    required this.unitCount,
  });
  final String name;
  final String group;
  final List<String> ids;
  final int unitCount;
  bool matches(String query) => categorySearchKey(
    '$name ${categoryGroupLabels[group] ?? ''}',
  ).contains(categorySearchKey(query));
}

List<CategoryChoice> categoryChoices(List<CategoryModel> categories) {
  final buckets = <String, List<CategoryModel>>{};
  for (final category in categories) {
    if (!category.active || category.name.trim().isEmpty) continue;
    final group =
        category.group ??
        CategoryService.groupForName(category.name) ??
        'OTHER';
    final key = '$group:${categorySearchKey(category.name)}';
    buckets.putIfAbsent(key, () => []).add(category);
  }
  return buckets.values
      .map(
        (items) => CategoryChoice(
          name: items.first.name.trim(),
          group:
              items.first.group ??
              CategoryService.groupForName(items.first.name) ??
              'OTHER',
          ids: List.unmodifiable(items.map((item) => item.id).toSet()),
          unitCount: items.map((item) => item.unitId).toSet().length,
        ),
      )
      .toList()
    ..sort(
      (a, b) => categorySearchKey(a.name).compareTo(categorySearchKey(b.name)),
    );
}

class CategoryBrowserSheet extends StatefulWidget {
  const CategoryBrowserSheet({super.key, required this.repository});
  final MarketplaceRepository repository;
  static Future<CategoryChoice?> show(
    BuildContext context,
    MarketplaceRepository repository,
  ) => showModalBottomSheet<CategoryChoice>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    builder: (context) => Theme(
      data: appSurfaceTheme(context),
      child: CategoryBrowserSheet(repository: repository),
    ),
  );
  @override
  State<CategoryBrowserSheet> createState() => _CategoryBrowserSheetState();
}

class _CategoryBrowserSheetState extends State<CategoryBrowserSheet> {
  late Future<List<CategoryModel>> _categories = widget.repository
      .listCategories();
  final _search = TextEditingController();
  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    final available =
        (media.size.height - media.viewInsets.bottom - media.padding.top).clamp(
          0.0,
          media.size.height,
        );
    return Padding(
      padding: EdgeInsets.only(bottom: media.viewInsets.bottom),
      child: SizedBox(
        height: (media.size.height * .82).clamp(0.0, available).toDouble(),
        child: Material(
          color: const Color(0xFFF7F7F7),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          clipBehavior: Clip.antiAlias,
          child: SafeArea(
            top: false,
            child: Column(
              children: [
                const SizedBox(height: 12),
                Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.black12,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 8, 4),
                  child: Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Todas as categorias',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: AppColors.dark,
                          ),
                        ),
                      ),
                      IconButton(
                        tooltip: 'Fechar categorias',
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close_rounded),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
                  child: TextField(
                    controller: _search,
                    onChanged: (_) => setState(() {}),
                    textInputAction: TextInputAction.search,
                    decoration: InputDecoration(
                      hintText: 'Buscar categoria',
                      prefixIcon: const Icon(Icons.search_rounded),
                      suffixIcon: _search.text.isEmpty
                          ? null
                          : IconButton(
                              tooltip: 'Limpar busca',
                              onPressed: () => setState(_search.clear),
                              icon: const Icon(Icons.close_rounded),
                            ),
                    ),
                  ),
                ),
                Expanded(
                  child: FutureBuilder<List<CategoryModel>>(
                    future: _categories,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState != ConnectionState.done) {
                        return const Center(
                          child: CircularProgressIndicator(
                            color: AppColors.redPrimary,
                          ),
                        );
                      }
                      if (snapshot.hasError) {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.cloud_off_rounded,
                                  size: 32,
                                  color: Colors.grey,
                                ),
                                const SizedBox(height: 12),
                                const Text(
                                  'Não foi possível carregar as categorias.',
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 12),
                                OutlinedButton(
                                  onPressed: () => setState(() {
                                    _categories = widget.repository
                                        .listCategories();
                                  }),
                                  child: const Text('Tentar novamente'),
                                ),
                              ],
                            ),
                          ),
                        );
                      }
                      final all = categoryChoices(snapshot.data ?? []);
                      final visible = all
                          .where((entry) => entry.matches(_search.text))
                          .toList();
                      if (visible.isEmpty) {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.category_outlined,
                                  size: 36,
                                  color: Colors.grey,
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  all.isEmpty
                                      ? 'Nenhuma categoria disponível no momento.'
                                      : 'Nenhuma categoria encontrada.',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: Color(0xFF666666),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }
                      return ListView.separated(
                        keyboardDismissBehavior:
                            ScrollViewKeyboardDismissBehavior.onDrag,
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                        itemCount: visible.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final category = visible[index];
                          final group = categoryGroupLabels[category.group];
                          final count = category.unitCount == 1
                              ? '1 açougue'
                              : '${category.unitCount} açougues';
                          return Material(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            child: ListTile(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              leading: Container(
                                width: 42,
                                height: 42,
                                decoration: BoxDecoration(
                                  color: AppColors.redPrimary.withValues(
                                    alpha: .08,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.category_outlined,
                                  color: AppColors.redPrimary,
                                  size: 22,
                                ),
                              ),
                              title: Text(
                                category.name,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.dark,
                                ),
                              ),
                              subtitle: Text(
                                group == null ? count : '$group · $count',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF777777),
                                ),
                              ),
                              trailing: const Icon(
                                Icons.chevron_right_rounded,
                                color: Color(0xFF999999),
                              ),
                              onTap: () => Navigator.pop(context, category),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
