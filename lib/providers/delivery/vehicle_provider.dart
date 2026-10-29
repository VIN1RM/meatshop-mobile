import '../../core/enums/vehicle_type.dart';
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
  int _generation = 0;
  String? error;
  void prepareNewVehicle() {
    _vehicleDocId = null;
    _vehicleInfo = {};
  }

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
    final generation = ++_generation;
    _isLoading = true;
    error = null;
    notifyListeners();
    try {
      final values = await repository.vehicles();
      if (generation != _generation) return;
      _vehicles = values
          .map((item) => <String, dynamic>{...item, '_docId': '${item['id']}'})
          .toList();
      final active =
          _vehicles.where((v) => v['is_active'] == true).firstOrNull ??
          _vehicles.firstOrNull;
      _vehicleInfo = active ?? {};
      _vehicleDocId = active == null ? null : '${active['id']}';
    } catch (_) {
      if (generation == _generation) {
        error = 'Não foi possível carregar os veículos. Tente novamente.';
      }
    } finally {
      if (generation == _generation) {
        _isLoading = false;
        notifyListeners();
      }
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
          'year': int.parse(data['year'] ?? ''),
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
    final type = VehicleType.tryParse(value);
    if (type == null) throw ArgumentError('Tipo de veículo inválido.');
    return type.apiValue;
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

  void clear() {
    ++_generation;
    _vehicleInfo = {};
    _vehicleDocId = null;
    _vehicles = [];
    _isLoading = false;
    notifyListeners();
  }
}
