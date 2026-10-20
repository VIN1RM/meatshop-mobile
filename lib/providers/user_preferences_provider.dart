import 'package:flutter/foundation.dart';
import 'package:meatshop_mobile/models/user_preferences.dart';
import 'package:meatshop_mobile/services/user_preferences_service.dart';

class UserPreferencesProvider extends ChangeNotifier {
  UserPreferences _prefs = const UserPreferences();
  bool _loading = false;
  String? _error;

  UserPreferences get prefs => _prefs;
  bool get loading => _loading;
  String? get error => _error;

  bool get notifOrders => _prefs.notifOrders;
  bool get notifDelivery => _prefs.notifDelivery;
  bool get notifPromotions => _prefs.notifPromotions;
  bool get notifSystem => _prefs.notifSystem;

  Future<void> loadForUser(String uid) async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      _prefs = await UserPreferencesService.instance.load(uid);
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  void clear() {
    _prefs = const UserPreferences();
    notifyListeners();
  }

  Future<bool> setNotifOrders(String uid, bool v) =>
      _update(uid, _prefs.copyWith(notifOrders: v));
  Future<bool> setNotifDelivery(String uid, bool v) =>
      _update(uid, _prefs.copyWith(notifDelivery: v));
  Future<bool> setNotifPromotions(String uid, bool v) =>
      _update(uid, _prefs.copyWith(notifPromotions: v));
  Future<bool> setNotifSystem(String uid, bool v) =>
      _update(uid, _prefs.copyWith(notifSystem: v));

  Future<bool> _update(String uid, UserPreferences updated) async {
    final previous = _prefs;
    _prefs = updated;
    _error = null;
    notifyListeners();
    try {
      await UserPreferencesService.instance.save(uid, updated);
      return true;
    } catch (_) {
      _prefs = previous;
      _error = 'Não foi possível salvar a preferência.';
      notifyListeners();
      return false;
    }
  }
}
