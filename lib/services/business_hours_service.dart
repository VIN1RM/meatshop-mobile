import 'package:meatshop_mobile/models/business_hours_model.dart';
import '../data/repositories/marketplace_repository.dart';

class BusinessHoursService {
  BusinessHoursService({required MarketplaceRepository marketplace})
    : _marketplace = marketplace;
  final MarketplaceRepository _marketplace;

  Future<BusinessHoursModel?> fetchToday(String unitId) async {
    final weekday = BusinessHoursModel.todayWeekday();
    final hours = await _marketplace.listBusinessHours(unitId);
    for (final item in hours) {
      if (item.weekday.toLowerCase() == weekday) return item;
    }
    return null;
  }

  Future<Map<String, BusinessHoursModel?>> fetchAllToday(
    List<String> unitIds,
  ) async {
    final results = await Future.wait(unitIds.map((id) => fetchToday(id)));
    return {for (var i = 0; i < unitIds.length; i++) unitIds[i]: results[i]};
  }
}
