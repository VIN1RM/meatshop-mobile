import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:meatshop_mobile/services/vehicle_registration_service.dart';
import 'package:meatshop_mobile/data/repositories/delivery_repository.dart';

class VehicleRepository extends Fake implements DeliveryRepository {
  final List<Map<String, Object?>> saved = [];
  int uploads = 0;
  bool fail = true;
  @override
  Future<Map<String, Object?>> register(String type) async => {};
  @override
  Future<List<Map<String, Object?>>> vehicles() async => saved;
  @override
  Future<Map<String, Object?>> createVehicle(Map<String, Object?> data) async {
    final vehicle = {...data, 'id': 7, 'photo_urls': <String>[]};
    saved.add(vehicle);
    return vehicle;
  }

  @override
  Future<String> uploadVehiclePhoto(
    int id, {
    required Uint8List bytes,
    required String fileName,
    required String contentType,
  }) async {
    expect(id, 7);
    expect(contentType, 'image/png');
    if (fail && uploads == 1) throw StateError('offline');
    uploads++;
    (saved.single['photo_urls'] as List).add(fileName);
    return fileName;
  }
}

void main() {
  test(
    'resumes interrupted vehicle registration without duplicating the vehicle or completed photos',
    () async {
      final repository = VehicleRepository();
      final service = VehicleRegistrationService(repository);
      final photo = base64Encode([137, 80, 78, 71]);
      const data = {
        'type': 'Bicicleta',
        'model': 'Caloi',
        'plate': '',
        'color': 'Preto',
        'year': '2026',
      };
      await expectLater(
        service.register('BIKE', data, photos: [photo, photo, photo]),
        throwsStateError,
      );
      repository.fail = false;
      await service.register('BIKE', data, photos: [photo, photo, photo]);
      expect(repository.saved, hasLength(1));
      expect(repository.uploads, 3);
      expect(
        () => VehicleRegistrationService.type('Patinete'),
        throwsArgumentError,
      );
      expect(
        () => VehicleRegistrationService.type('ON_FOOT'),
        throwsArgumentError,
      );
    },
  );
}
