import 'package:flutter_test/flutter_test.dart';
import 'package:meatshop_mobile/core/auth/password_policy.dart';

void main() {
  test('requires all password components and at least eight characters', () {
    for (final password in [
      'Ab1!xy',
      'Ab1!xyz',
      'abcdef1!',
      'ABCDEF1!',
      'Abcdefg!',
      'Abcdef12',
      'Abcdef1 ',
    ]) {
      expect(PasswordPolicy.isValid(password), isFalse, reason: password);
      expect(() => PasswordPolicy.validate(password), throwsArgumentError);
    }
    expect(PasswordPolicy.isValid('Abcdef1!'), isTrue);
    expect(PasswordPolicy.isValid('Abcdef1_'), isTrue);
    expect(PasswordPolicy.isValid('A' * 65 + 'a1!'), isFalse);
  });
}
