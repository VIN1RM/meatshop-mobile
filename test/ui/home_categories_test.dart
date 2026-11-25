import 'package:flutter/material.dart' hide Page;
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:meatshop_mobile/core/network/page.dart';
import 'package:meatshop_mobile/data/repositories/marketplace_context.dart';
import 'package:meatshop_mobile/data/repositories/marketplace_repository.dart';
import 'package:meatshop_mobile/models/category_model.dart';
import 'package:meatshop_mobile/models/product_model.dart';
import 'package:meatshop_mobile/routes/app_routes.dart';
import 'package:meatshop_mobile/ui/components/categories/home_categories.dart';
import 'package:meatshop_mobile/ui/components/categories/category_browser_sheet.dart';
import 'package:meatshop_mobile/ui/screens/cuts/cuts_screen.dart';

CategoryModel category(
  String id,
  String name,
  String unit, {
  String group = 'OTHER',
  bool active = true,
}) => CategoryModel(
  id: id,
  name: name,
  description: '',
  unitId: unit,
  group: group,
  active: active,
);

class Repository extends Fake implements MarketplaceRepository {
  bool fail = false;
  int categoryCalls = 0;
  List<CategoryModel> categories = [
    category('1', 'Embutidos', '1'),
    category('2', 'Embutidos', '2'),
    category('3', 'Cortes suínos', '1', group: 'PORK'),
  ];
  final requested = <String?>[];
  @override
  Future<List<CategoryModel>> listCategories({String? unitId}) async {
    categoryCalls++;
    if (fail) throw Exception('offline');
    return categories;
  }

  @override
  Future<Page<ProductModel>> listProducts({
    String? unitId,
    String? categoryId,
    int page = 1,
    int limit = 10,
  }) async {
    requested.add(categoryId);
    return const Page(
      items: [],
      meta: PageMeta(page: 1, limit: 10, total: 0, totalPages: 1),
    );
  }
}

void main() {
  late Repository repository;
  setUp(() => repository = Repository());
  Future<void> open(WidgetTester tester, {double scale = 1}) async {
    await tester.pumpWidget(
      Provider<MarketplaceContext>.value(
        value: MarketplaceContext(repository),
        child: MaterialApp(
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: TextScaler.linear(scale)),
            child: child!,
          ),
          routes: {
            AppRoutes.beefCuts: (_) =>
                const Scaffold(body: Text('Grupo Bovinos')),
          },
          home: const Scaffold(
            backgroundColor: Color(0xFF2E2E2E),
            body: SafeArea(
              child: SingleChildScrollView(child: HomeCategories()),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  test(
    'deduplicates category names within each group and retains every catalog ID',
    () {
      final choices = categoryChoices([
        category('1', 'Embutidos', '1'),
        category('2', ' embutidos ', '2'),
        category('3', 'Oculta', '1', active: false),
        category('4', 'Premium', '1', group: 'BEEF'),
        category('5', 'Premium', '1', group: 'PORK'),
      ]);
      expect(choices.length, 3);
      expect(choices.first.ids, ['1', '2']);
      expect(choices.first.unitCount, 2);
      expect(choices.where((entry) => entry.name == 'Premium').length, 2);
    },
  );

  testWidgets(
    'labels the four shortcuts and keeps all categories in the section header',
    (tester) async {
      await open(tester);
      for (final name in [
        'CATEGORIAS',
        'Bovinos',
        'Suínos',
        'Aves',
        'Peixes',
        'Ver todas',
      ]) {
        expect(find.text(name), findsOneWidget);
      }
      expect(find.text('Outras categorias'), findsNothing);
      expect(repository.categoryCalls, 0);
      await tester.tap(find.text('Bovinos'));
      await tester.pumpAndSettle();
      expect(find.text('Grupo Bovinos'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'browses real categories and opens all matching IDs across units',
    (tester) async {
      await open(tester);
      await tester.tap(find.text('Ver todas'));
      await tester.pumpAndSettle();
      expect(find.text('Todas as categorias'), findsOneWidget);
      expect(find.text('Embutidos'), findsOneWidget);
      expect(find.text('2 açougues'), findsOneWidget);
      expect(find.text('Outros'), findsNothing);
      await tester.tap(find.text('Embutidos'));
      await tester.pumpAndSettle();
      expect(tester.widget<CutsScreen>(find.byType(CutsScreen)).categoryIds, [
        '1',
        '2',
      ]);
      expect(repository.requested.toSet(), {'1', '2'});
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('searches without accents and can clear an empty result', (
    tester,
  ) async {
    await open(tester);
    await tester.tap(find.text('Ver todas'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'suinos');
    await tester.pumpAndSettle();
    expect(find.text('Cortes suínos'), findsOneWidget);
    expect(find.text('Embutidos'), findsNothing);
    await tester.enterText(find.byType(TextField), 'inexistente');
    await tester.pumpAndSettle();
    expect(find.text('Nenhuma categoria encontrada.'), findsOneWidget);
    await tester.tap(find.byTooltip('Limpar busca'));
    await tester.pumpAndSettle();
    expect(find.text('Embutidos'), findsOneWidget);
  });

  testWidgets('retries loading categories without losing navigation', (
    tester,
  ) async {
    repository.fail = true;
    await open(tester);
    await tester.tap(find.text('Ver todas'));
    await tester.pumpAndSettle();
    expect(find.text('Tentar novamente'), findsOneWidget);
    repository.fail = false;
    await tester.tap(find.text('Tentar novamente'));
    await tester.pumpAndSettle();
    expect(find.text('Embutidos'), findsOneWidget);
    expect(repository.categoryCalls, 2);
  });

  testWidgets('fits small screens, large text and the search keyboard', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 700);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetViewInsets);
    await open(tester, scale: 1.6);
    expect(tester.takeException(), isNull);
    await tester.tap(find.text('Ver todas'));
    await tester.pumpAndSettle();
    tester.view.viewInsets = const FakeViewPadding(bottom: 280);
    await tester.pumpAndSettle();
    expect(find.byType(TextField), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
