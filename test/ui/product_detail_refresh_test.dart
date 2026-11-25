import 'package:flutter/material.dart' hide Page;
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:meatshop_mobile/core/network/page.dart';
import 'package:meatshop_mobile/data/repositories/cart_repository.dart';
import 'package:meatshop_mobile/data/repositories/marketplace_context.dart';
import 'package:meatshop_mobile/data/repositories/marketplace_repository.dart';
import 'package:meatshop_mobile/data/repositories/product_details_repository.dart';
import 'package:meatshop_mobile/models/product_model.dart';
import 'package:meatshop_mobile/models/review_model.dart';
import 'package:meatshop_mobile/providers/cart_provider.dart';
import 'package:meatshop_mobile/ui/screens/butcher/product_detail_screen.dart';

ProductModel product(String name, double price) => ProductModel(
  id: '1',
  name: name,
  description: 'Description',
  price: price,
  unitOfMeasure: 'KG',
  active: true,
  brand: '',
  imageUrl: '',
  unitId: '9',
  unitName: 'Butcher',
  categoryId: '1',
  stockQuantity: 10,
);

class _Marketplace extends Fake
    implements MarketplaceRepository, ProductDetailsRepository {
  bool fail = false;
  int requests = 0;
  @override
  Future<ProductModel> getProduct(String id) async {
    requests++;
    if (fail) throw StateError('offline');
    return product('Updated product', 65);
  }

  @override
  Future<Page<ReviewModel>> listReviews({
    String? unitId,
    String? productId,
    int page = 1,
    int limit = 20,
  }) async => const Page(
    items: [],
    meta: PageMeta(page: 1, limit: 20, total: 0, totalPages: 0),
  );
}

class _Cart extends Fake implements CartRepository {}

void main() {
  testWidgets(
    'product refresh fetches current data and keeps entered quantity after failure',
    (tester) async {
      final repository = _Marketplace();
      final cart = CartProvider(uid: '1', repository: _Cart());
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            Provider.value(value: MarketplaceContext(repository)),
            ChangeNotifierProvider.value(value: cart),
          ],
          child: MaterialApp(
            onGenerateRoute: (_) => MaterialPageRoute(
              settings: RouteSettings(
                arguments: product('Original product', 50),
              ),
              builder: (_) => const ProductDetailScreen(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), '0.75');
      final refresh = tester.widget<RefreshIndicator>(
        find.byType(RefreshIndicator),
      );
      await refresh.onRefresh();
      await tester.pumpAndSettle();
      expect(repository.requests, 1);
      expect(find.text('Updated product'), findsOneWidget);
      expect(
        tester.widget<TextField>(find.byType(TextField)).controller!.text,
        '0.75',
      );
      repository.fail = true;
      await refresh.onRefresh();
      await tester.pumpAndSettle();
      expect(find.text('Updated product'), findsOneWidget);
      expect(
        tester.widget<TextField>(find.byType(TextField)).controller!.text,
        '0.75',
      );
      expect(find.text('Tentar novamente'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
      cart.dispose();
    },
  );
}
