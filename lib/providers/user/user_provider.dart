import 'dart:io';

import 'package:flutter/material.dart';

import '../../data/repositories/profile_repository.dart';
import '../../models/user_model.dart';

class UserProvider extends ChangeNotifier {
  UserProvider({required ProfileRepository repository})
    : _repository = repository;

  final ProfileRepository _repository;
  UserModel? _user;
  bool _isLoading = false;
  String? _error;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadUser(String uid) async {
    _setLoading(true);
    try {
      _user = await _repository.getProfile();
    } catch (error) {
      _error = 'Não foi possível carregar seu perfil.';
      debugPrint('[UserProvider] load error: $error');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updateUser({
    required String uid,
    required String name,
    required String email,
    required String phone,
  }) async {
    _error = null;
    try {
      _user = await _repository.updateProfile(
        name: name,
        email: email,
        phone: phone,
      );
      notifyListeners();
    } catch (error) {
      _error = 'Não foi possível atualizar seu perfil.';
      notifyListeners();
      rethrow;
    }
  }

  Future<void> updateAvatar(String uid, File? file) async {
    _error = null;
    try {
      final photoUrl = file == null
          ? await _clearAvatar(uid)
          : await _uploadAvatar(uid, file);
      _user = _user?.copyWith(photoUrl: photoUrl);
      notifyListeners();
    } catch (error) {
      _error = 'Não foi possível atualizar sua foto.';
      notifyListeners();
      rethrow;
    }
  }

  Future<String> _uploadAvatar(String uid, File file) async {
    return _repository.uploadAvatar(
      bytes: await file.readAsBytes(),
      fileName: file.uri.pathSegments.last,
      contentType: _imageContentType(file.path),
    );
  }

  Future<String> _clearAvatar(String uid) async {
    await _repository.clearAvatar();
    return '';
  }

  String _imageContentType(String path) {
    final extension = path.split('.').last.toLowerCase();
    return switch (extension) {
      'png' => 'image/png',
      'webp' => 'image/webp',
      'gif' => 'image/gif',
      _ => 'image/jpeg',
    };
  }

  void _setLoading(bool value) {
    _isLoading = value;
    if (value) _error = null;
    notifyListeners();
  }

  void clear() {
    _user = null;
    _error = null;
    notifyListeners();
  }
}
