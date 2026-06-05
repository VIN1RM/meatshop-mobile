import 'package:flutter/foundation.dart';
import 'package:meatshop_mobile/models/user_preferences.dart';
import 'package:meatshop_mobile/services/user_preferences_service.dart';

class UserPreferencesProvider extends ChangeNotifier {
  UserPreferences _prefs = const UserPreferences();
  bool _loading = true;

  UserPreferences get prefs => _prefs;
  bool get loading => _loading;

  bool get notifOrders => _prefs.notifOrders;
  bool get notifDelivery => _prefs.notifDelivery;
  bool get notifPromotions => _prefs.notifPromotions;
  bool get notifSystem => _prefs.notifSystem;

  UserPreferencesProvider() {
    _load();
  }

  Future<void> _load() async {
    _prefs = await UserPreferencesService.instance.load();
    _loading = false;
    notifyListeners();
  }

  Future<void> setNotifOrders(bool v) =>
      _update(_prefs.copyWith(notifOrders: v));
  Future<void> setNotifDelivery(bool v) =>
      _update(_prefs.copyWith(notifDelivery: v));
  Future<void> setNotifPromotions(bool v) =>
      _update(_prefs.copyWith(notifPromotions: v));
  Future<void> setNotifSystem(bool v) =>
      _update(_prefs.copyWith(notifSystem: v));

  Future<void> _update(UserPreferences updated) async {
    _prefs = updated;
    notifyListeners();
    await UserPreferencesService.instance.save(updated);
  }
}
