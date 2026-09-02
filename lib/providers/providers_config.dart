import 'package:meatshop_mobile/providers/cart_provider.dart';
import 'package:meatshop_mobile/providers/delivery/delivery_provider.dart';
import 'package:meatshop_mobile/providers/auth/auth_provider.dart';
import 'package:meatshop_mobile/providers/delivery/vehicle_provider.dart';
import 'package:meatshop_mobile/providers/order_provider.dart';
import 'package:meatshop_mobile/providers/payment_provider.dart';
import 'package:meatshop_mobile/providers/product_review_provider.dart';
import 'package:meatshop_mobile/providers/promotion_provider.dart';
import 'package:meatshop_mobile/providers/review_provider.dart';
import 'package:meatshop_mobile/providers/search_provider.dart';
import 'package:meatshop_mobile/providers/user/address_provider.dart';
import 'package:meatshop_mobile/providers/user/user_provider.dart';
import 'package:meatshop_mobile/providers/unit/unit_provider.dart';
import 'package:meatshop_mobile/providers/user_preferences_provider.dart';
import 'package:meatshop_mobile/services/auth_service.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:meatshop_mobile/providers/delivery_earnings_provider.dart';
import 'package:meatshop_mobile/providers/recipe_provider.dart';
import '../core/config/feature_flags.dart';
import '../data/repositories/federated_auth_repository.dart';
import '../data/repositories/marketplace_repository.dart';
import '../data/repositories/marketplace_context.dart';
import '../data/repositories/address_repository.dart';
import '../data/repositories/cart_repository.dart';
import '../data/repositories/profile_repository.dart';
import '../services/business_hours_service.dart';
import '../services/promotion_service.dart';
import '../services/search_service.dart';
import '../services/unit_service.dart';

class ProvidersConfig {
  static List<SingleChildWidget> providers({
    FederatedAuthRepository? federatedAuth,
    MarketplaceRepository? marketplace,
    ProfileRepository? profile,
    AddressRepository? addresses,
    CartRepository? cart,
    FeatureFlags flags = const FeatureFlags(
      backendAuth: false,
      backendMarketplace: false,
      backendProfileCart: false,
    ),
  }) => [
    Provider<MarketplaceContext>.value(value: MarketplaceContext(marketplace)),
    ChangeNotifierProvider<AuthProvider>(
      create: (_) => AuthProvider(federatedAuth: federatedAuth, flags: flags),
    ),
    ChangeNotifierProvider<DeliveryProvider>(create: (_) => DeliveryProvider()),
    ChangeNotifierProvider(
      create: (_) =>
          UserProvider(repository: flags.backendProfileCart ? profile : null),
    ),
    ChangeNotifierProvider(create: (_) => VehicleProvider()),
    ChangeNotifierProvider(
      create: (_) => UnitProvider(
        unitService: UnitService(marketplace: marketplace),
        hoursService: BusinessHoursService(marketplace: marketplace),
      ),
    ),
    ChangeNotifierProvider(
      create: (_) => AddressProvider(
        repository: flags.backendProfileCart ? addresses : null,
      ),
    ),
    ChangeNotifierProvider(
      create: (_) =>
          SearchProvider(service: SearchService(marketplace: marketplace)),
    ),
    ChangeNotifierProvider(
      create: (_) => PromotionProvider(
        service: PromotionService(marketplace: marketplace),
        unitService: UnitService(marketplace: marketplace),
      ),
    ),
    ChangeNotifierProvider(create: (_) => PaymentProvider()),
    ChangeNotifierProvider(create: (_) => OrderProvider()),
    ChangeNotifierProvider(create: (_) => UserPreferencesProvider()),
    ChangeNotifierProvider(create: (_) => RecipeProvider()),
    ChangeNotifierProvider(create: (_) => ReviewProvider()),
    ChangeNotifierProvider(create: (_) => ProductReviewProvider()),
    ChangeNotifierProvider(
      create: (_) => DeliveryEarningsProvider(
        deliveryPersonId: AuthService.instance.currentUser?.uid ?? '',
      ),
    ),
    ChangeNotifierProvider(
      create: (_) => CartProvider(
        uid: AuthService.instance.currentUser?.uid ?? '',
        repository: flags.backendProfileCart ? cart : null,
        hoursService: BusinessHoursService(marketplace: marketplace),
      ),
    ),
  ];
}
