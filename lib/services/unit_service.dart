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
  }) async {
    return (await _marketplace.listUnits(
      latitude: latitude,
      longitude: longitude,
      radiusKm: radiusKm,
    )).items;
  }
}
