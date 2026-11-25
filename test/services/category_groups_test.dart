import 'package:flutter_test/flutter_test.dart';
import 'package:meatshop_mobile/data/repositories/marketplace_repository.dart';
import 'package:meatshop_mobile/models/category_model.dart';
import 'package:meatshop_mobile/services/category_service.dart';

CategoryModel category(
  String id,
  String name, {
  String? group,
  bool active = true,
}) => CategoryModel(
  id: id,
  name: name,
  group: group,
  description: '',
  active: active,
  unitId: id,
);

class Marketplace extends Fake implements MarketplaceRepository {
  List<CategoryModel> categories = [];
  @override
  Future<List<CategoryModel>> listCategories({String? unitId}) async =>
      categories;
}

void main() {
  test(
    'groups collect custom names across units and respect explicit classification',
    () async {
      final repository = Marketplace()
        ..categories = [
          category('1', 'Cortes bovinos', group: 'BEEF'),
          category('2', 'Linha premium', group: 'BEEF'),
          category('3', 'Bovinos', group: 'PORK'),
          category('4', 'Bovinos', group: 'BEEF', active: false),
        ];
      final service = CategoryService(marketplace: repository);
      expect(await service.fetchCategoryIdsByGroup('BEEF'), ['1', '2']);
      expect(await service.fetchCategoryIdsByGroup('PORK'), ['3']);
    },
  );

  test(
    'older API names remain visible including unknown and ambiguous categories',
    () async {
      final repository = Marketplace()
        ..categories = [
          category('1', 'Cortes bovinos'),
          category('2', 'Carne suína'),
          category('3', 'Frango'),
          category('4', 'Peixes frescos'),
          category('5', 'Churrasco'),
          category('6', 'Bovinos e suínos'),
        ];
      final service = CategoryService(marketplace: repository);
      expect(await service.fetchCategoryIdsByGroup('BEEF'), ['1']);
      expect(await service.fetchCategoryIdsByGroup('PORK'), ['2']);
      expect(await service.fetchCategoryIdsByGroup('POULTRY'), ['3']);
      expect(await service.fetchCategoryIdsByGroup('FISH'), ['4']);
      expect(await service.fetchCategoryIdsByGroup('OTHER'), ['5', '6']);
    },
  );

  test('an unknown category name can still resolve its exact ID', () async {
    final repository = Marketplace()..categories = [category('9', 'Temperos')];
    expect(
      await CategoryService(
        marketplace: repository,
      ).fetchCategoryIdsByName(' Temperos '),
      ['9'],
    );
  });
}
