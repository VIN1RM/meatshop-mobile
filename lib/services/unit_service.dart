import '../models/unit_model.dart';
import '../data/repositories/marketplace_repository.dart';

class UnitService {
  UnitService({required MarketplaceRepository marketplace})
    : _marketplace = marketplace;
  final MarketplaceRepository _marketplace;

  Future<UnitModel?> getUnitById(String unitId) async {
    return _marketplace.getUnit(unitId);
  }

  Future<List<UnitModel>> getAllUnits({
    double? latitude,
    double? longitude,
    double? radiusKm,
    String? city,
    String? region,
  }) async {
    final units = <UnitModel>[];
    var page = 1;
    while (true) {
      final result = await _marketplace.listUnits(
        page: page++,
        latitude: latitude,
        longitude: longitude,
        radiusKm: radiusKm,
        city: city,
        region: region,
      );
      units.addAll(result.items);
      if (!result.meta.hasNextPage) return units;
    }
  }
}
