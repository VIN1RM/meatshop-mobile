import 'package:flutter/material.dart';
import 'package:meatshop_mobile/routes/app_routes.dart';

class AuthProvider extends ChangeNotifier {
  bool _isAuthenticated = false;

  bool get isAuthenticated => _isAuthenticated;

  Future<void> login({
    required BuildContext context,
    required String email,
    required String password,
  }) async {
    await Future.delayed(const Duration(seconds: 2));

    _isAuthenticated = true;
    notifyListeners();

    Navigator.of(context).pushReplacementNamed(AppRoutes.home);
  }

  void logout(BuildContext context) {
    _isAuthenticated = false;
    notifyListeners();

    Navigator.of(
      context,
    ).pushNamedAndRemoveUntil(AppRoutes.login, (route) => false);
  }
}
