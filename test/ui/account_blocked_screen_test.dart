import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meatshop_mobile/ui/screens/account/account_blocked_screen.dart';

void main() {
  Widget app(Object? arguments) => MaterialApp(
    onGenerateRoute: (_) => MaterialPageRoute<void>(
      settings: RouteSettings(arguments: arguments),
      builder: (_) => const AccountBlockedPage(),
    ),
  );

  testWidgets('provider restriction has no invented countdown', (tester) async {
    await tester.pumpWidget(app(null));
    await tester.pump();
    expect(find.text('Tempo restante'), findsNothing);
    expect(find.textContaining('O provedor de acesso'), findsOneWidget);
    expect(find.text('Voltar ao login'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('local restriction displays countdown until expiry', (
    tester,
  ) async {
    await tester.pumpWidget(
      app(DateTime.now().add(const Duration(minutes: 5))),
    );
    await tester.pump();
    expect(find.text('Tempo restante'), findsOneWidget);
    expect(find.textContaining('O provedor de acesso'), findsNothing);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
  });
}
