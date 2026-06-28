import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:meatshop_mobile/models/business_hours_model.dart';
import 'package:meatshop_mobile/models/unit_model.dart';
import 'package:meatshop_mobile/services/business_hours_service.dart';
import 'package:meatshop_mobile/services/location_service.dart';
import 'package:meatshop_mobile/services/unit_service.dart';

enum UnitSortMode { rating, proximity }

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

  Position? _userPosition;
  bool _locationDenied = false;
  UnitSortMode _sortMode = UnitSortMode.proximity;

  List<UnitModel> get units => _sorted;
  bool get loading => _loading;
  String? get error => _error;
  Position? get userPosition => _userPosition;
  bool get locationDenied => _locationDenied;
  UnitSortMode get sortMode => _sortMode;
  bool get hasLocation => _userPosition != null;

  BusinessHoursModel? hoursFor(String unitId) => _hoursMap[unitId];
  bool isOpenNow(String unitId) => _hoursMap[unitId]?.isOpenNow ?? false;

  List<UnitModel> get _sorted {
    final list = [..._units];
    if (_sortMode == UnitSortMode.proximity && _userPosition != null) {
      list.sort((a, b) {
        final da = a.distanceTo(
          _userPosition!.latitude,
          _userPosition!.longitude,
        );
        final db = b.distanceTo(
          _userPosition!.latitude,
          _userPosition!.longitude,
        );
        if (da == null && db == null) return 0;
        if (da == null) return 1;
        if (db == null) return -1;
        return da.compareTo(db);
      });
    }
    return list;
  }

  void setSortMode(UnitSortMode mode) {
    if (_sortMode == mode) return;
    _sortMode = mode;
    notifyListeners();
  }

  Future<void> loadUnits() async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      _units = await _unitService.getAllUnits();

      Position? position;
      try {
        position = await LocationService.instance.getCurrentPosition().timeout(
          const Duration(seconds: 8),
          onTimeout: () => null,
        );
        debugPrint('[UnitProvider] position: $position');
      } catch (_) {
        position = null;
      }
      if (position != null) {
        _userPosition = position;
        _locationDenied = false;
        _sortMode = UnitSortMode.proximity;
      } else {
        _locationDenied = true;
        _sortMode = UnitSortMode.rating;
      }

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
