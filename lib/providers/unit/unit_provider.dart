import 'package:flutter/foundation.dart';
import 'package:meatshop_mobile/models/unit_model.dart';
import 'package:meatshop_mobile/services/unit_service.dart';

class UnitProvider extends ChangeNotifier {
  final UnitService _service = UnitService();

  List<UnitModel> _units = [];
  bool _loading = false;
  String? _error;

  List<UnitModel> get units => _units;
  bool get loading => _loading;
  String? get error => _error;

  Future<void> loadUnits() async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      _units = await _service.getAllUnits();
    } catch (e) {
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<String?> createUnit(UnitModel unit) async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final id = await _service.createUnit(unit);
      await loadUnits();
      return id;
    } catch (e) {
      _error = e.toString();
      _loading = false;
      notifyListeners();
      return null;
    }
  }
}