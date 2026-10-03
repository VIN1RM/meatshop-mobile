import 'package:geolocator/geolocator.dart';

abstract interface class DiscoveryLocationSource {
  Future<({double latitude, double longitude})> current();
}

/// One foreground fix, requested only after the customer chooses to use GPS.
class GeolocatorDiscoverySource implements DiscoveryLocationSource {
  @override
  Future<({double latitude, double longitude})> current() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      throw StateError('Ative o GPS ou escolha um ponto no mapa.');
    }
    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission != LocationPermission.always &&
        permission != LocationPermission.whileInUse) {
      throw StateError(
        'Sem permissão de localização. Escolha um ponto no mapa ou use seu endereço salvo.',
      );
    }
    final point = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        timeLimit: Duration(seconds: 15),
      ),
    );
    if (!point.latitude.isFinite ||
        !point.longitude.isFinite ||
        point.latitude.abs() > 90 ||
        point.longitude.abs() > 180) {
      throw StateError('Localização indisponível. Escolha um ponto no mapa.');
    }
    return (latitude: point.latitude, longitude: point.longitude);
  }
}
