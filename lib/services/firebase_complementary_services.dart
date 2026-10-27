import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_performance/firebase_performance.dart';
import 'package:flutter/foundation.dart';

import 'analytics_consent_store.dart';

final class FirebaseComplementaryServices {
  FirebaseComplementaryServices._();

  static bool _enabled = false;
  static bool _analyticsConsent = AnalyticsConsentStore.defaultConsent;

  static Future<void> initialize() async {
    _enabled = true;
    await FirebaseAppCheck.instance.activate(
      androidProvider: kReleaseMode
          ? AndroidProvider.playIntegrity
          : AndroidProvider.debug,
      appleProvider: kReleaseMode
          ? AppleProvider.appAttest
          : AppleProvider.debug,
    );
    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };
    await setAnalyticsConsent(await const AnalyticsConsentStore().read());
    const performanceEnabled = bool.fromEnvironment(
      'FIREBASE_PERFORMANCE_ENABLED',
      defaultValue: true,
    );
    await FirebasePerformance.instance.setPerformanceCollectionEnabled(
      performanceEnabled,
    );
  }

  static Future<Map<String, String>> requestHeaders({
    bool requireAppCheck = true,
  }) async {
    if (!_enabled) return const {'x-meatshop-client': 'mobile'};
    try {
      final token = await FirebaseAppCheck.instance.getToken();
      return {
        'x-meatshop-client': 'mobile',
        if (token != null && token.isNotEmpty) 'x-firebase-appcheck': token,
      };
    } catch (_) {
      if (requireAppCheck) rethrow;
      return const {'x-meatshop-client': 'mobile'};
    }
  }

  static Future<void> setAnalyticsConsent(bool granted) async {
    _analyticsConsent = granted;
    if (!_enabled) return;
    await FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(granted);
  }

  static Future<void> logNavigation(String destination) async {
    if (!_enabled || !_analyticsConsent) return;
    await FirebaseAnalytics.instance.logEvent(
      name: 'push_open',
      parameters: {'destination': destination},
    );
  }
}
