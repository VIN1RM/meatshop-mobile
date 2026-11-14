import 'package:meatshop_mobile/ui/screens/butcher/butcher_catalog_controls.dart';
import 'dart:async';
import 'package:flutter/material.dart' hide Page;
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:meatshop_mobile/core/network/page.dart';
import 'package:meatshop_mobile/data/repositories/marketplace_context.dart';
import 'package:meatshop_mobile/data/repositories/marketplace_repository.dart';
import 'package:meatshop_mobile/data/repositories/cart_repository.dart';
import 'package:meatshop_mobile/models/product_model.dart';
import 'package:meatshop_mobile/models/category_model.dart';
import 'package:meatshop_mobile/models/promotion_model.dart';
import 'package:meatshop_mobile/models/business_hours_model.dart';
import 'package:meatshop_mobile/models/review_model.dart';
import 'package:meatshop_mobile/models/unit_model.dart';
import 'package:meatshop_mobile/providers/cart_provider.dart';
import 'package:meatshop_mobile/providers/unit/butcher_provider.dart';
import 'package:meatshop_mobile/services/product_service.dart';
import 'package:meatshop_mobile/services/promotion_service.dart';
import 'package:meatshop_mobile/services/review_service.dart';
import 'package:meatshop_mobile/services/business_hours_service.dart';
import 'package:meatshop_mobile/ui/screens/butcher/butcher_detail_screen.dart';

ProductModel product(
  String id,
  String name,
  String category,
  double price, {
  String brand = 'Nobre',
}) => ProductModel(
  id: id,
  name: name,
  description: '',
  price: price,
  unitOfMeasure: 'kg',
  active: true,
  brand: brand,
  imageUrl: '',
  unitId: '9',
  unitName: 'Vila Nobre',
  categoryId: category,
  stockQuantity: 10,
);

class CatalogFixture extends Fake implements MarketplaceRepository {
  final calls = <int>[];
  bool failProducts = false;
  bool failCategories = false;
  Completer<Page<ReviewModel>>? pendingReviews;
  List<ProductModel> products = [
    product('1', 'Picanha Angus', 'beef', 79.9),
    product('2', 'Alcatra', 'beef', 44.9),
    product('3', 'Linguiça de pernil', 'pork', 29.9, brand: 'Da casa'),
    product('4', 'Costelinha suína', 'pork', 39.9),
  ];
  @override
  Future<Page<ProductModel>> listProducts({
    String? unitId,
    String? categoryId,
    int page = 1,
    int limit = 10,
  }) async {
    calls.add(page);
    if (failProducts) throw StateError('Offline');
    final offset = (page - 1) * 2;
    return Page(
      items: products.skip(offset).take(2).toList(),
      meta: PageMeta(
        page: page,
        limit: 2,
        total: products.length,
        totalPages: (products.length / 2).ceil(),
      ),
    );
  }

  @override
  Future<List<CategoryModel>> listCategories({String? unitId}) async {
    if (failCategories) throw StateError('Offline');
    return [
      for (final entry in {
        'beef': 'Bovinos',
        'pork': 'Suínos',
        'birds': 'Aves',
      }.entries)
        CategoryModel(
          id: entry.key,
          name: entry.value,
          description: '',
          active: true,
          unitId: '9',
        ),
    ];
  }

  @override
  Future<Page<PromotionModel>> listPromotions({
    String? unitId,
    int page = 1,
    int limit = 10,
  }) async => const Page(
    items: [],
    meta: PageMeta(page: 1, limit: 10, total: 0, totalPages: 0),
  );
  @override
  Future<List<BusinessHoursModel>> listBusinessHours(String unitId) async => [];
  @override
  Future<Page<ReviewModel>> listReviews({
    String? unitId,
    String? productId,
    int page = 1,
    int limit = 20,
  }) async =>
      pendingReviews?.future ??
      const Page(
        items: [],
        meta: PageMeta(page: 1, limit: 20, total: 0, totalPages: 0),
      );
}

class _CartRepository extends Fake implements CartRepository {}

ButcherProvider catalogProvider(CatalogFixture fixture) => ButcherProvider(
  unitId: '9',
  productService: ProductService(marketplace: fixture),
  promotionService: PromotionService(marketplace: fixture),
  reviewService: ReviewService(marketplace: fixture),
  hoursService: BusinessHoursService(marketplace: fixture),
);
Widget catalogApp(
  CatalogFixture fixture, {
  bool photos = false,
  double scale = 1,
}) => MultiProvider(
  providers: [
    Provider.value(value: MarketplaceContext(fixture)),
    ChangeNotifierProvider(
      create: (_) => CartProvider(uid: '1', repository: _CartRepository()),
    ),
  ],
  child: MaterialApp(
    builder: (context, child) => MediaQuery(
      data: MediaQuery.of(
        context,
      ).copyWith(textScaler: TextScaler.linear(scale)),
      child: child!,
    ),
    onGenerateRoute: (settings) => MaterialPageRoute(
      settings: RouteSettings(
        arguments: UnitModel(
          id: '9',
          name: 'Açougue Vila Nobre',
          cnpj: '',
          street: '',
          number: '',
          neighborhood: '',
          city: '',
          state: '',
          zipCode: '',
          adminId: '1',
          imageUrl: '',
          galleryUrls: photos ? ['https://example.com/shop.jpg'] : [],
          createdAt: DateTime(2026),
        ),
      ),
      builder: (_) => const ButcherDetailScreen(),
    ),
  ),
);

void main() {
  testWidgets(
    'filter actions remain reachable with a keyboard and larger text on a small screen',
    (tester) async {
      tester.view.physicalSize = const Size(320, 480);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final provider = catalogProvider(CatalogFixture());
      await provider.loadProducts();
      await tester.pumpWidget(
        ChangeNotifierProvider<ButcherProvider>.value(
          value: provider,
          child: MaterialApp(
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(context).copyWith(
                textScaler: TextScaler.linear(1.5),
                viewInsets: const EdgeInsets.only(bottom: 180),
              ),
              child: child!,
            ),
            home: const Scaffold(
              body: SingleChildScrollView(child: ButcherCatalogControls()),
            ),
          ),
        ),
      );
      await tester.tap(find.widgetWithIcon(OutlinedButton, Icons.tune));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.byType(TextFormField));
      await tester.enterText(find.byType(TextFormField), '50,00');
      await tester.ensureVisible(find.text('Aplicar filtros'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Aplicar filtros'));
      await tester.pumpAndSettle();
      expect(provider.maxPriceFilter, 50);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
      provider.dispose();
    },
  );

  test(
    'loads every page before exposing the catalog and combines category, brand, name and price filters',
    () async {
      final fixture = CatalogFixture()..pendingReviews = Completer();
      final provider = catalogProvider(fixture);
      final loading = provider.loadProducts();
      await Future<void>.delayed(Duration.zero);
      expect(provider.isLoading, isTrue);
      expect(provider.items, isEmpty);
      fixture.pendingReviews!.complete(
        const Page(
          items: [],
          meta: PageMeta(page: 1, limit: 3, total: 0, totalPages: 0),
        ),
      );
      await loading;
      expect(fixture.calls, [1, 2]);
      expect(provider.items, hasLength(4));
      expect(provider.groupedProducts.keys, ['Bovinos', 'Suínos']);
      expect(
        provider.categories.map((category) => category.name),
        isNot(contains('Aves')),
      );
      await provider.applyFilters(
        name: 'linguica',
        brand: 'Da casa',
        category: 'pork',
        maxPrice: 30,
      );
      expect(provider.items.single.id, '3');
      expect(fixture.calls, [1, 2]);
      await provider.applyFilters();
      expect(provider.items, hasLength(4));
      provider.dispose();
    },
  );
  test(
    'keeps products usable when category metadata fails and distinguishes a catalog load failure',
    () async {
      final fixture = CatalogFixture()..failCategories = true;
      final provider = catalogProvider(fixture);
      await provider.loadProducts();
      expect(provider.error, isNull);
      expect(provider.warning, isNotNull);
      expect(provider.groupedProducts['Outros produtos'], hasLength(4));
      fixture.failProducts = true;
      await provider.loadProducts();
      expect(provider.error, isNotNull);
      fixture.failProducts = false;
      fixture.failCategories = false;
      await provider.loadProducts();
      expect(provider.error, isNull);
      expect(provider.warning, isNull);
      provider.dispose();
    },
  );
  testWidgets(
    'waits for the complete snapshot and removes empty promotions, reviews and their dividers',
    (tester) async {
      final fixture = CatalogFixture()..pendingReviews = Completer();
      await tester.pumpWidget(catalogApp(fixture));
      await tester.pump();
      expect(find.byType(Shimmer), findsOneWidget);
      expect(find.text('Alcatra'), findsNothing);
      fixture.pendingReviews!.complete(
        const Page(
          items: [],
          meta: PageMeta(page: 1, limit: 3, total: 0, totalPages: 0),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Alcatra'), findsOneWidget);
      expect(find.text('Costelinha suína'), findsOneWidget);
      expect(find.text('Promoções'), findsNothing);
      expect(find.text('Avaliações dos Clientes'), findsNothing);
      expect(find.byType(Divider), findsNothing);
      expect(find.text('Aves'), findsNothing);
      await tester.pumpWidget(const SizedBox());
    },
  );
  testWidgets('omits the entire product section when the unit has no catalog', (
    tester,
  ) async {
    await tester.pumpWidget(catalogApp(CatalogFixture()..products = []));
    await tester.pumpAndSettle();
    expect(find.text('Produtos'), findsNothing);
    expect(find.byType(TextField), findsNothing);
    expect(find.byType(Divider), findsNothing);
    await tester.pumpWidget(const SizedBox());
  });
  testWidgets(
    'filters by category, searches with spaces, validates price inline and restores the catalog',
    (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final fixture = CatalogFixture();
      await tester.pumpWidget(catalogApp(fixture));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.widgetWithText(ChoiceChip, 'Suínos'));
      await tester.tap(find.widgetWithText(ChoiceChip, 'Suínos'));
      await tester.pumpAndSettle();
      expect(find.text('Alcatra'), findsNothing);
      expect(find.text('Linguiça de pernil'), findsOneWidget);
      await tester.enterText(find.byType(TextField).first, 'Linguiça ');
      await tester.pump();
      expect(
        tester.widget<TextField>(find.byType(TextField).first).controller!.text,
        'Linguiça ',
      );
      await tester.tap(find.widgetWithIcon(OutlinedButton, Icons.tune));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextFormField), '-5');
      await tester.ensureVisible(find.text('Aplicar filtros'));
      await tester.tap(find.text('Aplicar filtros'));
      await tester.pumpAndSettle();
      expect(find.text('Informe um preço válido.'), findsOneWidget);
      await tester.enterText(find.byType(TextFormField), '30,00');
      await tester.ensureVisible(find.text('Aplicar filtros'));
      await tester.tap(find.text('Aplicar filtros'));
      await tester.pumpAndSettle();
      expect(find.text('Filtrar produtos'), findsNothing);
      expect(find.text('Linguiça de pernil'), findsOneWidget);
      await tester.enterText(find.byType(TextField).first, 'inexistente');
      await tester.pumpAndSettle();
      expect(find.text('Nenhum produto encontrado'), findsOneWidget);
      await tester.ensureVisible(find.text('Limpar filtros').first);
      await tester.tap(find.text('Limpar filtros').first);
      await tester.pumpAndSettle();
      expect(find.text('Alcatra'), findsOneWidget);
      expect(fixture.calls, [1, 2]);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
    },
  );
  testWidgets(
    'centers the gallery action and keeps product cards readable with larger text',
    (tester) async {
      tester.view.physicalSize = const Size(320, 700);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        catalogApp(CatalogFixture(), photos: true, scale: 1.6),
      );
      await tester.pumpAndSettle();
      final button = find.widgetWithIcon(
        FilledButton,
        Icons.photo_library_outlined,
      );
      expect((tester.getCenter(button).dx - 160).abs(), lessThan(1));
      await tester.scrollUntilVisible(
        find.text('Costelinha suína'),
        180,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
    },
  );
}
