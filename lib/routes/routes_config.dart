import 'package:flutter/material.dart';
import 'package:meatshop_mobile/routes/app_routes.dart';
import 'package:meatshop_mobile/ui/screens/account/edit_profile_screen.dart';
import 'package:meatshop_mobile/ui/screens/account/saved_addresses_screen.dart';
import 'package:meatshop_mobile/ui/screens/account/saved_payments_screen.dart';
import 'package:meatshop_mobile/ui/screens/account/settings_screen.dart';
import 'package:meatshop_mobile/ui/screens/account/vehicle_settings_screen.dart';
import 'package:meatshop_mobile/ui/screens/auth/forgot_password_screen.dart';
import 'package:meatshop_mobile/ui/screens/auth/mode_selection_screen.dart';
import 'package:meatshop_mobile/ui/screens/butcher/butcher_detail_screen.dart';
import 'package:meatshop_mobile/ui/screens/butcher/butcher_list_screen.dart';
import 'package:meatshop_mobile/ui/screens/butcher/product_detail_screen.dart';
import 'package:meatshop_mobile/ui/screens/account/chat/chat_list_screen.dart';
import 'package:meatshop_mobile/ui/screens/account/chat/chat_screen.dart';
import 'package:meatshop_mobile/ui/screens/cuts/cuts_screen.dart';
import 'package:meatshop_mobile/ui/screens/fallback/mode_switch_screen.dart';
import 'package:meatshop_mobile/ui/screens/initial_screens/splash_screen.dart';
import 'package:meatshop_mobile/ui/screens/initial_screens/welcome_screen.dart';
import 'package:meatshop_mobile/ui/screens/auth/login_screen.dart';
import 'package:meatshop_mobile/ui/screens/auth/register_screen.dart';
import 'package:meatshop_mobile/ui/screens/auth/change_password_screen.dart';
import 'package:meatshop_mobile/ui/screens/auth/select_register_screen.dart';
import 'package:meatshop_mobile/ui/screens/search_screen.dart';
import 'package:meatshop_mobile/ui/widgets/shell/client_shell.dart';
import 'package:meatshop_mobile/ui/screens/recipes/recipe_assistant_screen.dart';
import 'package:meatshop_mobile/ui/screens/recipes/recipe_screen.dart';
import 'package:meatshop_mobile/ui/screens/cart/review_order_screen.dart';
import 'package:meatshop_mobile/ui/screens/delivery/order_tracking_screen%20.dart';
import 'package:meatshop_mobile/ui/widgets/shell/delivery_shell.dart';
import 'package:meatshop_mobile/ui/screens/cart/payment_screen.dart';
import 'package:meatshop_mobile/ui/screens/cart/address_schedule_screen.dart';

Map<String, WidgetBuilder> buildRoutes() {
  return {
    AppRoutes.splash: (_) => const SplashPage(),
    AppRoutes.welcome: (_) => const WelcomePage(),
    AppRoutes.login: (_) => const LoginPage(),
    AppRoutes.selectRegister: (_) => const SelectRegisterPage(),
    AppRoutes.register: (_) => const RegisterPage(),
    AppRoutes.changePassword: (_) => const ChangePasswordPage(),
    AppRoutes.shell: (_) => const AppShell(),
    AppRoutes.reviewOrder: (_) => const Scaffold(
      backgroundColor: Color(0xFF2E2E2E),
      body: Center(
        child: Text(
          'Use o fluxo do carrinho',
          style: TextStyle(color: Colors.white54),
        ),
      ),
    ),
    AppRoutes.acougues: (_) => const AcouguesScreen(),
    AppRoutes.cortesBovinos: (_) =>
        const CutsScreen(title: 'CORTES BOVINOS', categoryName: 'Bovinos'),
    AppRoutes.cortesSuinos: (_) =>
        const CutsScreen(title: 'CORTES SUÍNOS', categoryName: 'Suínos'),
    AppRoutes.cortesAves: (_) =>
        const CutsScreen(title: 'CORTES DE AVES', categoryName: 'Aves'),
    AppRoutes.cortesPeixes: (_) =>
        const CutsScreen(title: 'CORTES DE PEIXE', categoryName: 'Peixes'),
    AppRoutes.deliveries: (_) => const DeliveriesScreen(),
    AppRoutes.chat: (_) => const ChatScreen(),
    AppRoutes.chatList: (_) => const ChatListScreen(),
    AppRoutes.butcherDetail: (_) => const ButcherDetailScreen(),
    AppRoutes.productDetail: (_) => const ProductDetailScreen(),
    AppRoutes.savedAddresses: (_) => const SavedAddressesScreen(),
    AppRoutes.settings: (_) => const SettingsScreen(),
    AppRoutes.savedPayments: (_) => const SavedPaymentsScreen(),
    AppRoutes.modeSelection: (_) => const ModeSelectionPage(),
    AppRoutes.deliveryShell: (_) => const DeliveryShell(),
    AppRoutes.vehicleSettings: (_) => const VehicleSettingsScreen(),
    AppRoutes.modeSwitch: (_) => const ModeSwitchScreen(),
    AppRoutes.paymentOrder: (_) => const Scaffold(
      backgroundColor: Color(0xFF2E2E2E),
      body: Center(
        child: Text(
          'Use o fluxo do carrinho',
          style: TextStyle(color: Colors.white54),
        ),
      ),
    ),
    AppRoutes.editProfile: (_) => const EditProfileScreen(),
    AppRoutes.addressSchedule: (_) => const AddressScheduleScreen(total: 0),
    AppRoutes.recipeTips: (_) => const RecipeTipsScreen(),
    AppRoutes.recipeChat: (_) => const RecipeScreen(),
    AppRoutes.forgotPassword: (_) => const ForgotPasswordPage(),
    AppRoutes.search: (_) => const SearchScreen(),
  };
}
