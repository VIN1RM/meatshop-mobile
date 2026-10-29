import 'package:meatshop_mobile/data/repositories/federated_auth_repository.dart';
import 'package:firebase_auth/firebase_auth.dart' show User;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:meatshop_mobile/providers/auth/auth_provider.dart';
import 'package:meatshop_mobile/providers/delivery/vehicle_provider.dart';
import 'package:meatshop_mobile/data/repositories/delivery_repository.dart';
import 'package:meatshop_mobile/ui/screens/account/vehicle_settings_screen.dart';

class _Federated extends Fake implements FederatedAuthRepository {}

class _Auth extends AuthProvider {
  _Auth() : super(federatedAuth: _Federated(), delivery: _Delivery());
  @override
  User? get currentUser => null;
}

class _Delivery implements DeliveryRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Vehicles extends VehicleProvider {
  _Vehicles() : super(repository: _Delivery());
  @override
  List<Map<String, dynamic>> get vehicles => const [
    {'id': 1, 'type': 'MOTORCYCLE', 'is_active': true},
    {'id': 2, 'type': 'CAR', 'is_active': false},
    {'id': 3, 'type': 'BIKE', 'is_active': false},
  ];
}

void main() {
  testWidgets(
    'translates API types, separates cards and adapts actions to large text',
    (tester) async {
      tester.view.physicalSize = const Size(320, 640);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<AuthProvider>(create: (_) => _Auth()),
            ChangeNotifierProvider<VehicleProvider>(create: (_) => _Vehicles()),
          ],
          child: MaterialApp(
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(
                context,
              ).copyWith(textScaler: TextScaler.linear(1.8)),
              child: child!,
            ),
            home: const VehicleSettingsScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Moto'), findsOneWidget);
      expect(find.text('Carro'), findsOneWidget);
      expect(find.text('Bicicleta'), findsOneWidget);
      expect(find.text('MOTORCYCLE'), findsNothing);
      expect(find.text('Veículo principal'), findsOneWidget);
      expect(find.text('Veículo adicional'), findsNWidgets(2));
      expect(
        tester.getRect(find.byKey(const ValueKey('vehicle-1'))).bottom,
        lessThanOrEqualTo(
          tester.getRect(find.byKey(const ValueKey('vehicle-2'))).top,
        ),
      );
      await tester.ensureVisible(find.text('Adicionar veículo'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    },
  );
}
