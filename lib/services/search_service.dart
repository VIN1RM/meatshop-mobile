import 'package:meatshop_mobile/models/search_model.dart';
import '../data/repositories/marketplace_repository.dart';

class SearchService {
  SearchService({required MarketplaceRepository marketplace})
    : _marketplace = marketplace;
  final MarketplaceRepository _marketplace;

  Future<List<SearchResultModel>> search(String query) async {
    if (query.trim().isEmpty) return [];
    return (await _marketplace.search(query.trim())).items;
  }
}
