import 'package:shared_preferences/shared_preferences.dart';
import 'package:meatshop_mobile/models/user_preferences.dart';
import 'package:meatshop_mobile/data/repositories/notification_repository.dart';

class UserPreferencesService {
  UserPreferencesService._();
  static final UserPreferencesService instance = UserPreferencesService._();
  NotificationRepository? _backend;

  void configure({required NotificationRepository backend}) {
    _backend = backend;
  }

  String _key(String uid, String field) => 'user_prefs_${uid}_$field';

  Future<UserPreferences> load(String uid) async {
    final backend = _backend;
    if (backend != null) {
      try {
        final preferences = await backend.getPreferences();
        await _saveLocal(uid, preferences);
        return preferences;
      } catch (_) {
        // Offline users retain the last synchronized preferences.
      }
    }
    return _loadLocal(uid);
  }

  Future<UserPreferences> _loadLocal(String uid) async {
    final p = await SharedPreferences.getInstance();
    return UserPreferences(
      notifOrders: p.getBool(_key(uid, 'notif_orders')) ?? true,
      notifDelivery: p.getBool(_key(uid, 'notif_delivery')) ?? true,
      notifPromotions: p.getBool(_key(uid, 'notif_promotions')) ?? true,
      notifSystem: p.getBool(_key(uid, 'notif_system')) ?? true,
    );
  }

  Future<void> save(String uid, UserPreferences prefs) async {
    final synchronized = await _backend?.updatePreferences(prefs) ?? prefs;
    await _saveLocal(uid, synchronized);
  }

  Future<void> _saveLocal(String uid, UserPreferences prefs) async {
    final p = await SharedPreferences.getInstance();
    await Future.wait([
      p.setBool(_key(uid, 'notif_orders'), prefs.notifOrders),
      p.setBool(_key(uid, 'notif_delivery'), prefs.notifDelivery),
      p.setBool(_key(uid, 'notif_promotions'), prefs.notifPromotions),
      p.setBool(_key(uid, 'notif_system'), prefs.notifSystem),
    ]);
  }
}
