import '../network/api_failure.dart';
import 'session_refresher.dart';
import 'session_store.dart';
import 'session_tokens.dart';

final class SessionCoordinator {
  SessionCoordinator({
    required SessionStore store,
    required SessionRefresher refresher,
  }) : _store = store,
       _refresher = refresher;

  final SessionStore _store;
  final SessionRefresher _refresher;

  SessionTokens? _tokens;
  Future<void>? _initializing;
  Future<SessionTokens>? _refreshing;

  SessionTokens? get current => _tokens;

  Future<void> initialize() {
    final pending = _initializing;
    if (pending != null) return pending;
    final operation = _initialize();
    _initializing = operation;
    return operation;
  }

  Future<void> _initialize() async {
    _tokens ??= await _store.read();
  }

  Future<void> save(SessionTokens tokens) async {
    await _store.write(tokens);
    _tokens = tokens;
  }

  Future<void> clear() async {
    _tokens = null;
    await _store.clear();
  }

  Future<SessionTokens> refresh() {
    final pending = _refreshing;
    if (pending != null) return pending;
    final operation = _refreshOnce();
    _refreshing = operation;
    return operation;
  }

  Future<SessionTokens> _refreshOnce() async {
    try {
      await initialize();
      final refreshToken = _tokens?.refreshToken;
      if (refreshToken == null || refreshToken.isEmpty) {
        throw const ApiFailure(
          kind: ApiFailureKind.unauthorized,
          message: 'Sua sessão expirou. Entre novamente.',
          code: 'SESSION_EXPIRED',
        );
      }
      final refreshed = await _refresher.refresh(refreshToken);
      await save(refreshed);
      return refreshed;
    } on ApiFailure catch (failure) {
      if (failure.kind == ApiFailureKind.unauthorized ||
          failure.kind == ApiFailureKind.forbidden) {
        await clear();
      }
      rethrow;
    } finally {
      _refreshing = null;
    }
  }
}
