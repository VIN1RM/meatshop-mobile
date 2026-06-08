import 'package:flutter/foundation.dart';
import 'package:meatshop_mobile/models/user_preferences.dart';
import 'package:meatshop_mobile/services/user_preferences_service.dart';

class UserPreferencesProvider extends ChangeNotifier {
  UserPreferences _prefs = const UserPreferences();
  bool _loading = false;

  UserPreferences get prefs => _prefs;
  bool get loading => _loading;

  bool get notifOrders => _prefs.notifOrders;
  bool get notifDelivery => _prefs.notifDelivery;
  bool get notifPromotions => _prefs.notifPromotions;
  bool get notifSystem => _prefs.notifSystem;

  Future<void> loadForUser(String uid) async {
    _loading = true;
    notifyListeners();

    _prefs = await UserPreferencesService.instance.load(uid);

    _loading = false;
    notifyListeners();
  }

  void clear() {
    _prefs = const UserPreferences();
    notifyListeners();
  }

  Future<void> setNotifOrders(String uid, bool v) =>
      _update(uid, _prefs.copyWith(notifOrders: v));
  Future<void> setNotifDelivery(String uid, bool v) =>
      _update(uid, _prefs.copyWith(notifDelivery: v));
  Future<void> setNotifPromotions(String uid, bool v) =>
      _update(uid, _prefs.copyWith(notifPromotions: v));
  Future<void> setNotifSystem(String uid, bool v) =>
      _update(uid, _prefs.copyWith(notifSystem: v));

  Future<void> _update(String uid, UserPreferences updated) async {
    _prefs = updated;
    notifyListeners();
    await UserPreferencesService.instance.save(uid, updated);
  }
}