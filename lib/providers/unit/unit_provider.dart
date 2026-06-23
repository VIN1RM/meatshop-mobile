import 'package:flutter/foundation.dart';
import 'package:meatshop_mobile/models/business_hours_model.dart';
import 'package:meatshop_mobile/models/unit_model.dart';
import 'package:meatshop_mobile/services/business_hours_service.dart';
import 'package:meatshop_mobile/services/unit_service.dart';

class UnitProvider extends ChangeNotifier {
  final UnitService _unitService;
  final BusinessHoursService _hoursService;

  UnitProvider({UnitService? unitService, BusinessHoursService? hoursService})
    : _unitService = unitService ?? UnitService(),
      _hoursService = hoursService ?? BusinessHoursService();

  List<UnitModel> _units = [];
  Map<String, BusinessHoursModel?> _hoursMap = {};
  bool _loading = false;
  String? _error;

  List<UnitModel> get units => _units;
  bool get loading => _loading;
  String? get error => _error;

  BusinessHoursModel? hoursFor(String unitId) => _hoursMap[unitId];

  bool isOpenNow(String unitId) => _hoursMap[unitId]?.isOpenNow ?? false;

  Future<void> loadUnits() async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      _units = await _unitService.getAllUnits();
      _hoursMap = await _hoursService.fetchAllToday(
        _units.map((u) => u.id).toList(),
      );
    } catch (e) {
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
}
