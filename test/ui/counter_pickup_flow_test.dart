import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:meatshop_mobile/models/order_model.dart';
import 'package:meatshop_mobile/providers/order_provider.dart';
import 'package:meatshop_mobile/data/repositories/order_repository.dart';
import 'package:meatshop_mobile/ui/screens/orders/orders_screen.dart';
import 'package:meatshop_mobile/ui/screens/orders/pickup_order_page.dart';

OrderModel row(
  String status, {
  String type = 'PICKUP',
  String payment = 'PENDING',
  String method = 'Card on Delivery',
}) => OrderModel.fromApi({
  'id': status == 'DELIVERED' ? 2 : 1,
  'status': status,
  'unit_id': 1,
  'unit_name': 'Açougue de teste',
  'delivery_type': type,
  'payment_status': payment,
  'payment': {'method': method},
  'delivery_code': '123456',
  'total_amount': 40.5,
  'items': [],
});

void main() {
  test(
    'status and payment wording follows fulfilment in all customer presentations',
    () {
      expect(row('READY').statusLabel, 'Pronto para retirada');
      expect(row('DELIVERED').statusLabel, 'Retirado');
      expect(row('READY', type: 'DELIVERY').statusLabel, 'Pronto para entrega');
      expect(row('DELIVERED', type: 'DELIVERY').statusLabel, 'Entregue');
      expect(row('READY').paymentMethodLabel, 'Maquininha no balcão');
      expect(row('READY').paymentStatusLabel, 'A pagar no balcão');
      expect(row('READY', payment: 'PAID').paymentStatusLabel, 'Pago');
      expect(row('PREPARING').canShowCustomerCode, isFalse);
      expect(row('READY').canShowCustomerCode, isTrue);
      expect(row('DELIVERED').canShowCustomerCode, isFalse);
      expect(row('CANCELLED').canShowCustomerCode, isFalse);
    },
  );

  testWidgets(
    'order list and completed history distinguish customer collection',
    (tester) async {
      await initializeDateFormatting('pt_BR');
      tester.view.physicalSize = const Size(700, 1800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final orders = _Orders();
      addTearDown(orders.dispose);
      await tester.pumpWidget(
        ChangeNotifierProvider<OrderProvider>.value(
          value: orders,
          child: const MaterialApp(home: Scaffold(body: OrdersScreen())),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Pronto para retirada'), findsOneWidget);
      expect(find.text('Retirado'), findsOneWidget);
      expect(find.text('Pronto para entrega'), findsNothing);
      expect(find.text('Ver retirada e código'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
    },
  );

  for (final status in ['PREPARING', 'READY', 'DELIVERED', 'CANCELLED']) {
    testWidgets('counter page handles $status without delivery instructions', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(390, 1400);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        MaterialApp(
          home: PickupOrderPage(
            order: row(status),
            generatingCode: false,
            onRegenerate: () {},
            onRefresh: () async {},
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(
        find.text('Código de retirada'),
        status == 'READY' ? findsOneWidget : findsNothing,
      );
      expect(
        find.text('123456'),
        status == 'READY' ? findsOneWidget : findsNothing,
      );
      expect(find.text('Maquininha no balcão'), findsOneWidget);
      expect(find.text('A pagar no balcão'), findsOneWidget);
      expect(find.text('Seguir entregador'), findsNothing);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
    });
  }
}

class _Orders extends OrderProvider {
  _Orders() : super(repository: _Unused());
  @override
  Stream<List<OrderModel>> activeOrdersStream() => Stream.value([row('READY')]);
  @override
  Future<OrderHistoryPage> historyPage(int page) async =>
      OrderHistoryPage([row('DELIVERED')], hasMore: false);
}

class _Unused implements OrderRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
