import 'data/repositories/support_repository.dart';
import 'data/repositories/personal_data_repository.dart';
import 'data/repositories/delivery_expense_repository.dart';
import 'services/firebase_identity_service.dart';
import 'dart:async';
import 'package:meatshop_mobile/providers/auth/auth_provider.dart';
import 'package:meatshop_mobile/ui/screens/initial_screens/splash_screen.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:meatshop_mobile/firebase_options.dart';
import 'package:meatshop_mobile/routes/app_routes.dart';
import 'package:meatshop_mobile/routes/routes_config.dart';
import 'package:meatshop_mobile/providers/providers_config.dart';
import 'package:meatshop_mobile/services/notification_service.dart';
import 'package:meatshop_mobile/services/user_preferences_service.dart';
import 'package:meatshop_mobile/core/config/feature_flags.dart';
import 'package:meatshop_mobile/infra/api_foundation.dart';
import 'package:meatshop_mobile/services/firebase_complementary_services.dart';
import 'core/utils/payment_return_intent.dart';
import 'ui/widgets/payment_return_listener.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }
  if (message.notification == null) {
    await NotificationService.instance.showBackgroundNotification(message);
  }
}

final navigatorKey = GlobalKey<NavigatorState>();
final featureFlags = FeatureFlags.fromEnvironment();
ApiFoundation? apiFoundation;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await FirebaseComplementaryServices.initialize(
    enabled: featureFlags.backendFirebaseServices,
  );
  if (featureFlags.backendAuth ||
      featureFlags.backendMarketplace ||
      featureFlags.backendProfileCart ||
      featureFlags.backendCheckout ||
      featureFlags.backendDelivery ||
      featureFlags.backendRealtime ||
      featureFlags.backendFirebaseServices) {
    apiFoundation = ApiFoundation.fromEnvironment();
    await apiFoundation!.initialize();
  }
  if (apiFoundation != null) {
    AuthService.instance.configure(apiFoundation!.client);
  }
  final notifications = apiFoundation?.notifications;
  if (notifications == null) {
    throw StateError('Notification repository was not initialized.');
  }
  NotificationService.instance.configure(backend: notifications);
  UserPreferencesService.instance.configure(backend: notifications);
  await initializeDateFormatting('pt_BR');
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  runApp(const MeatShopApp());
}

class MeatShopApp extends StatefulWidget {
  const MeatShopApp({super.key});

  @override
  State<MeatShopApp> createState() => _MeatShopAppState();
}

class _MeatShopAppState extends State<MeatShopApp> {
  StreamSubscription<void>? _expiration;
  StreamSubscription<void>? _legalRequirement;
  bool _reviewingLegal = false;
  @override
  void dispose() {
    _expiration?.cancel();
    _legalRequirement?.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _expiration = apiFoundation?.session.expirations.listen((_) {
      final context = navigatorKey.currentContext;
      if (context != null && context.mounted) {
        context.read<AuthProvider>().expireSession(context);
      }
    });
    _legalRequirement = apiFoundation?.client.legalRequirements.stream.listen((
      _,
    ) async {
      final context = navigatorKey.currentContext;
      if (_reviewingLegal || context == null || !context.mounted) return;
      _reviewingLegal = true;
      try {
        await context.read<AuthProvider>().reviewLegalRequirements(context);
      } finally {
        _reviewingLegal = false;
      }
    });
    NotificationService.instance
        .initialize(navigatorKey: navigatorKey)
        .catchError((e) => debugPrint('NotificationService init error: $e'));
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        if (apiFoundation != null) ...[
          Provider<SupportRepository>.value(value: apiFoundation!.support),
          Provider<PersonalDataRepository>.value(
            value: apiFoundation!.personalData,
          ),
          Provider<DeliveryExpenseRepository>.value(
            value: apiFoundation!.deliveryExpenses,
          ),
        ],
        ...ProvidersConfig.providers(
          federatedAuth: apiFoundation?.federatedAuth,
          legal: apiFoundation?.legal,
          marketplace: featureFlags.backendMarketplace
              ? apiFoundation?.marketplace
              : null,
          profile: apiFoundation?.profile,
          addresses: apiFoundation?.addresses,
          cart: apiFoundation?.cart,
          orders: apiFoundation?.orders,
          payments: apiFoundation?.payments,
          delivery: apiFoundation?.delivery,
          chat: apiFoundation?.chat,
          realtime: apiFoundation?.realtime,
          recipes: apiFoundation?.recipes,
          reviews: apiFoundation?.reviews,
          aiAssistant: apiFoundation?.aiAssistant,
          flags: featureFlags,
        ),
      ],
      child: MaterialApp(
        navigatorKey: navigatorKey,
        title: 'MeatShop',
        debugShowCheckedModeBanner: false,
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        supportedLocales: const [Locale('pt', 'BR')],
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFB71C1C)),
        ),
        initialRoute:
            PaymentReturnIntent.accepts(
              Uri.parse(
                WidgetsBinding.instance.platformDispatcher.defaultRouteName,
              ),
            )
            ? WidgetsBinding.instance.platformDispatcher.defaultRouteName
            : AppRoutes.splash,
        builder: (context, child) => PaymentReturnListener(
          navigatorKey: navigatorKey,
          child: child ?? const SizedBox(),
        ),
        routes: buildRoutes(),
        onGenerateRoute: (settings) {
          final uri = Uri.tryParse(settings.name ?? '');
          if (uri != null && PaymentReturnIntent.accepts(uri)) {
            PaymentReturnIntent.instance.remember(uri);
            return MaterialPageRoute(
              builder: (context) => context.read<AuthProvider>().isAuthenticated
                  ? const Scaffold(
                      body: Center(child: Text('Recuperando pagamento…')),
                    )
                  : const SplashPage(),
            );
          }
          return null;
        },
      ),
    );
  }
}
