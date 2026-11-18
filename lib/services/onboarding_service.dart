import 'package:shared_preferences/shared_preferences.dart';

/// Introduction state belongs to this installation, never to authentication.
class OnboardingService {
  const OnboardingService();

  static const currentVersion = 2;
  static const legacyKey = 'hasSeenOnboarding';
  static const versionKey = 'onboarding_version';

  Future<bool> shouldShowIntroduction() async {
    final prefs = await SharedPreferences.getInstance();
    final version = prefs.getInt(versionKey);
    // Existing installations keep their completed introduction.
    if (version == null && prefs.getBool(legacyKey) == true) return false;
    return (version ?? 0) < currentVersion;
  }

  Future<void> completeIntroduction() async {
    final prefs = await SharedPreferences.getInstance();
    if (!await prefs.setInt(versionKey, currentVersion)) {
      throw StateError('Introduction was not saved.');
    }
    await prefs.setBool(legacyKey, true);
  }

  Future<bool> shouldShowGuide(String profile) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('onboarding_guide_$profile') != currentVersion;
  }

  Future<void> completeGuide(String profile) async {
    final prefs = await SharedPreferences.getInstance();
    if (!await prefs.setInt('onboarding_guide_$profile', currentVersion)) {
      throw StateError('Guide was not saved.');
    }
  }
}
