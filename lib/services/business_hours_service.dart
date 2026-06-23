import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:meatshop_mobile/models/business_hours_model.dart';

class BusinessHoursService {
  final FirebaseFirestore _db;

  BusinessHoursService({FirebaseFirestore? db})
    : _db = db ?? FirebaseFirestore.instance;

  Future<BusinessHoursModel?> fetchToday(String unitId) async {
    final weekday = BusinessHoursModel.todayWeekday();
    final doc = await _db
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
