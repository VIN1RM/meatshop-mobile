import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meatshop_mobile/core/exceptions/login_blocked_exception.dart';
import 'package:meatshop_mobile/infra/auth/secure_key_value_store.dart';
import 'package:meatshop_mobile/services/login_attempts_service.dart';

class MemoryStore implements SecureKeyValueStore {
  final values = <String, String>{};
  @override
  Future<String?> read(String key) async => values[key];
  @override
  Future<void> write(String key, String value) async {
    values[key] = value;
  }

  @override
  Future<void> delete(String key) async {
    values.remove(key);
  }
}

void main() {
  late MemoryStore storage;
  late DateTime now;
  late LoginAttemptsService service;
  Future<void> invalid() async =>
      throw FirebaseAuthException(code: 'invalid-credential');
  setUp(() {
    storage = MemoryStore();
    now = DateTime.utc(2026, 10, 15);
    service = LoginAttemptsService(storage: storage, now: () => now);
  });
  test(
    'fifth failure blocks without calling Firebase again and survives restart',
    () async {
      for (var i = 0; i < 4; i++) {
        await expectLater(
          service.authenticate(' Test@example.com ', invalid),
          throwsA(isA<FirebaseAuthException>()),
        );
      }
      await expectLater(
        service.authenticate('test@example.com', invalid),
        throwsA(isA<LoginBlockedException>()),
      );
      final restored = LoginAttemptsService(storage: storage, now: () => now);
      var called = false;
      await expectLater(
        restored.authenticate('test@example.com', () async {
          called = true;
        }),
        throwsA(isA<LoginBlockedException>()),
      );
      expect(called, isFalse);
      expect(storage.values.keys.single, isNot(contains('example.com')));
      now = now.add(const Duration(minutes: 5));
      await restored.authenticate('test@example.com', () async {});
      expect(storage.values, isEmpty);
    },
  );
  test(
    'network errors and provider throttling do not count as wrong passwords',
    () async {
      for (final code in [
        'network-request-failed',
        'too-many-requests',
        'user-disabled',
      ]) {
        await expectLater(
          service.authenticate(
            'a@b.com',
            () async => throw FirebaseAuthException(code: code),
          ),
          throwsA(isA<FirebaseAuthException>()),
        );
      }
      expect(storage.values, isEmpty);
    },
  );
  test(
    'successful authentication clears failures only for the matching identity',
    () async {
      await expectLater(
        service.authenticate('a@b.com', invalid),
        throwsA(isA<FirebaseAuthException>()),
      );
      await expectLater(
        service.authenticate('c@d.com', invalid),
        throwsA(isA<FirebaseAuthException>()),
      );
      await service.authenticate('A@B.COM', () async {});
      expect(storage.values.length, 1);
    },
  );
  test('failures reset after five minutes without attempts', () async {
    for (var i = 0; i < 4; i++) {
      await expectLater(
        service.authenticate('a@b.com', invalid),
        throwsA(isA<FirebaseAuthException>()),
      );
    }
    now = now.add(const Duration(minutes: 5));
    await expectLater(
      service.authenticate('a@b.com', invalid),
      throwsA(isA<FirebaseAuthException>()),
    );
  });
}
