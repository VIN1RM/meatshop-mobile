import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:meatshop_mobile/core/auth/session_coordinator.dart';
import 'package:meatshop_mobile/core/auth/session_refresher.dart';
import 'package:meatshop_mobile/core/auth/session_store.dart';
import 'package:meatshop_mobile/core/auth/session_tokens.dart';
import 'package:meatshop_mobile/core/network/api_failure.dart';

void main() {
  group('SessionCoordinator', () {
    test('shares a single renewal across concurrent calls', () async {
      final store = _MemorySessionStore(
        const SessionTokens(accessToken: 'old', refreshToken: 'refresh-old'),
      );
      final refresher = _ControlledRefresher();
      final coordinator = SessionCoordinator(
        store: store,
        refresher: refresher,
      );

      final first = coordinator.refresh();
      final second = coordinator.refresh();
      await Future<void>.delayed(Duration.zero);

      expect(refresher.calls, 1);
      refresher.complete(
        const SessionTokens(accessToken: 'new', refreshToken: 'refresh-new'),
      );

      expect(await first, same(await second));
      expect(store.tokens?.accessToken, 'new');
    });

    test('clears the session when renewal fails definitively', () async {
      final store = _MemorySessionStore(
        const SessionTokens(accessToken: 'old', refreshToken: 'invalid'),
      );
      final coordinator = SessionCoordinator(
        store: store,
        refresher: _FailingRefresher(),
      );

      await expectLater(coordinator.refresh(), throwsA(isA<ApiFailure>()));

      expect(store.tokens, isNull);
      expect(coordinator.current, isNull);
    });

    test(
      'preserves the refresh token during a temporary network failure',
      () async {
        final store = _MemorySessionStore(
          const SessionTokens(accessToken: 'old', refreshToken: 'still-valid'),
        );
        final coordinator = SessionCoordinator(
          store: store,
          refresher: _NetworkFailingRefresher(),
        );

        await expectLater(coordinator.refresh(), throwsA(isA<ApiFailure>()));

        expect(store.tokens?.refreshToken, 'still-valid');
      },
    );
  });
}

final class _MemorySessionStore implements SessionStore {
  _MemorySessionStore(this.tokens);

  SessionTokens? tokens;

  @override
  Future<void> clear() async => tokens = null;

  @override
  Future<SessionTokens?> read() async => tokens;

  @override
  Future<void> write(SessionTokens tokens) async => this.tokens = tokens;
}

final class _ControlledRefresher implements SessionRefresher {
  final Completer<SessionTokens> _completer = Completer<SessionTokens>();
  int calls = 0;

  @override
  Future<SessionTokens> refresh(String refreshToken) {
    calls++;
    return _completer.future;
  }

  void complete(SessionTokens tokens) => _completer.complete(tokens);
}

final class _FailingRefresher implements SessionRefresher {
  @override
  Future<SessionTokens> refresh(String refreshToken) async {
    throw const ApiFailure(
      kind: ApiFailureKind.unauthorized,
      message: 'Sessão expirada.',
    );
  }
}

final class _NetworkFailingRefresher implements SessionRefresher {
  @override
  Future<SessionTokens> refresh(String refreshToken) async {
    throw const ApiFailure(
      kind: ApiFailureKind.network,
      message: 'Sem conexão.',
    );
  }
}
