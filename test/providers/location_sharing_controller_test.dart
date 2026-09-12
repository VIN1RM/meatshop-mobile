import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:meatshop_mobile/core/network/api_failure.dart';
import 'package:meatshop_mobile/data/repositories/delivery_repository.dart';
import 'package:meatshop_mobile/providers/delivery/location_sharing_controller.dart';
import 'package:meatshop_mobile/services/delivery_location_source.dart';

Position position({
  double accuracy = 12.345678,
  bool mocked = false,
  DateTime? at,
}) => Position(
  latitude: -23.5,
  longitude: -46.6,
  timestamp: at ?? DateTime.now(),
  accuracy: accuracy,
  altitude: 0,
  altitudeAccuracy: 0,
  heading: 0,
  headingAccuracy: 0,
  speed: 0,
  speedAccuracy: 0,
  isMocked: mocked,
);

class FakeSource implements DeliveryLocationSource {
  bool serviceEnabled = true;
  LocationPermission allowed = LocationPermission.whileInUse;
  Position next = position();
  final stream = StreamController<Position>.broadcast();
  @override
  Future<bool> enabled() async => serviceEnabled;
  @override
  Future<LocationPermission> permission() async => allowed;
  @override
  Future<LocationPermission> requestPermission() async => allowed;
  @override
  Future<Position> current() async => next;
  @override
  Stream<Position> positions() => stream.stream;
}

class FakeDelivery extends Fake implements DeliveryRepository {
  final consents = <bool>[];
  final sent = <Map<String, Object?>>[];
  ApiFailure? failure;
  @override
  Future<String?> setLocationSharing(int id, bool enabled) async {
    consents.add(enabled);
    return enabled ? '00000000-0000-4000-8000-000000000001' : null;
  }

  @override
  Future<void> sendLocation(
    int orderId,
    double latitude,
    double longitude, {
    double? accuracy,
    required DateTime capturedAt,
    required String sessionId,
    required String sampleId,
    bool isMocked = false,
  }) async {
    if (failure != null) throw failure!;
    sent.add({
      'orderId': orderId,
      'accuracy': accuracy,
      'sessionId': sessionId,
      'sampleId': sampleId,
      'capturedAt': capturedAt,
    });
  }
}

void main() {
  late FakeDelivery repository;
  late FakeSource source;
  late LocationSharingController controller;
  setUp(() {
    repository = FakeDelivery();
    source = FakeSource();
    controller = LocationSharingController(
      repository: repository,
      source: source,
    );
  });
  tearDown(() async {
    await controller.stop();
    controller.dispose();
    await source.stream.close();
  });
  test(
    'does not request a sharing session when GPS or permission is unavailable',
    () async {
      source.serviceEnabled = false;
      expect(await controller.start(42), false);
      expect(repository.consents, isEmpty);
      source.serviceEnabled = true;
      source.allowed = LocationPermission.deniedForever;
      expect(await controller.start(42), false);
      expect(repository.sent, isEmpty);
    },
  );
  test(
    'sends precise native accuracy with capture time and an explicit consent session',
    () async {
      expect(await controller.start(42), true);
      expect(repository.sent.single['accuracy'], 12.345678);
      expect(repository.sent.single['orderId'], 42);
      expect(
        repository.sent.single['sampleId'],
        matches(
          RegExp(
            r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
          ),
        ),
      );
    },
  );
  test('does not forward stale, inaccurate or mocked samples', () async {
    source.next = position(accuracy: 900);
    await controller.start(42);
    source.stream.add(position(mocked: true));
    source.stream.add(
      position(at: DateTime.now().subtract(const Duration(minutes: 3))),
    );
    await Future<void>.delayed(Duration.zero);
    expect(repository.sent, isEmpty);
    expect(controller.message, isNotNull);
  });
  test('throttles streams and stops sending immediately when paused', () async {
    await controller.start(42);
    source.stream.add(position());
    source.stream.add(position());
    await Future<void>.delayed(Duration.zero);
    expect(repository.sent, hasLength(1));
    await controller.stop();
    source.stream.add(position());
    await Future<void>.delayed(Duration.zero);
    expect(repository.sent, hasLength(1));
    expect(controller.sharing, false);
    expect(repository.consents, [true, false]);
  });
  test('ends sharing after a definitive remote rejection', () async {
    repository.failure = const ApiFailure(
      kind: ApiFailureKind.conflict,
      statusCode: 409,
      code: 'TRACKING_ENDED',
      message: 'Ended',
    );
    expect(await controller.start(42), false);
    expect(controller.sharing, false);
    expect(repository.consents, [true, false]);
  });
}
