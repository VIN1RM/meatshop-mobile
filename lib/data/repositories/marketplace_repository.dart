import '../../core/network/page.dart';
import '../../models/business_hours_model.dart';
import '../../models/category_model.dart';
import '../../models/product_model.dart';
import '../../models/promotion_model.dart';
import '../../models/review_model.dart';
import '../../models/search_model.dart';
import '../../models/unit_model.dart';

abstract interface class MarketplaceRepository {
  Future<Page<UnitModel>> listUnits({
    int page = 1,
    int limit = 50,
    double? latitude,
    double? longitude,
    double? radiusKm,
  });
  Future<UnitModel> getUnit(String id);
  Future<List<CategoryModel>> listCategories({String? unitId});
  Future<Page<ProductModel>> listProducts({
    String? unitId,
    String? categoryId,
    int page = 1,
    int limit = 10,
  });
  Future<Page<PromotionModel>> listPromotions({
    String? unitId,
    int page = 1,
    int limit = 10,
  });
  Future<List<BusinessHoursModel>> listBusinessHours(String unitId);
  Future<Page<ReviewModel>> listReviews({
    String? unitId,
    String? productId,
    int page = 1,
    int limit = 20,
  });
  Future<Page<SearchResultModel>> search(
    String query, {
    String? unitId,
    String? categoryId,
    double? minPrice,
    double? maxPrice,
    int page = 1,
    int limit = 20,
  });
}
