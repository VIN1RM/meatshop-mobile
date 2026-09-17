import 'package:flutter_test/flutter_test.dart';
import 'package:meatshop_mobile/core/auth/session_tokens.dart';
import 'package:meatshop_mobile/infra/auth/secure_key_value_store.dart';
import 'package:meatshop_mobile/infra/auth/secure_session_store.dart';

void main() {
  group('SecureSessionStore', () {
    test('persists, restores, and removes both tokens', () async {
      final storage = _MemorySecureStore();
      final store = SecureSessionStore(storage);
      const tokens = SessionTokens(
        accessToken: 'access-secret',
        refreshToken: 'refresh-secret',
      );

      await store.write(tokens);
      final restored = await store.read();

      expect(restored?.accessToken, tokens.accessToken);
      expect(restored?.refreshToken, tokens.refreshToken);

      await store.clear();
      expect(await store.read(), isNull);
    });

    test(
      'discards a partial session instead of using inconsistent credentials',
      () async {
        final storage = _MemorySecureStore()
          ..values['meatshop.auth.access_token.v1'] = 'orphan';
        final store = SecureSessionStore(storage);

        expect(await store.read(), isNull);
        expect(storage.values, isEmpty);
      },
    );
  });
}

final class _MemorySecureStore implements SecureKeyValueStore {
  final Map<String, String> values = {};

  @override
  Future<void> delete(String key) async => values.remove(key);

  @override
  Future<String?> read(String key) async => values[key];

  @override
  Future<void> write(String key, String value) async => values[key] = value;
}
