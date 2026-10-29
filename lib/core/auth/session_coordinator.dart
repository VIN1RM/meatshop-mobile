import 'dart:async';
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
  final _expiration = StreamController<void>.broadcast();
  Stream<void> get expirations => _expiration.stream;
  SessionTokens? _tokens;
  Future<void>? _initializing;
  Future<SessionTokens>? _refreshing;
  Future<void> _writes = Future.value();
  int _generation = 0;

  SessionTokens? get current => _tokens;
  int get generation => _generation;

  Future<void> initialize() => _initializing ??= _initialize();

  Future<void> _initialize() async {
    final generation = _generation;
    try {
      await _writes;
      final tokens = await _store.read();
      if (generation == _generation) _tokens ??= tokens;
    } catch (_) {
      _initializing = null;
      rethrow;
    }
  }

  Future<void> _persist(Future<void> Function() operation) {
    final next = _writes.then((_) => operation());
    _writes = next.catchError((Object _) {});
    return next;
  }

  Future<void> save(SessionTokens tokens) {
    final generation = ++_generation;
    _refreshing = null;
    _tokens = null;
    return _persist(() async {
      await _store.write(tokens);
      if (generation == _generation) _tokens = tokens;
    });
  }

  Future<void> clear() {
    ++_generation;
    _refreshing = null;
    _tokens = null;
    return _persist(_store.clear);
  }

  Future<SessionTokens> refresh() => _refreshing ??= _refreshOnce(_generation);

  Future<SessionTokens> _refreshOnce(int generation) async {
    try {
      await initialize();
      _requireGeneration(generation);
      final refreshToken = _tokens?.refreshToken;
      if (refreshToken == null || refreshToken.isEmpty) {
        throw const ApiFailure(
          kind: ApiFailureKind.unauthorized,
          message: 'Sua sessão expirou. Entre novamente.',
          code: 'SESSION_EXPIRED',
        );
      }
      final refreshed = await _refresher.refresh(refreshToken);
      _requireGeneration(generation);
      await _persist(() async {
        _requireGeneration(generation);
        await _store.write(refreshed);
        if (generation == _generation) _tokens = refreshed;
      });
      _requireGeneration(generation);
      return refreshed;
    } on ApiFailure catch (failure) {
      if (generation == _generation &&
          (failure.kind == ApiFailureKind.unauthorized ||
              failure.kind == ApiFailureKind.forbidden)) {
        final invalidatedGeneration = _generation + 1;
        await clear();
        if (_generation == invalidatedGeneration) _expiration.add(null);
      }
      rethrow;
    } finally {
      if (generation == _generation) _refreshing = null;
    }
  }

  void _requireGeneration(int generation) {
    if (generation == _generation) return;
    throw const ApiFailure(
      kind: ApiFailureKind.cancelled,
      message: 'A sessão mudou. Tente novamente.',
      code: 'SESSION_CHANGED',
    );
  }
}
