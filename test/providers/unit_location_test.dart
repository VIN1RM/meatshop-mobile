import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:meatshop_mobile/core/network/page.dart';
import 'package:meatshop_mobile/data/repositories/marketplace_repository.dart';
import 'package:meatshop_mobile/models/unit_model.dart';
import 'package:meatshop_mobile/providers/unit/unit_provider.dart';
import 'package:meatshop_mobile/services/business_hours_service.dart';
import 'package:meatshop_mobile/services/discovery_location_source.dart';
import 'package:meatshop_mobile/services/unit_service.dart';

class FakeMarketplace extends Fake implements MarketplaceRepository {
  final requests = <({double? latitude, double? longitude})>[];
  Completer<Page<UnitModel>>? pending;
  @override
  Future<Page<UnitModel>> listUnits({
    int page = 1,
    int limit = 50,
    double? latitude,
    double? longitude,
    double? radiusKm,
  }) async {
    requests.add((latitude: latitude, longitude: longitude));
    if (pending != null) return pending!.future;
    return const Page(
      items: [],
      meta: PageMeta(page: 1, limit: 50, total: 0, totalPages: 1),
    );
  }
}

class FakeLocation implements DiscoveryLocationSource {
  int calls = 0;
  bool denied = false;
  Completer<({double latitude, double longitude})>? pending;
  @override
  Future<({double latitude, double longitude})> current() async {
    calls++;
    if (denied) throw StateError('Sem permissão. Escolha no mapa.');
    if (pending != null) return pending!.future;
    return (latitude: -23.55, longitude: -46.63);
  }
}

void main() {
  late FakeMarketplace marketplace;
  late FakeLocation location;
  late UnitProvider units;
  setUp(() {
    marketplace = FakeMarketplace();
    location = FakeLocation();
    units = UnitProvider(
      unitService: UnitService(marketplace: marketplace),
      hoursService: BusinessHoursService(marketplace: marketplace),
      locationSource: location,
    );
  });
  tearDown(() => units.dispose());
  test(
    'only requests device location after an explicit selection and forwards it',
    () async {
      await units.loadUnits();
      expect(location.calls, 0);
      await units.useCurrentLocation();
      expect(location.calls, 1);
      expect(marketplace.requests.last, (latitude: -23.55, longitude: -46.63));
      expect(units.locationMode, UnitLocationMode.device);
      expect(units.locating, false);
    },
  );
  test(
    'denied permission preserves manual search and saved-address fallback',
    () async {
      location.denied = true;
      await units.useCurrentLocation();
      expect(units.locationError, isNotNull);
      await units.useManualLocation(-8, -35);
      expect(marketplace.requests.last, (latitude: -8.0, longitude: -35.0));
      units.setDeliveryAddress(-10, -40);
      await Future<void>.delayed(Duration.zero);
      expect(
        units.latitude,
        -8,
      ); // Address refresh must not replace a deliberate choice.
      await units.useSavedAddress();
      expect(units.latitude, -10);
      await units.showAllUnits();
      expect(marketplace.requests.last, (latitude: null, longitude: null));
    },
  );
  test('a late GPS fix cannot replace a newer manual selection', () async {
    location.pending = Completer();
    final locating = units.useCurrentLocation();
    await units.useManualLocation(-8, -35);
    location.pending!.complete((latitude: -23.55, longitude: -46.63));
    await locating;
    expect(units.latitude, -8);
    expect(units.locationMode, UnitLocationMode.manual);
  });
  test(
    'closing the provider during a GPS request does not notify after dispose',
    () async {
      location.pending = Completer();
      final locating = units.useCurrentLocation();
      units.dispose();
      location.pending!.complete((latitude: -23.55, longitude: -46.63));
      await locating;
      // Replace the disposed instance for tearDown.
      units = UnitProvider(
        unitService: UnitService(marketplace: marketplace),
        hoursService: BusinessHoursService(marketplace: marketplace),
      );
    },
  );
}
