import '../../core/auth/session_store.dart';
import '../../core/auth/session_tokens.dart';
import 'secure_key_value_store.dart';

final class SecureSessionStore implements SessionStore {
  SecureSessionStore(this._storage);

  static const _accessTokenKey = 'meatshop.auth.access_token.v1';
  static const _refreshTokenKey = 'meatshop.auth.refresh_token.v1';

  final SecureKeyValueStore _storage;

  @override
  Future<SessionTokens?> read() async {
    final values = await Future.wait([
      _storage.read(_accessTokenKey),
      _storage.read(_refreshTokenKey),
    ]);
    final accessToken = values[0];
    final refreshToken = values[1];
    if (accessToken == null && refreshToken == null) return null;
    if (accessToken == null || refreshToken == null) {
      await clear();
      return null;
    }
    return SessionTokens(accessToken: accessToken, refreshToken: refreshToken);
  }

  @override
  Future<void> write(SessionTokens tokens) async {
    await _storage.write(_refreshTokenKey, tokens.refreshToken);
    await _storage.write(_accessTokenKey, tokens.accessToken);
  }

  @override
  Future<void> clear() async {
    await Future.wait([
      _storage.delete(_accessTokenKey),
      _storage.delete(_refreshTokenKey),
    ]);
  }
}
