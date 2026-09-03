import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:meatshop_mobile/data/repositories/delivery_repository.dart';

class VehicleProvider extends ChangeNotifier {
  VehicleProvider({this.repository});
  final DeliveryRepository? repository;
  final _db = FirebaseFirestore.instance;
  final _storage = FirebaseStorage.instance;

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
    if (repository == null) return;
    await repository!.activateVehicle(id);
    await loadVehicle(uid);
  }

  Future<void> deleteVehicle(String uid, int id) async {
    if (repository == null) return;
    await repository!.deleteVehicle(id);
    await loadVehicle(uid);
  }

  Future<void> loadVehicle(String uid) async {
    if (repository != null) {
      final values = await repository!.vehicles();
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
      return;
    }
    final snap = await _db
        .collection('delivery_persons')
        .doc(uid)
        .collection('vehicles')
        .orderBy('created_at', descending: false)
        .get();

    _vehicles = snap.docs.map((doc) {
      final data = Map<String, dynamic>.from(doc.data());
      data['_docId'] = doc.id;
      return data;
    }).toList();

    final active = _vehicles.where((v) => v['is_active'] == true);
    if (active.isNotEmpty) {
      _vehicleDocId = active.first['_docId'];
      _vehicleInfo = active.first;
    } else if (_vehicles.isNotEmpty) {
      _vehicleDocId = _vehicles.first['_docId'];
      _vehicleInfo = _vehicles.first;
    }

    notifyListeners();
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
      if (repository != null) {
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
            ? await repository!.createVehicle(payload)
            : await repository!.updateVehicle(id, payload);
        final savedId = (saved['id'] as num).toInt();
        await repository!.activateVehicle(savedId);
        _vehicleDocId = '$savedId';
        _vehicleInfo = <String, dynamic>{
          ...saved,
          'is_active': true,
          'photo_urls': keptUrls,
        };
        await loadVehicle(uid);
        return;
      }
      final existingUrls = keptUrls;
      final uploadedUrls = await _uploadImages(uid, newImages);
      final allUrls = [...existingUrls, ...uploadedUrls];

      final payload = {
        'type': data['type'] ?? '',
        'model': data['model'] ?? '',
        'plate': data['plate'] ?? '',
        'color': data['color'] ?? '',
        'year': data['year'] ?? '',
        'photo_urls': allUrls,
        'is_active': true,
      };

      if (_vehicleDocId != null) {
        await _db
            .collection('delivery_persons')
            .doc(uid)
            .collection('vehicles')
            .doc(_vehicleDocId)
            .update(payload);
      } else {
        final ref = await _db
            .collection('delivery_persons')
            .doc(uid)
            .collection('vehicles')
            .add({...payload, 'created_at': FieldValue.serverTimestamp()});
        _vehicleDocId = ref.id;
      }

      _vehicleInfo = payload;
      notifyListeners();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> removeVehicleImage({
    required String uid,
    required String imageUrl,
  }) async {
    if (repository != null) {
      final urls = List<String>.from(_vehicleInfo['photo_urls'] ?? const []);
      urls.remove(imageUrl);
      _vehicleInfo['photo_urls'] = urls;
      notifyListeners();
      return;
    }
    final urls = List<String>.from(_vehicleInfo['photo_urls'] ?? []);
    urls.remove(imageUrl);

    try {
      await _storage.refFromURL(imageUrl).delete();
    } catch (_) {}

    await _db
        .collection('delivery_persons')
        .doc(uid)
        .collection('vehicles')
        .doc(_vehicleDocId)
        .update({'photo_urls': urls});

    _vehicleInfo['photo_urls'] = urls;
    notifyListeners();
  }

  Future<List<String>> _uploadImages(String uid, List<File> files) async {
    final urls = <String>[];
    for (final file in files) {
      final bytes = await file.readAsBytes();
      final base64Str = base64Encode(bytes);
      urls.add('data:image/jpeg;base64,$base64Str');
    }
    return urls;
  }

  String _vehicleType(String? value) {
    final normalized = (value ?? '').toUpperCase();
    if (normalized.contains('BIKE') || normalized.contains('BICI')) {
      return 'BIKE';
    }
    if (normalized.contains('CAR')) return 'CAR';
    return 'MOTORCYCLE';
  }
}
