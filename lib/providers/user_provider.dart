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
    await UserService.instance.updateUser(uid, name: name, email: email, phone: phone);
    _user = _user?.copyWith(name: name, email: email, phone: phone);
    notifyListeners();
  }

  void clear() {
    _user = null;
    notifyListeners();
  }
}