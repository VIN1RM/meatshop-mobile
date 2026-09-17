import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('password registration verifies e-mail before backend exchange', () {
    final identitySource = File(
      'lib/services/firebase_identity_service.dart',
    ).readAsStringSync();
    final providerSource = File(
      'lib/providers/auth/auth_provider.dart',
    ).readAsStringSync();

    final createIdentity = identitySource.indexOf(
      'createUserWithEmailAndPassword',
    );
    final sendVerification = identitySource.indexOf(
      'sendEmailVerification()',
      createIdentity,
    );
    expect(createIdentity, isNonNegative);
    expect(sendVerification, greaterThan(createIdentity));

    final registerFlow = providerSource.indexOf(
      'Future<bool> _registerWithBackend',
    );
    final unverifiedGuard = providerSource.indexOf(
      'if (!firebaseUser.emailVerified)',
      registerFlow,
    );
    final tokenExchange = providerSource.indexOf(
      'final idToken = await firebaseUser.getIdToken(true)',
      registerFlow,
    );
    expect(registerFlow, isNonNegative);
    expect(unverifiedGuard, greaterThan(registerFlow));
    expect(tokenExchange, greaterThan(unverifiedGuard));
  });
}
