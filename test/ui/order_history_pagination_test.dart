import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:meatshop_mobile/data/repositories/order_repository.dart';
import 'package:meatshop_mobile/models/order_model.dart';
import 'package:meatshop_mobile/providers/order_provider.dart';
import 'package:meatshop_mobile/ui/screens/orders/orders_screen.dart';

Finder title(String text) => find.byWidgetPredicate(
  (widget) =>
      widget is Text &&
      widget.data == text &&
      widget.style?.fontWeight == FontWeight.w700,
);

void main() {
  testWidgets(
    'history retries the same page, deduplicates orders and ends pagination',
    (tester) async {
      await initializeDateFormatting('pt_BR');
      tester.view.physicalSize = const Size(700, 1800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final orders = _PagedOrders();
      addTearDown(orders.dispose);
      addTearDown(() async => tester.pumpWidget(const SizedBox()));
      await tester.pumpWidget(
        ChangeNotifierProvider<OrderProvider>.value(
          value: orders,
          child: const MaterialApp(home: Scaffold(body: OrdersScreen())),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.textContaining('Hist\u00f3rico completo'), findsOneWidget);
      expect(title('Old order 1'), findsOneWidget);
      await tester.ensureVisible(find.text('Carregar mais pedidos'));
      await tester.tap(find.text('Carregar mais pedidos'));
      await tester.pumpAndSettle();
      expect(find.textContaining('carregar o hist\u00f3rico'), findsOneWidget);
      expect(find.textContaining('technical failure'), findsNothing);
      await tester.ensureVisible(find.text('Tentar novamente'));
      await tester.tap(find.text('Tentar novamente'));
      await tester.pumpAndSettle();
      expect(orders.requested, [0, 1, 1]);
      expect(title('Old order 1'), findsOneWidget);
      expect(title('Old order 2'), findsNothing);
      expect(title('Updated order 2'), findsOneWidget);
      expect(title('Old order 3'), findsOneWidget);
      expect(find.text('Carregar mais pedidos'), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'refresh restarts history at the first page and removes stale pages',
    (tester) async {
      await initializeDateFormatting('pt_BR');
      tester.view.physicalSize = const Size(700, 1800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final orders = _PagedOrders()..failed = true;
      await tester.pumpWidget(
        ChangeNotifierProvider<OrderProvider>.value(
          value: orders,
          child: const MaterialApp(home: Scaffold(body: OrdersScreen())),
        ),
      );
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Carregar mais pedidos'));
      await tester.tap(find.text('Carregar mais pedidos'));
      await tester.pumpAndSettle();
      expect(title('Old order 3'), findsOneWidget);
      await tester
          .widget<RefreshIndicator>(find.byType(RefreshIndicator))
          .onRefresh();
      await tester.pumpAndSettle();
      expect(orders.requested, [0, 1, 0]);
      expect(title('Old order 3'), findsNothing);
      expect(title('Old order 1'), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
      orders.dispose();
    },
  );
}

class _PagedOrders extends OrderProvider {
  _PagedOrders() : super(repository: _UnusedRepository());
  final requested = <int>[];
  bool failed = false;
  @override
  Stream<List<OrderModel>> activeOrdersStream() => Stream.value([]);
  OrderModel row(int id, String name) => OrderModel.fromApi({
    'id': id,
    'status': 'DELIVERED',
    'order_date': '2020-01-01T12:00:00Z',
    'unit_id': 1,
    'unit_name': name,
    'items': [],
    'total_amount': 10,
  });
  @override
  Future<OrderHistoryPage> historyPage(int page) async {
    requested.add(page);
    if (page == 0) {
      return OrderHistoryPage([
        row(1, 'Old order 1'),
        row(2, 'Old order 2'),
      ], hasMore: true);
    }
    if (!failed) {
      failed = true;
      throw StateError('technical failure');
    }
    return OrderHistoryPage([
      row(2, 'Updated order 2'),
      row(3, 'Old order 3'),
    ], hasMore: false);
  }
}

class _UnusedRepository implements OrderRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
