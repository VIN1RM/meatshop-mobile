import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:meatshop_mobile/data/repositories/delivery_repository.dart';
import 'package:meatshop_mobile/models/address_model.dart';
import 'package:meatshop_mobile/models/delivery_order_model.dart';
import 'package:meatshop_mobile/models/delivery_earnings_model.dart';
import 'package:meatshop_mobile/providers/delivery/delivery_provider.dart';
import 'package:meatshop_mobile/ui/screens/delivery/delivery_history_screen.dart';
import 'package:meatshop_mobile/ui/widgets/earning_row.dart';

class _Repository extends Fake implements DeliveryRepository {}

class _History extends DeliveryProvider {
  _History() : super(repository: _Repository());
  @override
  List<DeliveryOrder> get historyOrders => [
    DeliveryOrder(
      id: 97,
      clientName: 'Karina Cliente Demo',
      unitName: 'Vila Nobre',
      address: address,
      unitAddress: address,
      items: 'Carnes',
      total: 194.15,
      deliveryFee: 8.5,
    ),
  ];
  @override
  Future<void> loadHistory() async {}
}

const address = AddressModel(
  id: '1',
  label: 'Casa',
  street: 'Rua',
  number: '1',
  complement: '',
  neighborhood: 'Centro',
  city: 'Anápolis',
  state: 'GO',
  zipCode: '',
  isDefault: true,
);

void main() {
  test(
    'localizes current and legacy earning labels without changing the delivery amount',
    () {
      for (final paid in [null, '2026-11-12T12:00:00Z']) {
        for (final id in ['97', '']) {
          final entry = DeliveryEarningModel.fromApi({
            'id': 97,
            'order_id': id,
            'label': 'Order #97',
            'amount': 8.5,
            'paid_at': paid,
          });
          expect(
            entry.label,
            paid == null ? 'Pedido #97 · A receber' : 'Pedido #97 · Recebido',
          );
          expect(entry.amount, 8.5);
        }
      }
    },
  );

  testWidgets(
    'history highlights the delivery gain and labels the purchase total only in the details',
    (tester) async {
      tester.view.physicalSize = const Size(320, 700);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final provider = _History();
      await tester.pumpWidget(
        ChangeNotifierProvider<DeliveryProvider>.value(
          value: provider,
          child: MaterialApp(
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(
                context,
              ).copyWith(textScaler: TextScaler.linear(1.5)),
              child: child!,
            ),
            home: const Scaffold(body: DeliveryHistoryScreen()),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Ganho na entrega'), findsOneWidget);
      expect(find.textContaining('8,50'), findsOneWidget);
      expect(find.textContaining('194,15'), findsNothing);
      await tester.tap(find.text('Pedido #97'));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        find.text('Total do pedido'),
        160,
        scrollable: find.byType(Scrollable).last,
      );
      expect(find.textContaining('194,15'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
      provider.dispose();
    },
  );

  testWidgets(
    'shared recent/report earning rows fit narrow screens and show older dates correctly',
    (tester) async {
      tester.view.physicalSize = const Size(320, 640);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final date = DateTime.now().subtract(const Duration(days: 4));
      final entry = DeliveryEarningModel.fromApi({
        'order_id': 97,
        'label': 'Order #97',
        'amount': 8.5,
        'created_at': date.toIso8601String(),
      });
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MediaQuery(
              data: const MediaQueryData(textScaler: TextScaler.linear(1.8)),
              child: EarningRow(entry: entry),
            ),
          ),
        ),
      );
      expect(find.text('Pedido #97 · A receber'), findsOneWidget);
      expect(find.textContaining('8,50'), findsOneWidget);
      expect(find.text(DateFormat('dd/MM/yyyy').format(date)), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}
