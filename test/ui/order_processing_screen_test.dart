import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:meatshop_mobile/data/repositories/order_repository.dart';
import 'package:meatshop_mobile/models/order_model.dart';
import 'package:meatshop_mobile/providers/order_provider.dart';
import 'package:meatshop_mobile/ui/screens/fallback/order_processing_screen.dart';

void main() {
  Future<void> render(
    WidgetTester tester,
    _Orders orders, {
    Size size = const Size(600, 1200),
    double textScale = 1,
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(() async => tester.pumpWidget(const SizedBox()));
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => OrderProvider(repository: orders),
        child: MaterialApp(
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: TextScaler.linear(textScale)),
            child: child!,
          ),
          home: const OrderProcessingScreen(orderIds: ['6']),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets(
    'uses checkout styling and never presents an unpaid cash order as paid',
    (tester) async {
      await render(tester, _Orders());
      expect(
        tester.widget<Scaffold>(find.byType(Scaffold)).backgroundColor,
        const Color(0xFF2E2E2E),
      );
      expect(find.text('PAGAMENTOS'), findsOneWidget);
      expect(find.text('A pagar na entrega'), findsOneWidget);
      expect(find.text('Pago'), findsNothing);
      expect(find.text('Pagar este açougue'), findsNothing);
      expect(find.textContaining('Pague ao receber'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('offers checkout only for payable online orders', (tester) async {
    await render(tester, _Orders()..method = 'Pix');
    expect(find.text('Pagar este açougue'), findsOneWidget);
    expect(find.textContaining('Pague até'), findsOneWidget);
    expect(find.text('Aguardando pagamento'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'handles long unit names and refund states on a small screen with large text',
    (tester) async {
      final orders = _Orders()
        ..method = 'Pix'
        ..paymentStatus = 'PAID'
        ..refundStatus = 'FAILED';
      await render(tester, orders, size: const Size(320, 640), textScale: 1.4);
      await tester.scrollUntilVisible(
        find.text('Estorno precisa de atendimento'),
        150,
      );
      expect(find.text('Estorno precisa de atendimento'), findsOneWidget);
      expect(find.text('Pagar este açougue'), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'updates the visible state when the next automatic poll confirms payment',
    (tester) async {
      final orders = _Orders()..method = 'Pix';
      await render(tester, orders);
      expect(find.text('Aguardando pagamento'), findsOneWidget);
      orders.paymentStatus = 'PAID';
      await tester.pump(const Duration(seconds: 10));
      await tester.pumpAndSettle();
      expect(find.text('Pago'), findsOneWidget);
      expect(find.text('Pagar este açougue'), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );
}

class _Orders implements OrderRepository {
  String method = 'Cash';
  String paymentStatus = 'PENDING';
  String? refundStatus;
  @override
  Future<OrderModel> get(String id) async => OrderModel.fromApi({
    'id': int.parse(id),
    'unit_id': 1,
    'unit_name': 'Açougue do Daniel com nome completo da unidade Centro',
    'status': 'PENDING',
    'payment_status': paymentStatus,
    'total_amount': 3.31,
    'payment_due_at': DateTime.now()
        .add(const Duration(minutes: 20))
        .toIso8601String(),
    'payment': {'method': method, 'refund_status': refundStatus},
    'items': <Object?>[],
  });
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
