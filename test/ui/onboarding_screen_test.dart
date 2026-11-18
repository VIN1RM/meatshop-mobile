import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meatshop_mobile/routes/app_routes.dart';
import 'package:meatshop_mobile/services/onboarding_service.dart';
import 'package:meatshop_mobile/ui/screens/initial_screens/welcome_screen.dart';
import 'package:meatshop_mobile/ui/screens/onboarding/onboarding_screen.dart';
import 'package:meatshop_mobile/ui/widgets/buttons_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';

Widget app({
  Widget home = const OnboardingScreen(),
  double textScale = 1,
  bool reducedMotion = false,
}) => MaterialApp(
  builder: (context, child) => MediaQuery(
    data: MediaQuery.of(context).copyWith(
      textScaler: TextScaler.linear(textScale),
      disableAnimations: reducedMotion,
    ),
    child: child!,
  ),
  home: home,
  routes: {
    AppRoutes.welcome: (_) => const WelcomePage(),
    AppRoutes.login: (_) => const Scaffold(body: Text('Login de destino')),
    AppRoutes.selectRegister: (_) =>
        const Scaffold(body: Text('Cadastro de destino')),
  },
);

Future<void> lastPage(WidgetTester tester) async {
  for (var i = 0; i < 3; i++) {
    await tester.tap(find.text('PRÓXIMO'));
    await tester.pumpAndSettle();
  }
}

class ControlledOnboardingService extends OnboardingService {
  Completer<void> pending = Completer<void>();
  int saves = 0;

  @override
  Future<void> completeIntroduction() async {
    saves++;
    await pending.future;
    await super.completeIntroduction();
  }
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets(
    'first access opens the introduction without showing the welcome carousel',
    (tester) async {
      await tester.pumpWidget(app(home: const WelcomePage()));
      await tester.pumpAndSettle();
      expect(find.byType(OnboardingScreen), findsOneWidget);
      expect(find.text('Para clientes e entregadores'), findsOneWidget);
      expect(find.text('Conhecer o MeatShop'), findsNothing);
      expect(find.byType(PageView), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
    },
  );

  testWidgets(
    'skip persists completion and a subsequent launch opens welcome',
    (tester) async {
      await tester.pumpWidget(app());
      await tester.tap(find.text('Pular'));
      await tester.pumpAndSettle();
      expect(find.byType(OnboardingScreen), findsNothing);
      expect(find.text('CRIAR CONTA'), findsOneWidget);
      expect(find.text('Já tenho conta'), findsOneWidget);
      expect(await OnboardingService().shouldShowIntroduction(), isFalse);
      await tester.pumpWidget(const SizedBox());
      await tester.pumpWidget(app(home: const WelcomePage()));
      await tester.pumpAndSettle();
      expect(find.byType(OnboardingScreen), findsNothing);
      await tester.pumpWidget(const SizedBox());
    },
  );

  for (final destination in ['CRIAR CONTA', 'Já tenho conta']) {
    testWidgets('final action $destination navigates directly and only once', (
      tester,
    ) async {
      await tester.pumpWidget(app());
      await lastPage(tester);
      final text = destination == 'CRIAR CONTA'
          ? 'Cadastro de destino'
          : 'Login de destino';
      final callback = destination == 'CRIAR CONTA'
          ? tester.widget<PrimaryButton>(find.byType(PrimaryButton)).onPressed!
          : tester
                .widget<TextButton>(
                  find.widgetWithText(TextButton, destination),
                )
                .onPressed!;
      callback();
      callback();
      await tester.pumpAndSettle();
      expect(find.text(text), findsOneWidget);
      expect(await OnboardingService().shouldShowIntroduction(), isFalse);
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(find.byType(WelcomePage), findsOneWidget);
      expect(find.byType(OnboardingScreen), findsNothing);
      await tester.pumpWidget(const SizedBox());
    });
  }

  testWidgets(
    'system back returns to the previous slide then finishes safely',
    (tester) async {
      await tester.pumpWidget(app());
      await tester.tap(find.text('PRÓXIMO'));
      await tester.pumpAndSettle();
      expect(find.text('Seu pedido, do seu jeito'), findsOneWidget);
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(find.text('Bem-vindo ao MeatShop'), findsOneWidget);
      expect(await OnboardingService().shouldShowIntroduction(), isTrue);
      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      expect(find.byType(OnboardingScreen), findsNothing);
      expect(await OnboardingService().shouldShowIntroduction(), isFalse);
      await tester.pumpWidget(const SizedBox());
    },
  );

  testWidgets(
    'review closes to the original screen without completing or logging out',
    (tester) async {
      await tester.pumpWidget(
        app(
          home: Builder(
            builder: (context) => Scaffold(
              body: TextButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const OnboardingScreen(review: true),
                  ),
                ),
                child: const Text('Configurações de origem'),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Configurações de origem'));
      await tester.pumpAndSettle();
      await lastPage(tester);
      expect(find.text('CRIAR CONTA'), findsNothing);
      await tester.tap(find.text('CONCLUIR'));
      await tester.pumpAndSettle();
      expect(find.text('Configurações de origem'), findsOneWidget);
      expect(await OnboardingService().shouldShowIntroduction(), isTrue);
    },
  );

  testWidgets(
    'progress is announced and reduced motion changes page immediately',
    (tester) async {
      final semantics = tester.ensureSemantics();
      await tester.pumpWidget(app(reducedMotion: true));
      expect(find.bySemanticsLabel('Etapa 1 de 4'), findsOneWidget);
      await tester.tap(find.text('PRÓXIMO'));
      await tester.pump();
      expect(find.bySemanticsLabel('Etapa 2 de 4'), findsOneWidget);
      semantics.dispose();
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'a failed save stays on screen, blocks duplicate exits and allows retry',
    (tester) async {
      final service = ControlledOnboardingService();
      await tester.pumpWidget(app(home: OnboardingScreen(service: service)));
      final skip = tester
          .widget<TextButton>(find.widgetWithText(TextButton, 'Pular'))
          .onPressed!;
      skip();
      skip();
      await tester.pump();
      await tester.binding.handlePopRoute();
      expect(service.saves, 1);
      expect(find.byType(OnboardingScreen), findsOneWidget);
      service.pending.completeError(StateError('disk unavailable'));
      await tester.pumpAndSettle();
      expect(
        find.text('Não foi possível salvar. Tente novamente.'),
        findsOneWidget,
      );
      expect(await OnboardingService().shouldShowIntroduction(), isTrue);
      service.pending = Completer<void>();
      await tester.tap(find.text('Pular'));
      service.pending.complete();
      await tester.pumpAndSettle();
      expect(service.saves, 2);
      expect(find.byType(OnboardingScreen), findsNothing);
      expect(await OnboardingService().shouldShowIntroduction(), isFalse);
      await tester.pumpWidget(const SizedBox());
    },
  );

  for (final size in [const Size(320, 568), const Size(640, 320)]) {
    testWidgets('all slides fit $size with large text and scrollable content', (
      tester,
    ) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(app(textScale: 2, reducedMotion: true));
      await lastPage(tester);
      expect(tester.takeException(), isNull);
      expect(find.text('CRIAR CONTA'), findsOneWidget);
      expect(find.byType(SingleChildScrollView), findsWidgets);
    });
  }
}
