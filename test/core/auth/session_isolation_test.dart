import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:meatshop_mobile/core/auth/session_coordinator.dart';
import 'package:meatshop_mobile/core/auth/session_refresher.dart';
import 'package:meatshop_mobile/core/auth/session_store.dart';
import 'package:meatshop_mobile/core/auth/session_tokens.dart';
import 'package:meatshop_mobile/core/network/api_failure.dart';

const a = SessionTokens(accessToken: 'a', refreshToken: 'refresh-a');
const b = SessionTokens(accessToken: 'b', refreshToken: 'refresh-b');
const renewed = SessionTokens(
  accessToken: 'renewed-a',
  refreshToken: 'renewed-refresh-a',
);

class Store implements SessionStore {
  SessionTokens? tokens = a;
  Completer<void>? writing;
  Completer<SessionTokens?>? reading;
  @override
  Future<SessionTokens?> read() async =>
      reading == null ? tokens : reading!.future;
  @override
  Future<void> write(SessionTokens value) async {
    await writing?.future;
    tokens = value;
  }

  @override
  Future<void> clear() async {
    tokens = null;
  }
}

class Refresher implements SessionRefresher {
  final pending = <Completer<SessionTokens>>[];
  @override
  Future<SessionTokens> refresh(String token) {
    final value = Completer<SessionTokens>();
    pending.add(value);
    return value.future;
  }
}

void main() {
  for (final replace in [false, true]) {
    test(
      'ignores late renewal after ${replace ? 'another login' : 'logout'}',
      () async {
        final store = Store();
        final refresher = Refresher();
        final session = SessionCoordinator(store: store, refresher: refresher);
        final pending = session.refresh();
        final failure = expectLater(
          pending,
          throwsA(
            isA<ApiFailure>().having((e) => e.code, 'code', 'SESSION_CHANGED'),
          ),
        );
        await Future<void>.delayed(Duration.zero);
        await session.clear();
        if (replace) await session.save(b);
        refresher.pending.single.complete(renewed);
        await failure;
        expect(session.current, replace ? b : null);
        expect(store.tokens, replace ? b : null);
      },
    );
  }

  test(
    'late rejected renewal cannot expire another account or its renewal',
    () async {
      final store = Store();
      final refresher = Refresher();
      final session = SessionCoordinator(store: store, refresher: refresher);
      var expirations = 0;
      final subscription = session.expirations.listen((_) => expirations++);
      addTearDown(subscription.cancel);
      final old = session.refresh();
      final oldFailure = expectLater(old, throwsA(isA<ApiFailure>()));
      await Future<void>.delayed(Duration.zero);
      await session.save(b);
      final current = session.refresh();
      await Future<void>.delayed(Duration.zero);
      refresher.pending.first.completeError(
        const ApiFailure(kind: ApiFailureKind.unauthorized, message: 'Expired'),
      );
      await oldFailure;
      expect(session.current, b);
      expect(session.refresh(), same(current));
      refresher.pending.last.complete(b);
      await current;
      expect(expirations, 0);
    },
  );

  test(
    'logout is persisted after a renewal already writing to storage',
    () async {
      final store = Store();
      final refresher = Refresher();
      final session = SessionCoordinator(store: store, refresher: refresher);
      final pending = session.refresh();
      final failure = expectLater(pending, throwsA(isA<ApiFailure>()));
      await Future<void>.delayed(Duration.zero);
      store.writing = Completer();
      refresher.pending.single.complete(renewed);
      await Future<void>.delayed(Duration.zero);
      final clearing = session.clear();
      store.writing!.complete();
      await clearing;
      await failure;
      expect(session.current, isNull);
      expect(store.tokens, isNull);
    },
  );

  test('initial storage read cannot resurrect a cleared session', () async {
    final store = Store()..reading = Completer();
    final session = SessionCoordinator(store: store, refresher: Refresher());
    final pending = session.initialize();
    await session.clear();
    store.reading!.complete(a);
    await pending;
    expect(session.current, isNull);
  });
}
