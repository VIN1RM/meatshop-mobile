import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:meatshop_mobile/data/repositories/delivery_repository.dart';
import 'package:meatshop_mobile/data/repositories/federated_auth_repository.dart';
import 'package:meatshop_mobile/providers/auth/auth_provider.dart';
import 'package:meatshop_mobile/ui/screens/auth/login_screen.dart';
import 'package:provider/provider.dart';

class FakeFederatedAuthRepository extends Fake
    implements FederatedAuthRepository {}

class FakeDeliveryRepository extends Fake implements DeliveryRepository {}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('renders the authentication journey entry point', (tester) async {
    final provider = AuthProvider(
      federatedAuth: FakeFederatedAuthRepository(),
      delivery: FakeDeliveryRepository(),
    );
    addTearDown(provider.dispose);

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: provider,
        child: const MaterialApp(home: LoginPage()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(TextFormField), findsNWidgets(2));
    expect(find.text('ENTRAR'), findsOneWidget);
    expect(find.text('Continuar com Google'), findsOneWidget);
    expect(find.text('Continuar com Apple'), findsOneWidget);
  });
}
