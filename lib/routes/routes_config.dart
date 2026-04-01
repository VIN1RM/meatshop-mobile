import 'package:flutter/material.dart';
import 'package:meatshop_mobile/routes/app_routes.dart';
import 'package:meatshop_mobile/ui/screens/initial_screens/splash_screen.dart';
import 'package:meatshop_mobile/ui/screens/initial_screens/welcome_screen.dart';
import 'package:meatshop_mobile/ui/screens/auth/login_screen.dart';
import 'package:meatshop_mobile/ui/screens/auth/register_screen.dart';
import 'package:meatshop_mobile/ui/screens/auth/change_password.dart';
import 'package:meatshop_mobile/ui/screens/auth/select_register_screen.dart';
import 'package:meatshop_mobile/ui/screens/home/home_screen.dart';

Map<String, WidgetBuilder> buildRoutes() {
  return {
    AppRoutes.splash: (_) => const SplashPage(),
    AppRoutes.welcome: (_) => const WelcomePage(),
    AppRoutes.login: (_) => const LoginPage(),
    AppRoutes.selectRegister: (_) => const SelectRegisterPage(),
    AppRoutes.register: (_) => const RegisterPage(),
    AppRoutes.changePassword: (_) => const ChangePasswordPage(),
    AppRoutes.home: (_) => const HomePage(),
  };
}