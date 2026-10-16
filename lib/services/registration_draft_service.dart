import 'dart:convert';
import 'dart:io';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class RegistrationDraftService {
  static const _storage = FlutterSecureStorage();
  static String _key(String uid) => 'registration.draft.v1.$uid';
  static Future<void> save(String uid, Map<String, dynamic> data) async {
    final vehicle = data['vehicle'] as Map<String, dynamic>?;
    final photos = <String>[];
    for (final file in vehicle?['newImages'] as List? ?? const []) {
      if (file is File && await file.exists()) {
        photos.add(base64Encode(await file.readAsBytes()));
      }
    }
    await _storage.write(
      key: _key(uid),
      value: jsonEncode({
        ...data,
        'savedAt': DateTime.now().toUtc().toIso8601String(),
        if (vehicle != null) 'vehicle': {...vehicle}..remove('newImages'),
        'photos': photos,
      }),
    );
  }

  static Future<Map<String, dynamic>?> read(String uid) async {
    final raw = await _storage.read(key: _key(uid));
    if (raw == null) return null;
    try {
      final draft = Map<String, dynamic>.from(jsonDecode(raw) as Map);
      final savedAt = DateTime.tryParse('${draft['savedAt'] ?? ''}');
      if (savedAt == null ||
          DateTime.now().difference(savedAt) > const Duration(days: 7)) {
        await clear(uid);
        return null;
      }
      return draft;
    } on FormatException {
      await clear(uid);
      return null;
    }
  }

  static Future<void> clear(String uid) => _storage.delete(key: _key(uid));
}
