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
import 'package:meatshop_mobile/core/config/feature_flags.dart';
import 'package:meatshop_mobile/infra/api_foundation.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await NotificationService.instance.showLocalNotification(message);
}

final navigatorKey = GlobalKey<NavigatorState>();
final featureFlags = FeatureFlags.fromEnvironment();
ApiFoundation? apiFoundation;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  if (featureFlags.backendAuth ||
      featureFlags.backendMarketplace ||
      featureFlags.backendProfileCart ||
      featureFlags.backendCheckout ||
      featureFlags.backendDelivery ||
      featureFlags.backendRealtime) {
    apiFoundation = ApiFoundation.fromEnvironment();
    await apiFoundation!.initialize();
  }
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
  @override
  void initState() {
    super.initState();
    NotificationService.instance
        .initialize(navigatorKey: navigatorKey)
        .catchError((e) => debugPrint('NotificationService init error: $e'));
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: ProvidersConfig.providers(
        federatedAuth: apiFoundation?.federatedAuth,
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
        flags: featureFlags,
      ),
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
        initialRoute: AppRoutes.splash,
        routes: buildRoutes(),
      ),
    );
  }
}
