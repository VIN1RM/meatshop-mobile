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

  int _generation = 0;
  String? _activeUid;
  Future<void> _queue = Future<void>.value();

  Future<void> loadForUser(String uid) async {
    final generation = ++_generation;
    _activeUid = uid;
    _prefs = const UserPreferences();
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final loaded = await UserPreferencesService.instance.load(uid);
      if (generation == _generation) _prefs = loaded;
    } finally {
      if (generation == _generation) {
        _loading = false;
        notifyListeners();
      }
    }
  }

  void clear() {
    ++_generation;
    _activeUid = null;
    _prefs = const UserPreferences();
    _loading = false;
    _error = null;
    notifyListeners();
  }

  Future<bool> setNotifOrders(String uid, bool v) =>
      _update(uid, (prefs) => prefs.copyWith(notifOrders: v));
  Future<bool> setNotifDelivery(String uid, bool v) =>
      _update(uid, (prefs) => prefs.copyWith(notifDelivery: v));
  Future<bool> setNotifPromotions(String uid, bool v) =>
      _update(uid, (prefs) => prefs.copyWith(notifPromotions: v));
  Future<bool> setNotifSystem(String uid, bool v) =>
      _update(uid, (prefs) => prefs.copyWith(notifSystem: v));

  Future<bool> _update(
    String uid,
    UserPreferences Function(UserPreferences) change,
  ) {
    final generation = _generation;
    final result = _queue.then((_) async {
      if (generation != _generation || uid != _activeUid) return false;
      final previous = _prefs;
      final updated = change(previous);
      _prefs = updated;
      _error = null;
      notifyListeners();
      try {
        await UserPreferencesService.instance.save(uid, updated);
        return generation == _generation;
      } catch (_) {
        if (generation == _generation) {
          _prefs = previous;
          _error = 'Não foi possível salvar a preferência.';
          notifyListeners();
        }
        return false;
      }
    });
    _queue = result.then<void>((_) {});
    return result;
  }

  @override
  void dispose() {
    ++_generation;
    super.dispose();
  }
}
