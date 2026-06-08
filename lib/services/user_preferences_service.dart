import 'package:shared_preferences/shared_preferences.dart';
import 'package:meatshop_mobile/models/user_preferences.dart';

class UserPreferencesService {
  UserPreferencesService._();
  static final UserPreferencesService instance = UserPreferencesService._();

  String _key(String uid, String field) => 'user_prefs_${uid}_$field';

  Future<UserPreferences> load(String uid) async {
    final p = await SharedPreferences.getInstance();
    return UserPreferences(
      notifOrders: p.getBool(_key(uid, 'notif_orders')) ?? true,
      notifDelivery: p.getBool(_key(uid, 'notif_delivery')) ?? true,
      notifPromotions: p.getBool(_key(uid, 'notif_promotions')) ?? true,
      notifSystem: p.getBool(_key(uid, 'notif_system')) ?? true,
    );
  }

  Future<void> save(String uid, UserPreferences prefs) async {
    final p = await SharedPreferences.getInstance();
    await Future.wait([
      p.setBool(_key(uid, 'notif_orders'), prefs.notifOrders),
      p.setBool(_key(uid, 'notif_delivery'), prefs.notifDelivery),
      p.setBool(_key(uid, 'notif_promotions'), prefs.notifPromotions),
      p.setBool(_key(uid, 'notif_system'), prefs.notifSystem),
    ]);
  }
}