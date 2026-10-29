import 'package:flutter_test/flutter_test.dart';
import 'package:meatshop_mobile/core/auth/password_policy.dart';
import 'package:meatshop_mobile/core/utils/field_validations.dart';
import 'package:meatshop_mobile/core/utils/input_masks.dart';

void main() {
  for (final value in ['52998224725', '529.982.247-25', ' 111.444.777-35 ']) {
    test('accepts CPF $value with valid verifier digits', () {
      expect(FieldValidations.cpf(value), isNull);
    });
  }
  for (final value in [
    '',
    '11111111111',
    '00000000000',
    '52998224724',
    '52998224715',
    '5299822472',
    '529982247250',
    'abc52998224725',
  ]) {
    test('rejects malformed CPF $value', () {
      expect(FieldValidations.cpf(value), isNotNull);
    });
  }
  for (final value in [
    '11222333000181',
    '11.222.333/0001-81',
    '04.252.011/0001-10',
  ]) {
    test(
      'accepts CNPJ $value',
      () => expect(FieldValidations.cnpj(value), isNull),
    );
  }
  for (final value in [
    '',
    '11111111111111',
    '00000000000000',
    '11222333000180',
    '11222333000191',
    '1122233300018',
    '112223330001810',
  ]) {
    test(
      'rejects invalid CNPJ $value',
      () => expect(FieldValidations.cnpj(value), isNotNull),
    );
  }
  for (final value in [
    'user@example.com',
    ' user+tag@example.com.br ',
    'first.last@meatshop.local',
    "o'connor@example.com",
  ]) {
    test(
      'accepts email $value',
      () => expect(FieldValidations.email(value), isNull),
    );
  }
  for (final value in [
    '',
    'user@',
    '@example.com',
    'user@@example.com',
    'user example@test.com',
    'user@example',
    '.user@example.com',
    'user..name@example.com',
    'user@-example.com',
    'user@example..com',
    'user@example.123',
  ]) {
    test(
      'rejects invalid email $value',
      () => expect(FieldValidations.email(value), isNotNull),
    );
  }
  for (final value in [
    '11987654321',
    '(62) 99999-0003',
    '+55 (11) 98765-4321',
    '5511987654321',
  ]) {
    test(
      'accepts mobile phone $value',
      () => expect(FieldValidations.mobilePhone(value), isNull),
    );
  }
  for (final value in [
    '',
    '00987654321',
    '52987654321',
    '1132345678',
    '11887654321',
    '1198765432',
    '119876543210',
    '1198765432x',
    '+11987654321',
    '++5511987654321',
  ]) {
    test(
      'rejects invalid mobile phone $value',
      () => expect(FieldValidations.mobilePhone(value), isNotNull),
    );
  }
  test(
    'normalizes the Brazilian country code before masking or sending to the API',
    () {
      expect(
        FieldValidations.normalizeMobilePhone('+55 (11) 98765-4321'),
        '11987654321',
      );
      expect(InputMasks.phone('+55 (11) 98765-4321'), '(11) 98765-4321');
      expect(
        PhoneInputFormatter()
            .formatEditUpdate(
              TextEditingValue.empty,
              const TextEditingValue(text: '+55 (11) 98765-4321'),
            )
            .text,
        '(11) 98765-4321',
      );
    },
  );
  test('validates CEP and UF without requiring an external provider', () {
    for (final value in ['01310100', '01310-100']) {
      expect(FieldValidations.cep(value), isNull);
    }
    for (final value in ['', '0131010', '013101000', 'abc01310100']) {
      expect(FieldValidations.cep(value), isNotNull);
    }
    expect(FieldValidations.state(' sp '), isNull);
    expect(FieldValidations.state('XX'), isNotNull);
    expect(FieldValidations.state('S'), isNotNull);
  });
  test('keeps login passwords separate from new password policy', () {
    expect(
      FieldValidations.existingPassword('123456', minimumLength: 6),
      isNull,
    );
    expect(FieldValidations.newPassword('123456'), isNotNull);
    for (final value in [
      'Abc123!x',
      'Abc123!${'x' * 57}',
      'Abc123!${'x' * 58}',
    ]) {
      expect(
        FieldValidations.newPassword(value) == null,
        PasswordPolicy.isValid(value),
      );
    }
    expect(
      FieldValidations.passwordConfirmation('Abc123!x', 'Abc123!x'),
      isNull,
    );
    expect(
      FieldValidations.passwordConfirmation(' Abc123!x', 'Abc123!x'),
      isNotNull,
    );
    expect(FieldValidations.passwordConfirmation(null, ''), isNotNull);
  });
  test('validates text limits, required choices and names', () {
    expect(FieldValidations.name('  '), isNotNull);
    expect(FieldValidations.name('A'), isNotNull);
    expect(FieldValidations.name('João D’Ávila'), isNull);
    expect(FieldValidations.text('', optional: true, maximumLength: 5), isNull);
    expect(
      FieldValidations.text('123456', optional: true, maximumLength: 5),
      isNotNull,
    );
    expect(
      FieldValidations.requiredAny(['', 'GO'], message: 'Required'),
      isNull,
    );
    expect(
      FieldValidations.requiredAny([null, ' '], message: 'Required'),
      'Required',
    );
  });
  test('validates old and Mercosur plates and preserves year boundaries', () {
    for (final value in ['ABC1234', 'abc-1234', 'ABC1D23']) {
      expect(FieldValidations.licensePlate(value), isNull);
    }
    for (final value in ['', 'ABC123', 'ABC12345', '123ABCD']) {
      expect(FieldValidations.licensePlate(value), isNotNull);
    }
    expect(FieldValidations.vehicleYear('1950', currentYear: 2026), isNull);
    expect(FieldValidations.vehicleYear('2027', currentYear: 2026), isNull);
    expect(FieldValidations.vehicleYear('2028', currentYear: 2026), isNotNull);
    expect(FieldValidations.vehicleYear('1949', currentYear: 2026), isNotNull);
  });
  test(
    'parses money consistently and rejects non-finite or overly precise values',
    () {
      expect(FieldValidations.parseMoney('1.234,56'), 1234.56);
      expect(FieldValidations.parseMoney('1234.56'), 1234.56);
      expect(FieldValidations.parseMoney('1234,56'), 1234.56);
      for (final value in [
        '-1',
        'NaN',
        'Infinity',
        '1e3',
        '1,234',
        '1.234',
        '1.2.3',
        '1,234.56',
      ]) {
        expect(FieldValidations.money(value), isNotNull);
      }
      expect(FieldValidations.money('0'), isNotNull);
      expect(FieldValidations.money('0', minimum: 0), isNull);
      expect(FieldValidations.money('100', maximum: 99), isNotNull);
    },
  );
  test('requires exactly six numerical verification digits', () {
    expect(FieldValidations.verificationCode('012345'), isNull);
    for (final value in [null, '12345', '1234567', 'abcdef']) {
      expect(FieldValidations.verificationCode(value), isNotNull);
    }
  });
}
