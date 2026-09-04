import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_performance/firebase_performance.dart';
import 'package:flutter/foundation.dart';

final class FirebaseComplementaryServices {
  FirebaseComplementaryServices._();

  static bool _enabled = false;

  static Future<void> initialize({required bool enabled}) async {
    _enabled = enabled;
    if (!enabled) return;
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
    const analyticsConsent = bool.fromEnvironment('FIREBASE_ANALYTICS_CONSENT');
    await FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(
      analyticsConsent,
    );
    const performanceEnabled = bool.fromEnvironment(
      'FIREBASE_PERFORMANCE_ENABLED',
      defaultValue: true,
    );
    await FirebasePerformance.instance.setPerformanceCollectionEnabled(
      performanceEnabled,
    );
  }

  static Future<Map<String, String>> requestHeaders() async {
    if (!_enabled) return const {'x-meatshop-client': 'mobile'};
    final token = await FirebaseAppCheck.instance.getToken();
    return {
      'x-meatshop-client': 'mobile',
      if (token != null && token.isNotEmpty) 'x-firebase-appcheck': token,
    };
  }

  static Future<void> logNavigation(String destination) async {
    if (!_enabled) return;
    const consent = bool.fromEnvironment('FIREBASE_ANALYTICS_CONSENT');
    if (!consent) return;
    await FirebaseAnalytics.instance.logEvent(
      name: 'push_open',
      parameters: {'destination': destination},
    );
  }
}
