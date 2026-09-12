import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:meatshop_mobile/data/repositories/address_repository.dart';
import 'package:meatshop_mobile/models/address_model.dart';
import 'package:meatshop_mobile/providers/user/address_provider.dart';
import 'package:meatshop_mobile/ui/components/sheets/address_form_sheet.dart';

AddressModel address(String cep, String street) => AddressModel(
  id: '1',
  label: 'Casa',
  street: street,
  number: '10',
  complement: '',
  neighborhood: 'Centro',
  city: 'São Paulo',
  state: 'SP',
  zipCode: cep,
  isDefault: true,
  lat: -23.5,
  lng: -46.6,
  coordinateSource: 'USER_PIN',
);

class Addresses extends Fake implements AddressRepository {
  final requests = <String, Completer<AddressModel>>{};
  @override
  Future<AddressModel> resolveZipCode(String cep) =>
      (requests[cep] = Completer<AddressModel>()).future;
}

Finder field(String label) => find.byWidgetPredicate(
  (widget) => widget is TextField && widget.decoration?.labelText == label,
);

void main() {
  testWidgets('an old CEP response does not overwrite the current address', (
    tester,
  ) async {
    final repository = Addresses();
    final provider = AddressProvider(repository: repository);
    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: provider,
        child: MaterialApp(
          home: Scaffold(body: AddressFormSheet(onSave: (_) async {})),
        ),
      ),
    );
    await tester.enterText(field('CEP'), '01001000');
    await tester.pump();
    await tester.enterText(field('CEP'), '01310100');
    await tester.pump();
    repository.requests['01310100']!.complete(address('01310100', 'Rua atual'));
    await tester.pump();
    repository.requests['01001000']!.complete(
      address('01001000', 'Rua antiga'),
    );
    await tester.pump();
    expect(
      tester.widget<TextField>(field('Rua / Avenida')).controller!.text,
      'Rua atual',
    );
    await tester.pumpWidget(const SizedBox());
    provider.dispose();
  });

  testWidgets(
    'changing the house number invalidates a previously confirmed pin',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AddressFormSheet(
              address: address('01001000', 'Rua inicial'),
              onSave: (_) async {},
            ),
          ),
        ),
      );
      expect(find.text('Ponto confirmado · alterar'), findsOneWidget);
      await tester.ensureVisible(field('Número'));
      await tester.enterText(field('Número'), '99');
      await tester.pump();
      expect(find.text('Ponto confirmado · alterar'), findsNothing);
      expect(find.text('Marcar entrada no mapa'), findsOneWidget);
    },
  );
}
