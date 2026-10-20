import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:meatshop_mobile/data/repositories/delivery_repository.dart';
import 'package:meatshop_mobile/providers/delivery/delivery_provider.dart';
import 'package:meatshop_mobile/ui/screens/delivery/delivery_availability_control.dart';

class AvailabilityRepository extends Fake implements DeliveryRepository {
  bool online = false;
  bool fail = false;
  @override
  Future<void> setAvailability(bool value) async {
    if (fail) throw StateError('offline');
    online = value;
  }
}

void main() {
  testWidgets(
    'visible control activates and deactivates delivery availability',
    (tester) async {
      final repository = AvailabilityRepository();
      final provider = DeliveryProvider(repository: repository);
      addTearDown(provider.dispose);
      await tester.pumpWidget(
        ChangeNotifierProvider.value(
          value: provider,
          child: const MaterialApp(
            home: Scaffold(body: DeliveryAvailabilityControl()),
          ),
        ),
      );
      await tester.tap(find.text('Ficar online'));
      await tester.pumpAndSettle();
      expect(repository.online, isTrue);
      expect(find.text('Ficar offline'), findsOneWidget);
      await tester.tap(find.text('Ficar offline'));
      await tester.pumpAndSettle();
      expect(repository.online, isFalse);
      expect(find.text('Ficar online'), findsOneWidget);
    },
  );
  testWidgets('failed activation keeps the offline state and allows retry', (
    tester,
  ) async {
    final repository = AvailabilityRepository()..fail = true;
    final provider = DeliveryProvider(repository: repository);
    addTearDown(provider.dispose);
    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: provider,
        child: const MaterialApp(
          home: Scaffold(body: DeliveryAvailabilityControl()),
        ),
      ),
    );
    await tester.tap(find.text('Ficar online'));
    await tester.pumpAndSettle();
    expect(repository.online, isFalse);
    expect(find.text('Ficar online'), findsOneWidget);
    expect(provider.lastError, isNotNull);
  });
}
