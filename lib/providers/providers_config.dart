import 'package:meatshop_mobile/providers/analytics_consent_provider.dart';
import 'package:meatshop_mobile/providers/cart_provider.dart';
import 'package:meatshop_mobile/services/firebase_complementary_services.dart';
import 'package:meatshop_mobile/providers/delivery/delivery_provider.dart';
import 'package:meatshop_mobile/providers/auth/auth_provider.dart';
import 'package:meatshop_mobile/providers/delivery/vehicle_provider.dart';
import 'package:meatshop_mobile/providers/order_provider.dart';
import 'package:meatshop_mobile/providers/product_review_provider.dart';
import 'package:meatshop_mobile/providers/promotion_provider.dart';
import 'package:meatshop_mobile/providers/review_provider.dart';
import 'package:meatshop_mobile/providers/search_provider.dart';
import 'package:meatshop_mobile/providers/user/address_provider.dart';
import 'package:meatshop_mobile/providers/user/user_provider.dart';
import 'package:meatshop_mobile/providers/unit/unit_provider.dart';
import 'package:meatshop_mobile/providers/user_preferences_provider.dart';
import 'package:meatshop_mobile/services/firebase_identity_service.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';
import 'package:meatshop_mobile/providers/delivery_earnings_provider.dart';
import 'package:meatshop_mobile/providers/recipe_provider.dart';
import '../data/repositories/federated_auth_repository.dart';
import '../data/repositories/marketplace_repository.dart';
import '../data/repositories/marketplace_context.dart';
import '../data/repositories/address_repository.dart';
import '../data/repositories/cart_repository.dart';
import '../data/repositories/profile_repository.dart';
import '../data/repositories/order_repository.dart';
import '../data/repositories/delivery_repository.dart';
import '../data/repositories/chat_repository.dart';
import '../data/repositories/realtime_repository.dart';
import '../data/repositories/recipe_repository.dart';
import '../data/repositories/review_repository.dart';
import '../data/repositories/ai_assistant_repository.dart';
import '../services/business_hours_service.dart';
import '../services/promotion_service.dart';
import '../services/search_service.dart';
import '../services/unit_service.dart';

import '../data/repositories/legal_repository.dart';

class ProvidersConfig {
  static List<SingleChildWidget> providers({
    FederatedAuthRepository? federatedAuth,
    LegalRepository? legal,
    MarketplaceRepository? marketplace,
    ProfileRepository? profile,
    AddressRepository? addresses,
    CartRepository? cart,
    OrderRepository? orders,
    DeliveryRepository? delivery,
    ChatRepository? chat,
    RealtimeRepository? realtime,
    RecipeRepository? recipes,
    ReviewRepository? reviews,
    AiAssistantRepository? aiAssistant,
  }) => [
    Provider<LegalRepository>.value(value: legal!),
    Provider<AiAssistantRepository>.value(value: aiAssistant!),
    Provider<DeliveryRepository>.value(value: delivery!),
    Provider<OrderRepository>.value(value: orders!),
    Provider<BackendRealtimeAccess>.value(
      value: BackendRealtimeAccess(chat: chat, realtime: realtime),
    ),
    Provider<MarketplaceContext>.value(value: MarketplaceContext(marketplace!)),
    ChangeNotifierProvider<AuthProvider>(
      create: (_) =>
          AuthProvider(federatedAuth: federatedAuth!, delivery: delivery),
    ),
    ChangeNotifierProvider<DeliveryProvider>(
      create: (_) => DeliveryProvider(repository: delivery),
    ),
    ChangeNotifierProvider(create: (_) => UserProvider(repository: profile!)),
    ChangeNotifierProvider(
      create: (_) => VehicleProvider(repository: delivery),
    ),
    ChangeNotifierProvider(
      create: (_) => AddressProvider(repository: addresses!),
    ),
    ChangeNotifierProxyProvider<AddressProvider, UnitProvider>(
      create: (_) => UnitProvider(
        unitService: UnitService(marketplace: marketplace),
        hoursService: BusinessHoursService(marketplace: marketplace),
      ),
      update: (_, addressProvider, units) {
        final address = addressProvider.addresses
            .where((a) => a.isDefault)
            .firstOrNull;
        units!.setDeliveryAddress(address?.lat, address?.lng);
        return units;
      },
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
    ChangeNotifierProvider(
      create: (_) => OrderProvider(repository: orders, realtime: realtime),
    ),
    ChangeNotifierProvider(create: (_) => UserPreferencesProvider()),
    ChangeNotifierProvider(
      create: (_) => AnalyticsConsentProvider(
        apply: FirebaseComplementaryServices.setAnalyticsConsent,
      )..load(),
    ),
    ChangeNotifierProvider(create: (_) => RecipeProvider(repository: recipes!)),
    ChangeNotifierProvider(create: (_) => ReviewProvider(repository: reviews!)),
    ChangeNotifierProvider(
      create: (_) => ProductReviewProvider(repository: reviews!),
    ),
    ChangeNotifierProvider(
      create: (_) => DeliveryEarningsProvider(repository: delivery),
    ),
    ChangeNotifierProvider(
      create: (_) => CartProvider(
        uid: AuthService.instance.currentUser?.uid ?? '',
        repository: cart!,
        hoursService: BusinessHoursService(marketplace: marketplace),
      ),
    ),
  ];
}
