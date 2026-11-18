import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:meatshop_mobile/routes/app_routes.dart';
import 'package:meatshop_mobile/services/onboarding_service.dart';
import 'package:meatshop_mobile/ui/screens/initial_screens/welcome_screen.dart';
import 'package:meatshop_mobile/ui/screens/onboarding/onboarding_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'first access presents both profiles and opens authentication directly',
    (tester) async {
      // Keep this smoke journey isolated from the installation's real preferences.
      SharedPreferences.setMockInitialValues({});
      await tester.pumpWidget(
        MaterialApp(
          home: const WelcomePage(),
          routes: {
            AppRoutes.welcome: (_) => const WelcomePage(),
            AppRoutes.login: (_) =>
                Scaffold(appBar: AppBar(title: const Text('Login de destino'))),
          },
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Para clientes e entregadores'), findsOneWidget);

      await tester.drag(find.byType(PageView), const Offset(-500, 0));
      await tester.pumpAndSettle();
      expect(find.text('Entrega ou retirada'), findsOneWidget);
      await tester.tap(find.text('PRÓXIMO'));
      await tester.pumpAndSettle();
      expect(find.text('Também é para quem entrega'), findsOneWidget);
      await tester.tap(find.text('PRÓXIMO'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Já tenho conta'));
      await tester.pumpAndSettle();
      expect(find.text('Login de destino'), findsOneWidget);
      expect(await OnboardingService().shouldShowIntroduction(), isFalse);

      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(find.byType(OnboardingScreen), findsNothing);
      await tester.ensureVisible(find.text('Conhecer o MeatShop'));
      await tester.tap(find.text('Conhecer o MeatShop'));
      await tester.pumpAndSettle();
      expect(find.byType(OnboardingScreen), findsOneWidget);
      await tester.tap(find.byTooltip('Fechar apresentação'));
      await tester.pumpAndSettle();
      expect(find.byType(OnboardingScreen), findsNothing);
      await tester.pumpWidget(const SizedBox());
    },
  );
}
