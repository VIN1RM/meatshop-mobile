import '../core/enums/vehicle_type.dart';
import '../core/utils/field_validations.dart';
import 'dart:convert';
import 'dart:io';
import '../data/repositories/delivery_repository.dart';

final class VehicleRegistrationService {
  VehicleRegistrationService(this.repository);
  final DeliveryRepository repository;
  static String type(String value) {
    final vehicle = VehicleType.tryParse(value);
    if (vehicle == null) throw ArgumentError('Tipo de veículo inválido.');
    return vehicle.apiValue;
  }

  static String plate(Object? value) =>
      '${value ?? ''}'.replaceAll(RegExp(r'[^A-Za-z0-9]'), '').toUpperCase();
  Future<void> register(
    String selected,
    Map<String, dynamic> data, {
    List<String> photos = const [],
  }) async {
    final category = type('${data['type'] ?? selected}');
    final year = int.tryParse('${data['year'] ?? ''}');
    if (FieldValidations.vehicleYear('${data['year'] ?? ''}') != null) {
      throw ArgumentError('Informe o ano do veículo.');
    }
    await repository.register(category);
    final vehicles = await repository.vehicles();
    final found = vehicles
        .where(
          (v) =>
              plate(v['plate']) == plate(data['plate']) &&
              v['type'] == category &&
              v['model'] == data['model'],
        )
        .firstOrNull;
    final vehicle =
        found ??
        await repository.createVehicle({
          'type': category,
          'model': '${data['model'] ?? ''}',
          'plate': plate(data['plate']),
          'color': '${data['color'] ?? ''}',
          'year': year,
        });
    await _upload(vehicle, data['newImages'] as List? ?? const [], photos);
  }

  Future<void> _upload(
    Map<String, Object?> vehicle,
    List files,
    List<String> photos,
  ) async {
    final existing = (vehicle['photo_urls'] as List? ?? const []).length;
    final total = photos.isNotEmpty ? photos.length : files.length;
    for (var index = existing; index < total; index++) {
      final file = photos.isEmpty ? files[index] as File : null;
      final bytes = photos.isNotEmpty
          ? base64Decode(photos[index])
          : await file!.readAsBytes();
      final extension = bytes.length > 3 && bytes[0] == 137 && bytes[1] == 80
          ? 'png'
          : bytes.length > 12 &&
                ascii.decode(bytes.sublist(0, 4), allowInvalid: true) == 'RIFF'
          ? 'webp'
          : 'jpg';
      final name = 'registration-$index.$extension';
      await repository.uploadVehiclePhoto(
        (vehicle['id'] as num).toInt(),
        bytes: bytes,
        fileName: name,
        contentType: extension == 'png'
            ? 'image/png'
            : extension == 'webp'
            ? 'image/webp'
            : 'image/jpeg',
      );
    }
  }
}
