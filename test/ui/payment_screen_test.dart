import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:meatshop_mobile/data/repositories/address_repository.dart';
import 'package:meatshop_mobile/data/repositories/cart_repository.dart';
import 'package:meatshop_mobile/data/repositories/order_repository.dart';
import 'package:meatshop_mobile/models/cart_item_model.dart';
import 'package:meatshop_mobile/models/checkout_summary_model.dart';
import 'package:meatshop_mobile/providers/cart_provider.dart';
import 'package:meatshop_mobile/providers/order_provider.dart';
import 'package:meatshop_mobile/providers/user/address_provider.dart';
import 'package:meatshop_mobile/ui/screens/cart/payment_screen.dart';

void main() {
  Future<CartProvider> render(
    WidgetTester tester,
    _Orders orders, {
    int units = 2,
    Size size = const Size(600, 1400),
    double textScale = 1,
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final cart = CartProvider(uid: 'test', repository: _Cart(units));
    await cart.loadCart();
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: cart),
          ChangeNotifierProvider(
            create: (_) => OrderProvider(repository: orders),
          ),
          ChangeNotifierProvider(
            create: (_) => AddressProvider(repository: _Addresses()),
          ),
        ],
        child: MaterialApp(
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: TextScaler.linear(textScale)),
            child: child!,
          ),
          home: PaymentScreen(total: units * 20, addressId: '7'),
        ),
      ),
    );
    await tester.pumpAndSettle();
    return cart;
  }

  testWidgets(
    'offers online methods per unit and preserves separate choices in the official quote',
    (tester) async {
      final orders = _Orders();
      final cart = await render(tester, orders);
      expect(orders.requestedUnits, ['1', '2']);
      final first = find.byKey(const ValueKey('payment-unit-1'));
      final second = find.byKey(const ValueKey('payment-unit-2'));
      final firstOnline = find.descendant(
        of: first,
        matching: find.widgetWithText(TextButton, 'Pagar online'),
      );
      final secondOnline = find.descendant(
        of: second,
        matching: find.widgetWithText(TextButton, 'Pagar online'),
      );
      await tester.ensureVisible(secondOnline);
      expect(tester.widget<TextButton>(secondOnline).onPressed, isNull);
      await tester.ensureVisible(firstOnline);
      await tester.tap(firstOnline);
      await tester.pumpAndSettle();
      final credit = find.byKey(const ValueKey('payment-1-credit'));
      await tester.ensureVisible(credit);
      await tester.tap(credit);
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(ElevatedButton, 'Revisar pedido'));
      await tester.pumpAndSettle();
      expect(orders.lastQuote?.unitPaymentMethods, {
        '1': 'credit',
        '2': 'cash',
      });
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
      cart.dispose();
    },
  );

  testWidgets(
    'restores brand styling and fits a small screen with larger text',
    (tester) async {
      final cart = await render(
        tester,
        _Orders(),
        units: 1,
        size: const Size(320, 640),
        textScale: 1.4,
      );
      expect(
        tester.widget<Scaffold>(find.byType(Scaffold)).backgroundColor,
        const Color(0xFF2E2E2E),
      );
      expect(find.text('PAGAMENTO'), findsOneWidget);
      await tester.scrollUntilVisible(find.text('Pagar online'), 150);
      expect(find.text('Pagar online'), findsOneWidget);
      expect(find.text('Na entrega'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
      cart.dispose();
    },
  );

  testWidgets(
    'availability failure keeps delivery methods usable and explains how to retry',
    (tester) async {
      final orders = _Orders()..failAvailability = true;
      final cart = await render(tester, orders, units: 1);
      expect(find.textContaining('Não foi possível verificar'), findsOneWidget);
      expect(
        tester
            .widget<ElevatedButton>(
              find.widgetWithText(ElevatedButton, 'Revisar pedido'),
            )
            .onPressed,
        isNotNull,
      );
      expect(
        tester
            .widget<TextButton>(find.widgetWithText(TextButton, 'Pagar online'))
            .onPressed,
        isNull,
      );
      expect(find.byKey(const ValueKey('payment-1-cash')), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
      cart.dispose();
    },
  );

  testWidgets(
    'rejects change below the order subtotal without leaving payment selection',
    (tester) async {
      final cart = await render(tester, _Orders(), units: 1);
      await tester.enterText(
        find.byKey(const ValueKey('payment-change')),
        '10,00',
      );
      await tester.tap(find.widgetWithText(ElevatedButton, 'Revisar pedido'));
      await tester.pumpAndSettle();
      expect(
        find.text('Informe um valor para troco que cubra o pedido.'),
        findsOneWidget,
      );
      expect(find.text('PAGAMENTO'), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
      cart.dispose();
    },
  );
}

class _Orders implements OrderRepository, CheckoutCapabilities {
  List<String>? requestedUnits;
  CheckoutSummaryModel? lastQuote;
  bool failAvailability = false;
  @override
  Future<Map<String, bool>> paymentAvailability(List<String> units) async {
    requestedUnits = units;
    if (failAvailability) throw StateError('Offline');
    return {for (final id in units) id: id == '1'};
  }

  @override
  Future<bool> onlinePaymentsAvailable() async => true;
  @override
  Future<CheckoutQuote> quote(CheckoutSummaryModel summary) async {
    lastQuote = summary;
    return const CheckoutQuote(
      groups: [
        CheckoutQuoteGroup(
          unitId: '1',
          subtotal: 20,
          discountAmount: 0,
          deliveryFee: 0,
          totalAmount: 20,
        ),
        CheckoutQuoteGroup(
          unitId: '2',
          subtotal: 20,
          discountAmount: 0,
          deliveryFee: 0,
          totalAmount: 20,
        ),
      ],
      totalAmount: 40,
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Cart implements CartRepository {
  _Cart(this.units);
  final int units;
  @override
  Future<List<CartItemModel>> getCart() async => [
    for (var id = 1; id <= units; id++)
      CartItemModel(
        productId: '$id',
        productName: 'Produto',
        productImageUrl: '',
        unitOfMeasure: 'kg',
        unitPrice: 20,
        quantity: 1,
        unitId: '$id',
        unitName: 'Açougue $id',
      ),
  ];
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Addresses implements AddressRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
