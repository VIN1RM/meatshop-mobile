import '../data/repositories/support_repository.dart';
import '../data/repositories/personal_data_repository.dart';
import '../data/repositories/delivery_expense_repository.dart';
import 'repositories/http_support_repository.dart';
import 'repositories/http_personal_data_repository.dart';
import 'repositories/http_delivery_expense_repository.dart';
import '../core/auth/session_coordinator.dart';
import '../core/config/api_config.dart';
import '../data/repositories/backend_connection_repository.dart';
import 'auth/backend_session_refresher.dart';
import 'auth/secure_key_value_store.dart';
import 'auth/secure_session_store.dart';
import 'http/api_client.dart';
import 'http/json_http_transport.dart';
import 'repositories/http_backend_connection_repository.dart';
import '../data/repositories/federated_auth_repository.dart';
import 'repositories/http_federated_auth_repository.dart';
import '../data/repositories/marketplace_repository.dart';
import 'repositories/http_marketplace_repository.dart';
import '../data/repositories/address_repository.dart';
import '../data/repositories/cart_repository.dart';
import '../data/repositories/profile_repository.dart';
import 'repositories/http_address_repository.dart';
import 'repositories/http_cart_repository.dart';
import 'repositories/http_profile_repository.dart';
import '../data/repositories/order_repository.dart';
import '../data/repositories/payment_repository.dart';
import 'repositories/http_order_repository.dart';
import 'repositories/http_payment_repository.dart';
import '../data/repositories/delivery_repository.dart';
import 'repositories/http_delivery_repository.dart';
import '../data/repositories/chat_repository.dart';
import 'repositories/http_chat_repository.dart';
import 'realtime/backend_realtime_client.dart';
import '../services/firebase_complementary_services.dart';
import '../data/repositories/notification_repository.dart';
import 'repositories/http_notification_repository.dart';
import '../data/repositories/recipe_repository.dart';
import '../data/repositories/review_repository.dart';
import 'repositories/http_recipe_repository.dart';
import 'repositories/http_review_repository.dart';
import '../data/repositories/ai_assistant_repository.dart';
import 'repositories/http_ai_assistant_repository.dart';

import '../data/repositories/legal_repository.dart';
import 'repositories/http_legal_repository.dart';

final class ApiFoundation {
  ApiFoundation._({
    required JsonHttpTransport transport,
    required this.session,
    required this.backendConnection,
    required this.federatedAuth,
    required this.legal,
    required this.client,
    required this.marketplace,
    required this.profile,
    required this.addresses,
    required this.cart,
    required this.orders,
    required this.payments,
    required this.delivery,
    required this.chat,
    required this.realtime,
    required this.notifications,
    required this.recipes,
    required this.reviews,
    required this.aiAssistant,
    required this.support,
    required this.personalData,
    required this.deliveryExpenses,
  }) : _transport = transport;

  factory ApiFoundation.fromEnvironment() {
    final config = ApiConfig.fromEnvironment();
    final transport = JsonHttpTransport(
      config: config,
      requestHeaders: () => FirebaseComplementaryServices.requestHeaders(
        requireAppCheck: config.environment != AppEnvironment.development,
      ),
    );
    final secureStorage = FlutterSecureKeyValueStore();
    final session = SessionCoordinator(
      store: SecureSessionStore(secureStorage),
      refresher: BackendSessionRefresher(transport),
    );
    final client = ApiClient(transport: transport, session: session);
    return ApiFoundation._(
      transport: transport,
      session: session,
      backendConnection: HttpBackendConnectionRepository(client),
      legal: HttpLegalRepository(client),
      client: client,
      federatedAuth: HttpFederatedAuthRepository(
        transport: transport,
        client: client,
        session: session,
      ),
      marketplace: HttpMarketplaceRepository(client, config),
      profile: HttpProfileRepository(client, config),
      addresses: HttpAddressRepository(client),
      cart: HttpCartRepository(client),
      orders: HttpOrderRepository(
        client,
        pendingStorage: FlutterSecureKeyValueStore(),
      ),
      payments: HttpPaymentRepository(client),
      delivery: HttpDeliveryRepository(client, config),
      chat: HttpChatRepository(client),
      realtime: BackendRealtimeClient(config: config, session: session),
      notifications: HttpNotificationRepository(client),
      recipes: HttpRecipeRepository(client),
      reviews: HttpReviewRepository(
        client,
        HttpMarketplaceRepository(client, config),
      ),
      support: HttpSupportRepository(client),
      personalData: HttpPersonalDataRepository(client),
      deliveryExpenses: HttpDeliveryExpenseRepository(client),
      aiAssistant: HttpAiAssistantRepository(client, secureStorage),
    );
  }

  final JsonHttpTransport _transport;
  final SessionCoordinator session;
  final BackendConnectionRepository backendConnection;
  final FederatedAuthRepository federatedAuth;
  final LegalRepository legal;
  final ApiClient client;
  final MarketplaceRepository marketplace;
  final ProfileRepository profile;
  final AddressRepository addresses;
  final CartRepository cart;
  final OrderRepository orders;
  final PaymentRepository payments;
  final DeliveryRepository delivery;
  final ChatRepository chat;
  final BackendRealtimeClient realtime;
  final NotificationRepository notifications;
  final RecipeRepository recipes;
  final ReviewRepository reviews;
  final AiAssistantRepository aiAssistant;
  final SupportRepository support;
  final PersonalDataRepository personalData;
  final DeliveryExpenseRepository deliveryExpenses;

  Future<void> initialize() => session.initialize();

  void dispose() {
    client.legalRequirements.close();
    realtime.dispose();
    _transport.close();
  }
}
