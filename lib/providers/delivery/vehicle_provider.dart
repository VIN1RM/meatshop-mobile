import 'dart:io';
import 'package:flutter/material.dart';
import 'package:meatshop_mobile/data/repositories/delivery_repository.dart';

class VehicleProvider extends ChangeNotifier {
  VehicleProvider({required this.repository});
  final DeliveryRepository repository;

  Map<String, dynamic> _vehicleInfo = {};
  Map<String, dynamic> get vehicleInfo => _vehicleInfo;

  String? _vehicleDocId;
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<Map<String, dynamic>> _vehicles = [];
  List<Map<String, dynamic>> get vehicles => _vehicles;

  void selectVehicle(Map<String, dynamic> vehicle) {
    _vehicleInfo = vehicle;
    _vehicleDocId = '${vehicle['id'] ?? vehicle['_docId'] ?? ''}';
    notifyListeners();
  }

  Future<void> activateVehicle(String uid, int id) async {
    await repository.activateVehicle(id);
    await loadVehicle(uid);
  }

  Future<void> deleteVehicle(String uid, int id) async {
    await repository.deleteVehicle(id);
    await loadVehicle(uid);
  }

  Future<void> loadVehicle(String uid) async {
    {
      final values = await repository.vehicles();
      _vehicles = values
          .map((item) => <String, dynamic>{...item, '_docId': '${item['id']}'})
          .toList();
      final active = _vehicles.where((v) => v['is_active'] == true);
      if (active.isNotEmpty) {
        _vehicleDocId = '${active.first['id']}';
        _vehicleInfo = active.first;
      } else if (_vehicles.isNotEmpty) {
        _vehicleDocId = '${_vehicles.first['id']}';
        _vehicleInfo = _vehicles.first;
      }
      notifyListeners();
    }
  }

  Future<void> updateVehicle({
    required String uid,
    required Map<String, String> data,
    List<File> newImages = const [],
    List<String> keptUrls = const [],
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      {
        final payload = <String, Object?>{
          'type': _vehicleType(data['type']),
          'model': data['model'] ?? '',
          'plate': (data['plate'] ?? '')
              .replaceAll(RegExp(r'[^A-Za-z0-9]'), '')
              .toUpperCase(),
          'color': data['color'] ?? '',
          'year': int.tryParse(data['year'] ?? '') ?? DateTime.now().year,
        };
        final id = int.tryParse(_vehicleDocId ?? '');
        final saved = id == null
            ? await repository.createVehicle(payload)
            : await repository.updateVehicle(id, payload);
        final savedId = (saved['id'] as num).toInt();
        final previousUrls = List<String>.from(
          _vehicleInfo['photo_urls'] as List? ?? const [],
        );
        for (final url in previousUrls.where(
          (url) => !keptUrls.contains(url),
        )) {
          await repository.deleteVehiclePhoto(savedId, _fileName(url));
        }
        final uploadedUrls = <String>[];
        for (final image in newImages) {
          final name = image.uri.pathSegments.last;
          uploadedUrls.add(
            await repository.uploadVehiclePhoto(
              savedId,
              bytes: await image.readAsBytes(),
              fileName: name,
              contentType: _contentType(name),
            ),
          );
        }
        await repository.activateVehicle(savedId);
        _vehicleDocId = '$savedId';
        _vehicleInfo = <String, dynamic>{
          ...saved,
          'is_active': true,
          'photo_urls': [...keptUrls, ...uploadedUrls],
        };
        await loadVehicle(uid);
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> removeVehicleImage({
    required String uid,
    required String imageUrl,
  }) async {
    {
      final id = int.tryParse(_vehicleDocId ?? '');
      if (id == null) return;
      await repository.deleteVehiclePhoto(id, _fileName(imageUrl));
      final urls = List<String>.from(
        _vehicleInfo['photo_urls'] as List? ?? const [],
      );
      urls.remove(imageUrl);
      _vehicleInfo['photo_urls'] = urls;
      notifyListeners();
    }
  }

  String _vehicleType(String? value) {
    final normalized = (value ?? '').toUpperCase();
    if (normalized.contains('BIKE') || normalized.contains('BICI')) {
      return 'BIKE';
    }
    if (normalized.contains('CAR')) return 'CAR';
    return 'MOTORCYCLE';
  }

  String _fileName(String url) {
    final segments = Uri.tryParse(url)?.pathSegments;
    return segments != null && segments.isNotEmpty
        ? segments.last
        : url.split('/').last;
  }

  String _contentType(String fileName) {
    final extension = fileName.split('.').last.toLowerCase();
    if (extension == 'png') return 'image/png';
    if (extension == 'webp') return 'image/webp';
    return 'image/jpeg';
  }
}
