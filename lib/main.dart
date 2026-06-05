import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:meatshop_mobile/firebase_options.dart';
import 'package:meatshop_mobile/routes/app_routes.dart';
import 'package:meatshop_mobile/routes/routes_config.dart';
import 'package:meatshop_mobile/providers/providers_config.dart';
import 'package:meatshop_mobile/services/notification_service.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await NotificationService.instance.showLocalNotification(message);
}

final navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
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
      providers: ProvidersConfig.providers,
      child: MaterialApp(
        navigatorKey: navigatorKey,
        title: 'MeatShop',
        debugShowCheckedModeBanner: false,
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
