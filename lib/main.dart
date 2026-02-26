import 'package:flutter/material.dart';
import 'package:meatshop_mobile/ui/screens/initial_screens/splash_screen.dart';

void main() {
  runApp(const MeatShopApp());
}

class MeatShopApp extends StatelessWidget {
  const MeatShopApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MeatShop',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFB71C1C), // vermelho meat style
        ),
      ),
      home: const SplashPage(),
    );
  }
}