import 'package:flutter/foundation.dart';
import 'package:meatshop_mobile/models/business_hours_model.dart';
import 'package:meatshop_mobile/models/unit_model.dart';
import 'package:meatshop_mobile/services/business_hours_service.dart';
import 'package:meatshop_mobile/services/unit_service.dart';

class UnitProvider extends ChangeNotifier {
  final UnitService _unitService;
  final BusinessHoursService _hoursService;

  UnitProvider({
    required UnitService unitService,
    required BusinessHoursService hoursService,
  }) : _unitService = unitService,
       _hoursService = hoursService;

  double? _latitude;
  double? _longitude;
  int _loadVersion = 0;
  bool _disposed = false;
  bool get hasDeliveryLocation => _latitude != null && _longitude != null;
  void setDeliveryAddress(double? lat, double? lng) {
    if (_latitude == lat && _longitude == lng) return;
    _latitude = lat;
    _longitude = lng;
    Future.microtask(() {
      if (!_disposed) return loadUnits();
    });
  }

  List<UnitModel> _units = [];
  Map<String, BusinessHoursModel?> _hoursMap = {};
  bool _loading = false;
  String? _error;

  List<UnitModel> get units => _units;
  bool get loading => _loading;
  String? get error => _error;

  BusinessHoursModel? hoursFor(String unitId) => _hoursMap[unitId];

  bool isOpenNow(String unitId) => _hoursMap[unitId]?.isOpenNow ?? false;

  Future<void> loadUnits({
    double? latitude,
    double? longitude,
    double? radiusKm,
  }) async {
    if (_disposed) return;
    final version = ++_loadVersion;
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final units = await _unitService.getAllUnits(
        latitude: latitude ?? _latitude,
        longitude: longitude ?? _longitude,
        radiusKm: radiusKm,
      );
      if (version != _loadVersion) return;
      _units = units;
      final hours = await _hoursService.fetchAllToday(
        units.map((u) => u.id).toList(),
      );
      if (version == _loadVersion) _hoursMap = hours;
    } catch (e) {
      if (version == _loadVersion) _error = e.toString();
    } finally {
      if (version == _loadVersion) {
        _loading = false;
        notifyListeners();
      }
    }
  }

  @override
  void dispose() {
    _disposed = true;
    ++_loadVersion;
    super.dispose();
  }
}
