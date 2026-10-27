import 'package:shared_preferences/shared_preferences.dart';

class AnalyticsConsentStore {
  const AnalyticsConsentStore();

  static const _key = 'analytics_collection_consent';
  static const defaultConsent = false;

  Future<bool> read() async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.getBool(_key) ?? defaultConsent;
  }

  Future<void> write(bool granted) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setBool(_key, granted);
  }
}
