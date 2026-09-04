import 'package:flutter_test/flutter_test.dart';
import 'package:meatshop_mobile/models/address_model.dart';

void main() {
  AddressModel address(String label) => AddressModel(
    id: '',
    label: label,
    street: 'Rua A',
    number: '1',
    complement: '',
    neighborhood: 'Centro',
    city: 'Goiânia',
    state: 'GO',
    zipCode: '74000-000',
    isDefault: true,
  );

  test('normaliza os apelidos aceitos pelo contrato da API', () {
    expect(address('casa').toApi()['label'], 'Casa');
    expect(address('TRABALHO').toApi()['label'], 'Trabalho');
    expect(address('Minha chácara').toApi()['label'], 'Outro');
  });
}
