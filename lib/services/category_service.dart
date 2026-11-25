import '../data/repositories/marketplace_repository.dart';

class CategoryService {
  CategoryService({required MarketplaceRepository marketplace})
    : _marketplace = marketplace;
  final MarketplaceRepository _marketplace;

  // Name inference is only a fallback for servers predating category groups.
  static String? groupForName(String name) {
    var words = name.trim().toLowerCase();
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
    accents.forEach((from, to) => words = words.replaceAll(from, to));
    if (words == 'outros' || words == 'outras categorias') return 'OTHER';
    final patterns = {
      'BEEF': r'\b(bovinos?|bovinas?|beef)\b',
      'PORK': r'\b(suinos?|suinas?|porcos?|pork)\b',
      'POULTRY': r'\b(aves?|frangos?|galinhas?|poultry)\b',
      'FISH': r'\b(peixes?|pescados?|fish)\b',
    };
    final matches = patterns.entries
        .where((entry) => RegExp(entry.value).hasMatch(words))
        .toList();
    return matches.length == 1 ? matches.single.key : null;
  }

  Future<List<String>> fetchCategoryIdsByGroup(String group) async {
    final categories = await _marketplace.listCategories();
    return categories
        .where(
          (item) =>
              item.active &&
              (item.group ?? groupForName(item.name) ?? 'OTHER') == group,
        )
        .map((item) => item.id)
        .toList();
  }

  Future<List<String>> fetchCategoryIdsByName(String name) async {
    final categories = await _marketplace.listCategories();
    return categories
        .where(
          (item) =>
              item.active &&
              (groupForName(name) != null
                  ? (item.group ?? groupForName(item.name) ?? 'OTHER') ==
                        groupForName(name)
                  : item.name.trim().toLowerCase() ==
                        name.trim().toLowerCase()),
        )
        .map((item) => item.id)
        .toList();
  }
}
