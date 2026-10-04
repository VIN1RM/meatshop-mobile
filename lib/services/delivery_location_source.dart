import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

abstract interface class DeliveryLocationSource {
  Future<bool> enabled();
  Future<LocationPermission> permission();
  Future<LocationPermission> requestPermission();
  Stream<Position> positions();
  Future<Position> current();
}

class GeolocatorDeliverySource implements DeliveryLocationSource {
  @override
  Future<bool> enabled() => Geolocator.isLocationServiceEnabled();
  @override
  Future<LocationPermission> permission() => Geolocator.checkPermission();
  @override
  Future<LocationPermission> requestPermission() =>
      Geolocator.requestPermission();

  LocationSettings get settings {
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      return AndroidSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 0,
        intervalDuration: const Duration(seconds: 10),
        foregroundNotificationConfig: const ForegroundNotificationConfig(
          notificationTitle: 'Entrega em andamento',
          notificationText:
              'Sua localização está sendo compartilhada. Abra o MeatShop para pausar.',
          enableWakeLock: true,
        ),
      );
    }
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.iOS) {
      return AppleSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 0,
        activityType: ActivityType.automotiveNavigation,
        pauseLocationUpdatesAutomatically: false,
        showBackgroundLocationIndicator: true,
        allowBackgroundLocationUpdates: true,
      );
    }
    return const LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 0,
    );
  }

  @override
  Stream<Position> positions() =>
      Geolocator.getPositionStream(locationSettings: settings);
  @override
  Future<Position> current() => Geolocator.getCurrentPosition(
    locationSettings: const LocationSettings(
      accuracy: LocationAccuracy.high,
      timeLimit: Duration(seconds: 15),
    ),
  );
}
