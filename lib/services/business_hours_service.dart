import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:meatshop_mobile/models/business_hours_model.dart';
import '../data/repositories/marketplace_repository.dart';

class BusinessHoursService {
  final FirebaseFirestore? _db;

  BusinessHoursService({
    FirebaseFirestore? db,
    MarketplaceRepository? marketplace,
  }) : _db = db ?? (marketplace == null ? FirebaseFirestore.instance : null),
       _marketplace = marketplace;
  final MarketplaceRepository? _marketplace;

  Future<BusinessHoursModel?> fetchToday(String unitId) async {
    final weekday = BusinessHoursModel.todayWeekday();
    if (_marketplace != null) {
      final hours = await _marketplace.listBusinessHours(unitId);
      for (final item in hours) {
        if (item.weekday.toLowerCase() == weekday) return item;
      }
      return null;
    }
    final doc = await _db!
        .collection('units')
        .doc(unitId)
        .collection('business_hours')
        .doc(weekday)
        .get();

    if (!doc.exists || doc.data() == null) return null;
    return BusinessHoursModel.fromMap(doc.data()!);
  }

  Future<Map<String, BusinessHoursModel?>> fetchAllToday(
    List<String> unitIds,
  ) async {
    final results = await Future.wait(unitIds.map((id) => fetchToday(id)));
    return {for (var i = 0; i < unitIds.length; i++) unitIds[i]: results[i]};
  }
}
