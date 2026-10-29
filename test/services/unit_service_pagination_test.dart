import 'package:flutter_test/flutter_test.dart';
import 'package:meatshop_mobile/core/network/page.dart';
import 'package:meatshop_mobile/data/repositories/marketplace_repository.dart';
import 'package:meatshop_mobile/models/unit_model.dart';
import 'package:meatshop_mobile/services/unit_service.dart';

class _Units implements MarketplaceRepository {
  final pages = <int>[];
  @override
  Future<Page<UnitModel>> listUnits({
    int page = 1,
    int limit = 50,
    double? latitude,
    double? longitude,
    double? radiusKm,
    String? city,
    String? region,
  }) async {
    pages.add(page);
    expect(city, 'Goiânia');
    return Page(
      items: [
        UnitModel(
          id: '$page',
          name: '$page',
          cnpj: '',
          street: '',
          number: '',
          neighborhood: '',
          city: '',
          state: '',
          zipCode: '',
          adminId: '',
          imageUrl: '',
          createdAt: DateTime(2026),
        ),
      ],
      meta: PageMeta(page: page, limit: 1, total: 2, totalPages: 2),
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  test(
    'loads every matching page before local sorting and filtering',
    () async {
      final repository = _Units();
      final units = await UnitService(
        marketplace: repository,
      ).getAllUnits(city: 'Goiânia');
      expect(repository.pages, [1, 2]);
      expect(units.map((value) => value.id), ['1', '2']);
    },
  );
}
