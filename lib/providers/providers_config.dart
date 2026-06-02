import 'package:meatshop_mobile/providers/cart_provider.dart';
import 'package:meatshop_mobile/providers/delivery/delivery_provider.dart';
import 'package:meatshop_mobile/providers/auth/auth_provider.dart';
import 'package:meatshop_mobile/providers/delivery/vehicle_provider.dart';
import 'package:meatshop_mobile/providers/payment_provider.dart';
import 'package:meatshop_mobile/providers/promotion_provider.dart';
import 'package:meatshop_mobile/providers/search_provider.dart';
import 'package:meatshop_mobile/providers/user/address_provider.dart';
import 'package:meatshop_mobile/providers/user/user_provider.dart';
import 'package:meatshop_mobile/providers/unit/unit_provider.dart';
import 'package:meatshop_mobile/services/auth_service.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

class ProvidersConfig {
  static List<SingleChildWidget> providers = [
    ChangeNotifierProvider<AuthProvider>(create: (_) => AuthProvider()),
    ChangeNotifierProvider<DeliveryProvider>(create: (_) => DeliveryProvider()),
    ChangeNotifierProvider(create: (_) => UserProvider()),
    ChangeNotifierProvider(create: (_) => VehicleProvider()),
    ChangeNotifierProvider(create: (_) => UnitProvider()),
    ChangeNotifierProvider(create: (_) => AddressProvider()),
    ChangeNotifierProvider(create: (_) => SearchProvider()),
    ChangeNotifierProvider(create: (_) => PromotionProvider()),
    ChangeNotifierProvider(create: (_) => PaymentProvider()),
    ChangeNotifierProvider(
      create: (_) =>
          CartProvider(uid: AuthService.instance.currentUser?.uid ?? ''),
    ),
  ];
}
