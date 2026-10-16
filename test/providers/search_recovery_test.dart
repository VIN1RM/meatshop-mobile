import 'package:flutter_test/flutter_test.dart';
import 'package:meatshop_mobile/providers/search_provider.dart';
import 'package:meatshop_mobile/services/search_service.dart';
import 'package:meatshop_mobile/data/repositories/marketplace_repository.dart';
import 'package:meatshop_mobile/core/network/page.dart';
import 'package:meatshop_mobile/models/search_model.dart';

class SearchRepository extends Fake implements MarketplaceRepository {
  bool fail = true;
  @override
  Future<Page<SearchResultModel>> search(
    String query, {
    String? unitId,
    String? categoryId,
    double? minPrice,
    double? maxPrice,
    int page = 1,
    int limit = 20,
  }) async {
    if (fail) throw StateError('offline');
    return const Page(
      items: [],
      meta: PageMeta(page: 1, limit: 20, total: 0, totalPages: 0),
    );
  }
}

void main() {
  testWidgets('failed search stops loading and can retry', (tester) async {
    final repository = SearchRepository();
    final provider = SearchProvider(
      service: SearchService(marketplace: repository),
    );
    provider.onQueryChanged('carne');
    await tester.pump(const Duration(milliseconds: 401));
    expect(provider.isLoading, false);
    expect(provider.error, isNotNull);
    repository.fail = false;
    provider.onQueryChanged('carne');
    await tester.pump(const Duration(milliseconds: 401));
    expect(provider.error, isNull);
    expect(provider.isLoading, false);
    provider.dispose();
  });
}
