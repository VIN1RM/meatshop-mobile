import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meatshop_mobile/models/order_model.dart';
import 'package:meatshop_mobile/ui/widgets/customer_order_code_card.dart';

OrderModel _order({
  String status = 'OUT_FOR_DELIVERY',
  bool pickup = false,
  String? code = '625065',
}) => OrderModel.fromApi({
  'id': 135,
  'status': status,
  'delivery_type': pickup ? 'PICKUP' : 'DELIVERY',
  'delivery_code': code,
});
Future<void> _render(
  WidgetTester tester,
  OrderModel order, {
  VoidCallback? onOpen,
  double scale = 1,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: MediaQuery(
          data: MediaQueryData(textScaler: TextScaler.linear(scale)),
          child: SingleChildScrollView(
            child: CustomerOrderCodeCard(order: order, onOpen: onOpen),
          ),
        ),
      ),
    ),
  );
}

void main() {
  testWidgets(
    'delivery code is readable for its order and tells when it can be shared',
    (tester) async {
      await _render(tester, _order());
      expect(find.text('Código de entrega'), findsOneWidget);
      expect(find.text('#135'), findsOneWidget);
      expect(find.text('625065'), findsOneWidget);
      expect(find.textContaining('somente depois de receber'), findsOneWidget);
    },
  );
  for (final status in ['DELIVERED', 'CANCELLED']) {
    testWidgets('does not show a stale handoff code after $status', (
      tester,
    ) async {
      await _render(tester, _order(status: status));
      expect(find.text('625065'), findsNothing);
      expect(find.text('Código de entrega'), findsNothing);
    });
  }
  testWidgets(
    'pickup code appears only when ready and uses counter instructions',
    (tester) async {
      await _render(tester, _order(pickup: true, status: 'PREPARING'));
      expect(find.text('625065'), findsNothing);
      await _render(tester, _order(pickup: true, status: 'READY'));
      expect(find.text('Código de retirada'), findsOneWidget);
      expect(find.textContaining('no balcão'), findsOneWidget);
    },
  );
  testWidgets(
    'a missing code offers the existing tracking and regeneration flow',
    (tester) async {
      var opened = false;
      await _render(tester, _order(code: null), onOpen: () => opened = true);
      expect(find.byType(SelectableText), findsNothing);
      await tester.tap(find.text('Ver código'));
      expect(opened, isTrue);
    },
  );
  testWidgets('six digits remain visible with large text on a narrow device', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 700);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await _render(tester, _order(), scale: 1.6);
    expect(find.text('625065'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
