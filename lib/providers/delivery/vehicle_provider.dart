import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'dart:convert';

class VehicleProvider extends ChangeNotifier {
  final _db = FirebaseFirestore.instance;
  final _storage = FirebaseStorage.instance;

  Map<String, dynamic> _vehicleInfo = {};
  Map<String, dynamic> get vehicleInfo => _vehicleInfo;

  String? _vehicleDocId;
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> loadVehicle(String uid) async {
    final snap = await _db
        .collection('delivery_persons')
        .doc(uid)
        .collection('vehicles')
        .where('is_active', isEqualTo: true)
        .limit(1)
        .get();

    if (snap.docs.isNotEmpty) {
      final doc = snap.docs.first;
      _vehicleDocId = doc.id;
      _vehicleInfo = Map<String, dynamic>.from(doc.data());
      notifyListeners();
    }
  }

  Future<void> updateVehicle({
    required String uid,
    required Map<String, String> data,
    List<File> newImages = const [],
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final existingUrls = List<String>.from(_vehicleInfo['photo_urls'] ?? []);
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
}
