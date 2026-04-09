import 'package:flutter/material.dart';
import 'package:meatshop_mobile/routes/app_routes.dart';
import 'package:meatshop_mobile/ui/screens/butcher/butcher_screen.dart';
import 'package:meatshop_mobile/ui/screens/cuts/bovine_cuts_screen.dart';
import 'package:meatshop_mobile/ui/screens/initial_screens/splash_screen.dart';
import 'package:meatshop_mobile/ui/screens/initial_screens/welcome_screen.dart';
import 'package:meatshop_mobile/ui/screens/auth/login_screen.dart';
import 'package:meatshop_mobile/ui/screens/auth/register_screen.dart';
import 'package:meatshop_mobile/ui/screens/auth/change_password.dart';
import 'package:meatshop_mobile/ui/screens/auth/select_register_screen.dart';
import 'package:meatshop_mobile/ui/widgets/app_shell.dart';
import 'package:meatshop_mobile/ui/screens/cart/review_order_screen.dart';
import 'package:meatshop_mobile/ui/screens/cuts/swine_cuts_screen.dart';
import 'package:meatshop_mobile/ui/screens/cuts/poultry_cuts_screen.dart';
import 'package:meatshop_mobile/ui/screens/cuts/fish_cuts_screen.dart';

Map<String, WidgetBuilder> buildRoutes() {
  return {
    AppRoutes.splash: (_) => const SplashPage(),
    AppRoutes.welcome: (_) => const WelcomePage(),
    AppRoutes.login: (_) => const LoginPage(),
    AppRoutes.selectRegister: (_) => const SelectRegisterPage(),
    AppRoutes.register: (_) => const RegisterPage(),
    AppRoutes.changePassword: (_) => const ChangePasswordPage(),
    AppRoutes.shell: (_) => const AppShell(),
    AppRoutes.reviewOrder: (_) => const ReviewOrderScreen(),
    AppRoutes.acougues: (_) => const AcouguesScreen(),
    AppRoutes.cortesBovinos: (_) => const BovineCortsScreen(),
    AppRoutes.cortesSuinos: (_) => const SwineCortsScreen(),
    AppRoutes.cortesAves: (_) => const PoultryCortsScreen(),
    AppRoutes.cortesPeixes: (_) => const FishCortsScreen(),
  };
}
