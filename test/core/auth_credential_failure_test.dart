import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meatshop_mobile/core/network/api_failure.dart';
import 'package:meatshop_mobile/services/firebase_identity_service.dart';

void main() {
  test(
    'preserves account lock code and remaining duration across identity boundary',
    () {
      const failure = ApiFailure(
        kind: ApiFailureKind.rateLimited,
        message: 'Locked',
        statusCode: 429,
        code: 'ACCOUNT_LOCKED',
        retryAfter: Duration(seconds: 123),
      );
      expect(() => rethrowCredentialFailure(failure), throwsA(same(failure)));
      expect(failure.retryAfter, const Duration(seconds: 123));
    },
  );

  test(
    'keeps invalid credentials compatible with Firebase error localization',
    () {
      const failure = ApiFailure(
        kind: ApiFailureKind.unauthorized,
        message: 'Invalid',
        statusCode: 401,
      );
      expect(
        () => rethrowCredentialFailure(failure),
        throwsA(
          isA<FirebaseAuthException>().having(
            (error) => error.code,
            'code',
            'invalid-credential',
          ),
        ),
      );
    },
  );
}
