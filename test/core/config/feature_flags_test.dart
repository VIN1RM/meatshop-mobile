import 'package:flutter_test/flutter_test.dart';
import 'package:meatshop_mobile/core/config/feature_flags.dart';

void main() {
  test('production composition uses the backend for every migrated domain', () {
    final flags = FeatureFlags.fromEnvironment();

    expect(flags.backendAuth, isTrue);
    expect(flags.backendMarketplace, isTrue);
    expect(flags.backendProfileCart, isTrue);
    expect(flags.backendCheckout, isTrue);
    expect(flags.backendDelivery, isTrue);
    expect(flags.backendRealtime, isTrue);
    expect(flags.backendFirebaseServices, isTrue);
  });
}
