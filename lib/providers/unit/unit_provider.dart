import 'package:flutter/foundation.dart';
import '../../services/discovery_location_source.dart';

import 'package:meatshop_mobile/models/business_hours_model.dart';
import 'package:meatshop_mobile/models/unit_model.dart';
import 'package:meatshop_mobile/services/business_hours_service.dart';
import 'package:meatshop_mobile/services/unit_service.dart';

enum UnitLocationMode { savedAddress, device, manual, all }

class UnitProvider extends ChangeNotifier {
  final UnitService _unitService;
  final BusinessHoursService _hoursService;

  UnitProvider({
    required UnitService unitService,
    required BusinessHoursService hoursService,
    DiscoveryLocationSource? locationSource,
  }) : _unitService = unitService,
       _hoursService = hoursService,
       _locationSource = locationSource ?? GeolocatorDiscoverySource();

  final DiscoveryLocationSource _locationSource;
  double? _latitude;
  double? _longitude;
  double? _savedLatitude;
  double? _savedLongitude;
  int _loadVersion = 0;
  int _selectionVersion = 0;
  bool _disposed = false;
  bool locating = false;
  String? locationError;
  UnitLocationMode locationMode = UnitLocationMode.savedAddress;
  bool get hasDeliveryLocation => _latitude != null && _longitude != null;
  bool get hasSavedLocation =>
      _savedLatitude != null && _savedLongitude != null;
  double? get latitude => _latitude;
  double? get longitude => _longitude;
  String get locationLabel => !hasDeliveryLocation
      ? 'Todos os açougues'
      : switch (locationMode) {
          UnitLocationMode.savedAddress => 'Perto do endereço padrão',
          UnitLocationMode.device => 'Perto da minha localização',
          UnitLocationMode.manual => 'Perto do ponto escolhido',
          UnitLocationMode.all => 'Todos os açougues',
        };

  void setDeliveryAddress(double? lat, double? lng) {
    final changed = _savedLatitude != lat || _savedLongitude != lng;
    _savedLatitude = lat;
    _savedLongitude = lng;
    if (!changed || locationMode != UnitLocationMode.savedAddress) return;
    _latitude = lat;
    _longitude = lng;
    Future.microtask(() {
      if (!_disposed) return loadUnits();
    });
  }

  Future<void> _select(UnitLocationMode mode, double? lat, double? lng) async {
    if (_disposed) return;
    ++_selectionVersion;
    locating = false;
    locationError = null;
    locationMode = mode;
    _latitude = lat;
    _longitude = lng;
    await loadUnits();
  }

  Future<void> useSavedAddress() =>
      _select(UnitLocationMode.savedAddress, _savedLatitude, _savedLongitude);
  Future<void> showAllUnits() => _select(UnitLocationMode.all, null, null);
  Future<void> useManualLocation(double lat, double lng) {
    if (!lat.isFinite || !lng.isFinite || lat.abs() > 90 || lng.abs() > 180) {
      throw ArgumentError('Invalid coordinates');
    }
    return _select(UnitLocationMode.manual, lat, lng);
  }

  Future<void> useCurrentLocation() async {
    if (_disposed || locating) return;
    final version = ++_selectionVersion;
    locating = true;
    locationError = null;
    notifyListeners();
    try {
      final point = await _locationSource.current();
      if (_disposed || version != _selectionVersion) return;
      await _select(UnitLocationMode.device, point.latitude, point.longitude);
    } catch (error) {
      if (!_disposed && version == _selectionVersion) {
        locationError = error is StateError
            ? error.message
            : 'Não foi possível obter sua localização. Escolha um ponto no mapa ou use seu endereço salvo.';
      }
    } finally {
      if (!_disposed && version == _selectionVersion) {
        locating = false;
        notifyListeners();
      }
    }
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

  void clearSession() {
    ++_selectionVersion;
    ++_loadVersion;
    locating = false;
    locationError = null;
    locationMode = UnitLocationMode.savedAddress;
    _latitude = null;
    _longitude = null;
    _savedLatitude = null;
    _savedLongitude = null;
    _units = [];
    _hoursMap = {};
    _loading = false;
    _error = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    ++_loadVersion;
    super.dispose();
  }
}
