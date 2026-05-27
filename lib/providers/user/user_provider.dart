import 'dart:io';

import 'package:flutter/material.dart';
import 'package:meatshop_mobile/models/user_model.dart';
import 'package:meatshop_mobile/services/user_service.dart';

class UserProvider extends ChangeNotifier {
  UserModel? _user;
  bool _isLoading = false;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;

  Future<void> loadUser(String uid) async {
    _isLoading = true;
    notifyListeners();

    _user = await UserService.instance.fetchUser(uid);

    _isLoading = false;
    notifyListeners();
  }

  Future<void> updateUser({
    required String uid,
    required String name,
    required String email,
    required String phone,
  }) async {
    await UserService.instance.updateUser(
      uid,
      name: name,
      email: email,
      phone: phone,
    );
    _user = _user?.copyWith(name: name, email: email, phone: phone);
    notifyListeners();
  }

  Future<void> updateAvatar(String uid, File? file) async {
    if (file == null) {
      await UserService.instance.clearAvatar(uid);
      _user = _user?.copyWith(photoUrl: '');
      notifyListeners();
      return;
    }
    final url = await UserService.instance.updateAvatar(uid, file);
    _user = _user?.copyWith(photoUrl: url);
    notifyListeners();
  }

  void clear() {
    _user = null;
    notifyListeners();
  }
}
