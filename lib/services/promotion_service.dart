import '../data/repositories/marketplace_repository.dart';
import '../models/promotion_model.dart';

class PromotionService {
  PromotionService({required MarketplaceRepository marketplace})
    : _marketplace = marketplace;
  final MarketplaceRepository _marketplace;

  Future<List<PromotionModel>> fetchActivePromotions({int limit = 10}) async =>
      (await _marketplace.listPromotions(limit: limit)).items;

  Future<List<PromotionModel>> fetchActivePromotionsByUnit({
    required String unitId,
    int limit = 10,
  }) async =>
      (await _marketplace.listPromotions(unitId: unitId, limit: limit)).items;
}
