import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:meatshop_mobile/core/network/api_failure.dart';
import 'package:meatshop_mobile/data/repositories/cart_repository.dart';
import 'package:meatshop_mobile/data/repositories/address_repository.dart';
import 'package:meatshop_mobile/data/repositories/order_repository.dart';
import 'package:meatshop_mobile/models/cart_item_model.dart';
import 'package:meatshop_mobile/models/checkout_summary_model.dart';
import 'package:meatshop_mobile/providers/cart_provider.dart';
import 'package:meatshop_mobile/providers/order_provider.dart';
import 'package:meatshop_mobile/providers/user/address_provider.dart';
import 'package:meatshop_mobile/ui/screens/cart/review_order_screen.dart';

void main() {
  testWidgets('quote failure blocks checkout and retry restores delivery fee', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(600, 1400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final orders = _Orders();
    final cart = CartProvider(uid: 'test', repository: _Cart());
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
        child: const MaterialApp(
          home: ReviewOrderScreen(
            summary: CheckoutSummaryModel(
              addressId: '7',
              isScheduled: false,
              paymentMethod: 'cash',
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.text('Falha ao calcular entrega.'), findsOneWidget);
    final confirm = find.widgetWithText(ElevatedButton, 'Confirmar pedido');
    expect(tester.widget<ElevatedButton>(confirm).onPressed, isNull);
    expect(find.text('R\$0,00'), findsNothing);
    await tester.tap(find.text('Atualizar cotação'));
    await tester.pumpAndSettle();
    expect(orders.calls, 2);
    expect(find.text('Falha ao calcular entrega.'), findsNothing);
    expect(tester.widget<ElevatedButton>(confirm).onPressed, isNotNull);
    expect(find.textContaining('4,30'), findsOneWidget);
    expect(find.textContaining('5,80'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
    cart.dispose();
  });
  testWidgets(
    'unit location error offers fulfilment choices without blaming the customer address',
    (tester) async {
      tester.view.physicalSize = const Size(600, 1400);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final orders = _Orders()
        ..failureCode = 'UNIT_LOCATION_CONFIRMATION_REQUIRED';
      final cart = CartProvider(uid: 'test', repository: _Cart());
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
          child: const MaterialApp(
            home: ReviewOrderScreen(
              summary: CheckoutSummaryModel(
                addressId: '7',
                isScheduled: false,
                paymentMethod: 'cash',
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.text('Localização do açougue pendente'), findsOneWidget);
      expect(find.text('Ver opções de recebimento'), findsOneWidget);
      expect(find.text('Voltar e revisar a entrega'), findsNothing);
      expect(
        find.widgetWithText(OutlinedButton, 'Alterar entrega ou retirada'),
        findsOneWidget,
      );
      expect(
        find.widgetWithText(FilledButton, 'Atualizar cotação'),
        findsOneWidget,
      );
      expect(find.text('Falha ao calcular entrega.'), findsOneWidget);
      final confirm = find.widgetWithText(ElevatedButton, 'Confirmar pedido');
      expect(tester.widget<ElevatedButton>(confirm).onPressed, isNull);
      expect(find.text('R\$0,00'), findsNothing);
      await tester.tap(find.text('Atualizar cotação'));
      await tester.pumpAndSettle();
      expect(orders.calls, 2);
      expect(find.text('Falha ao calcular entrega.'), findsNothing);
      expect(tester.widget<ElevatedButton>(confirm).onPressed, isNotNull);
      expect(find.textContaining('4,30'), findsOneWidget);
      expect(find.textContaining('5,80'), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
      cart.dispose();
    },
  );
  testWidgets(
    'an unknown coupon stays inline and preserves the previous total and freight',
    (tester) async {
      tester.view.physicalSize = const Size(600, 1400);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final orders = _Orders()..failFirst = false;
      final cart = CartProvider(uid: 'test', repository: _Cart());
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
          child: const MaterialApp(
            home: ReviewOrderScreen(
              summary: CheckoutSummaryModel(
                addressId: '7',
                isScheduled: false,
                paymentMethod: 'cash',
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.textContaining('5,80'), findsOneWidget);
      await tester.tap(find.text('Adicionar cupom'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField).first, 'NAOEXISTE');
      await tester.tap(find.text('Aplicar cupom'));
      await tester.pumpAndSettle();
      expect(find.text('Cupom não encontrado.'), findsOneWidget);
      expect(find.text('Revise antes de confirmar'), findsNothing);
      expect(find.text('Indisponível'), findsNothing);
      expect(find.textContaining('5,80'), findsOneWidget);
      expect(find.textContaining('4,30'), findsOneWidget);
      final confirm = find.widgetWithText(ElevatedButton, 'Confirmar pedido');
      expect(tester.widget<ElevatedButton>(confirm).onPressed, isNull);
      await tester.tap(find.byTooltip('Remover cupom'));
      await tester.pumpAndSettle();
      expect(find.text('Cupom não encontrado.'), findsNothing);
      expect(tester.widget<ElevatedButton>(confirm).onPressed, isNotNull);
      expect(orders.lastCoupons, isEmpty);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
      cart.dispose();
    },
  );
  testWidgets('cash change can be corrected after the freight is quoted', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(600, 1800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final orders = _Orders()..failFirst = false;
    final cart = CartProvider(uid: 'test', repository: _Cart());
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
        child: const MaterialApp(
          home: ReviewOrderScreen(
            summary: CheckoutSummaryModel(
              addressId: '7',
              isScheduled: false,
              paymentMethod: 'cash',
              changeFor: 2,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    final confirm = find.widgetWithText(ElevatedButton, 'Confirmar pedido');
    expect(find.textContaining('O troco deve cobrir o total'), findsOneWidget);
    expect(find.textContaining('4,30'), findsOneWidget);
    expect(tester.widget<ElevatedButton>(confirm).onPressed, isNull);
    await tester.enterText(
      find.byKey(const ValueKey('review-change')),
      '10,00',
    );
    await tester.pumpAndSettle();
    expect(tester.widget<ElevatedButton>(confirm).onPressed, isNull);
    await tester.ensureVisible(find.text('Atualizar troco'));
    await tester.tap(find.text('Atualizar troco'));
    await tester.pumpAndSettle();
    expect(orders.lastChange, 10);
    expect(tester.widget<ElevatedButton>(confirm).onPressed, isNotNull);
    await tester.enterText(find.byKey(const ValueKey('review-change')), '');
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Atualizar troco'));
    await tester.tap(find.text('Atualizar troco'));
    await tester.pumpAndSettle();
    expect(orders.lastChange, isNull);
    expect(tester.widget<ElevatedButton>(confirm).onPressed, isNotNull);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
    cart.dispose();
  });
}

class _Orders implements OrderRepository {
  int calls = 0;
  double? lastChange;
  bool failFirst = true;
  String? failureCode;
  Map<String, String> lastCoupons = {};
  @override
  Future<CheckoutQuote> quote(CheckoutSummaryModel summary) async {
    lastCoupons = Map.of(summary.coupons);
    lastChange = summary.changeFor;
    if (summary.coupons.values.contains('NAOEXISTE')) {
      throw const ApiFailure(
        kind: ApiFailureKind.validation,
        statusCode: 400,
        code: 'COUPON_NOT_FOUND',
        message: 'Cupom não encontrado.',
      );
    }
    if (++calls == 1 && failFirst) {
      throw ApiFailure(
        kind: ApiFailureKind.validation,
        code: failureCode,
        message: 'Falha ao calcular entrega.',
      );
    }
    return const CheckoutQuote(
      groups: [
        CheckoutQuoteGroup(
          unitId: '1',
          subtotal: 1.5,
          discountAmount: 0,
          deliveryFee: 4.3,
          totalAmount: 5.8,
        ),
      ],
      totalAmount: 5.8,
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Cart implements CartRepository {
  @override
  Future<List<CartItemModel>> getCart() async => [
    const CartItemModel(
      productId: '1',
      productName: 'Produto',
      productImageUrl: '',
      unitOfMeasure: 'kg',
      unitPrice: 15,
      quantity: 0.1,
      unitId: '1',
      unitName: 'Loja',
    ),
  ];
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Addresses implements AddressRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
