import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:meatshop_mobile/routes/app_routes.dart';
import 'package:meatshop_mobile/routes/routes_config.dart';
import 'package:meatshop_mobile/providers/providers_config.dart';

void main() {
  runApp(const MeatShopApp());
}

class MeatShopApp extends StatelessWidget {
  const MeatShopApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: ProvidersConfig.providers,
      child: MaterialApp(
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
