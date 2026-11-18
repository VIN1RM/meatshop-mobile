import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meatshop_mobile/services/onboarding_service.dart';
import 'package:meatshop_mobile/ui/widgets/profile_quick_guide.dart';
import 'package:shared_preferences/shared_preferences.dart';

Widget guide(IntroductionProfile profile) => MaterialApp(
  home: Scaffold(
    body: SingleChildScrollView(child: ProfileQuickGuide(profile: profile)),
  ),
);

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('dismissing customer help keeps courier help available', (
    tester,
  ) async {
    await tester.pumpWidget(guide(IntroductionProfile.client));
    await tester.pumpAndSettle();
    expect(find.text('Seu primeiro pedido'), findsOneWidget);
    expect(find.textContaining('retirada'), findsOneWidget);
    await tester.tap(find.text('Entendi'));
    await tester.pumpAndSettle();
    expect(find.text('Seu primeiro pedido'), findsNothing);
    expect(await OnboardingService().shouldShowGuide('client'), isFalse);
    expect(await OnboardingService().shouldShowGuide('delivery'), isTrue);
    await tester.pumpWidget(const SizedBox());
    await tester.pumpWidget(guide(IntroductionProfile.delivery));
    await tester.pumpAndSettle();
    expect(find.text('Suas primeiras entregas'), findsOneWidget);
    expect(find.textContaining('pode ser pausado'), findsOneWidget);
  });

  testWidgets('completed help stays hidden when the screen is reopened', (
    tester,
  ) async {
    await OnboardingService().completeGuide('delivery');
    await tester.pumpWidget(guide(IntroductionProfile.delivery));
    await tester.pumpAndSettle();
    expect(find.text('Suas primeiras entregas'), findsNothing);
  });

  testWidgets('help fits a narrow viewport with large text', (tester) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MaterialApp(
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.linear(2)),
          child: child!,
        ),
        home: const Scaffold(
          body: SingleChildScrollView(
            child: ProfileQuickGuide(profile: IntroductionProfile.delivery),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
}
