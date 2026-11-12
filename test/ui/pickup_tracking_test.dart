import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:meatshop_mobile/data/repositories/order_repository.dart';
import 'package:meatshop_mobile/data/repositories/delivery_repository.dart';
import 'package:meatshop_mobile/data/repositories/marketplace_repository.dart';
import 'package:meatshop_mobile/data/repositories/marketplace_context.dart';
import 'package:meatshop_mobile/data/repositories/realtime_repository.dart';
import 'package:meatshop_mobile/models/order_model.dart';
import 'package:meatshop_mobile/models/unit_model.dart';
import 'package:meatshop_mobile/ui/screens/orders/order_tracking_screen.dart';

void main() {
  testWidgets(
    'counter pickup shows customer code and unit address without courier tracking',
    (tester) async {
      tester.view.physicalSize = const Size(430, 1100);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final deliveries = _Deliveries();
      final orders = _Orders();
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            Provider<OrderRepository>.value(value: orders),
            Provider<DeliveryRepository>.value(value: deliveries),
            Provider<MarketplaceContext>.value(
              value: MarketplaceContext(_Marketplace()),
            ),
            Provider<BackendRealtimeAccess>.value(
              value: const BackendRealtimeAccess(),
            ),
          ],
          child: const MaterialApp(home: OrderTrackingScreen(orderId: 1)),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Código de retirada'), findsOneWidget);
      expect(find.text('123456'), findsOneWidget);
      expect(find.textContaining('Rua da Loja'), findsOneWidget);
      expect(deliveries.trackingCalls, 0);
      expect(tester.takeException(), isNull);
      await tester.ensureVisible(find.text('Gerar novo código'));
      await tester.tap(find.text('Gerar novo código'));
      await tester.pumpAndSettle();
      expect(deliveries.regeneratedPurpose, isFalse);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
    },
  );
}

class _Orders implements OrderRepository {
  @override
  Future<OrderModel> get(String id) async => OrderModel.fromApi({
    'id': 1,
    'unit_id': 1,
    'unit_name': 'Loja',
    'delivery_type': 'PICKUP',
    'status': 'READY',
    'payment_status': 'PENDING',
    'total_amount': 30,
    'delivery_code': '123456',
    'items': <Object?>[],
  });
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Deliveries implements DeliveryRepository {
  int trackingCalls = 0;
  bool? regeneratedPurpose;
  @override
  Future<DeliveryTrackingPoint?> latestTracking(int orderId) async {
    trackingCalls++;
    return null;
  }

  @override
  Future<String> regenerateCode(int orderId, {required bool pickup}) async {
    regeneratedPurpose = pickup;
    return '123456';
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Marketplace implements MarketplaceRepository {
  @override
  Future<UnitModel> getUnit(String id) async => UnitModel(
    id: id,
    name: 'Loja',
    cnpj: '',
    street: 'Rua da Loja',
    number: '10',
    neighborhood: 'Centro',
    city: 'Goiânia',
    state: 'GO',
    zipCode: '',
    adminId: '1',
    imageUrl: '',
    createdAt: DateTime(2026),
    latitude: -16.68,
    longitude: -49.26,
  );
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
