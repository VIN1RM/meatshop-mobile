import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meatshop_mobile/core/network/api_failure.dart';
import 'package:meatshop_mobile/models/address_model.dart';
import 'package:meatshop_mobile/ui/dialogs/remove_address_dialog.dart';

const address = AddressModel(
  id: '35',
  label: 'Casa',
  street: 'Rua',
  number: '10',
  complement: '',
  neighborhood: 'Centro',
  city: 'Goiânia',
  state: 'GO',
  zipCode: '74000000',
  isDefault: true,
);

void main() {
  testWidgets(
    'awaits deletion, prevents duplicate requests and closes only on success',
    (tester) async {
      final pending = Completer<void>();
      var calls = 0;
      bool? removed;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => TextButton(
                onPressed: () async {
                  removed = await showDialog<bool>(
                    context: context,
                    builder: (_) => RemoveAddressDialog(
                      address: address,
                      onConfirm: () {
                        calls++;
                        return pending.future;
                      },
                    ),
                  );
                },
                child: const Text('Abrir'),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Abrir'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Remover'));
      await tester.pump();
      expect(calls, 1);
      expect(removed, isNull);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(
        tester
            .widget<OutlinedButton>(
              find.widgetWithText(OutlinedButton, 'Cancelar'),
            )
            .onPressed,
        isNull,
      );
      pending.complete();
      await tester.pumpAndSettle();
      expect(removed, isTrue);
      expect(find.byType(RemoveAddressDialog), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets('shows the API failure in the dialog and allows retry', (
    tester,
  ) async {
    var fail = true;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) => TextButton(
              onPressed: () => showDialog<bool>(
                context: context,
                builder: (_) => RemoveAddressDialog(
                  address: address,
                  onConfirm: () async {
                    if (fail) {
                      throw const ApiFailure(
                        kind: ApiFailureKind.conflict,
                        code: 'ADDRESS_IN_USE',
                        message: 'Este endereço está sendo usado em um pedido.',
                      );
                    }
                  },
                ),
              ),
              child: const Text('Abrir'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Abrir'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Remover'));
    await tester.pumpAndSettle();
    expect(
      find.text('Este endereço está sendo usado em um pedido.'),
      findsOneWidget,
    );
    expect(find.byType(RemoveAddressDialog), findsOneWidget);
    fail = false;
    await tester.tap(find.text('Remover'));
    await tester.pumpAndSettle();
    expect(find.byType(RemoveAddressDialog), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
