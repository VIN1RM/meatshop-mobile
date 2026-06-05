import 'package:shared_preferences/shared_preferences.dart';
import 'package:meatshop_mobile/models/user_preferences.dart';

class UserPreferencesService {
  UserPreferencesService._();
  static final UserPreferencesService instance = UserPreferencesService._();

  static const _kNotifOrders = 'notif_orders';
  static const _kNotifDelivery = 'notif_delivery';
  static const _kNotifPromotions = 'notif_promotions';
  static const _kNotifSystem = 'notif_system';

  Future<UserPreferences> load() async {
    final p = await SharedPreferences.getInstance();
    return UserPreferences(
      notifOrders: p.getBool(_kNotifOrders) ?? true,
      notifDelivery: p.getBool(_kNotifDelivery) ?? true,
      notifPromotions: p.getBool(_kNotifPromotions) ?? true,
      notifSystem: p.getBool(_kNotifSystem) ?? true,
    );
  }

  Future<void> save(UserPreferences prefs) async {
    final p = await SharedPreferences.getInstance();
    await Future.wait([
      p.setBool(_kNotifOrders, prefs.notifOrders),
      p.setBool(_kNotifDelivery, prefs.notifDelivery),
      p.setBool(_kNotifPromotions, prefs.notifPromotions),
      p.setBool(_kNotifSystem, prefs.notifSystem),
    ]);
  }

  Future<void> setNotifOrders(bool value) async {
    final p = await SharedPreferences.getInstance();
    await p.setBool(_kNotifOrders, value);
  }

  Future<void> setNotifDelivery(bool value) async {
    final p = await SharedPreferences.getInstance();
    await p.setBool(_kNotifDelivery, value);
  }

  Future<void> setNotifPromotions(bool value) async {
    final p = await SharedPreferences.getInstance();
    await p.setBool(_kNotifPromotions, value);
  }

  Future<void> setNotifSystem(bool value) async {
    final p = await SharedPreferences.getInstance();
    await p.setBool(_kNotifSystem, value);
  }
}
