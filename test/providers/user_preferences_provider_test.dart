import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:meatshop_mobile/data/repositories/notification_repository.dart';
import 'package:meatshop_mobile/models/user_preferences.dart';
import 'package:meatshop_mobile/providers/user_preferences_provider.dart';
import 'package:meatshop_mobile/services/user_preferences_service.dart';

class PreferencesBackend implements NotificationRepository {
  UserPreferences saved = const UserPreferences();
  Completer<UserPreferences>? load;
  Completer<void>? firstSave;
  bool failFirstSave = false;
  final writes = <UserPreferences>[];

  @override
  Future<UserPreferences> getPreferences() async =>
      load == null ? saved : load!.future;
  @override
  Future<UserPreferences> updatePreferences(UserPreferences value) async {
    writes.add(value);
    if (writes.length == 1) {
      await firstSave?.future;
      if (failFirstSave) throw StateError('offline');
    }
    saved = value;
    return value;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late PreferencesBackend backend;
  late UserPreferencesProvider provider;
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    backend = PreferencesBackend();
    UserPreferencesService.instance.configure(backend: backend);
    provider = UserPreferencesProvider();
  });
  tearDown(() => provider.dispose());

  test(
    'serializes independent changes and preserves the latest choices',
    () async {
      await provider.loadForUser('a');
      backend.firstSave = Completer<void>();
      final first = provider.setNotifOrders('a', false);
      final second = provider.setNotifDelivery('a', false);
      await Future<void>.delayed(Duration.zero);
      expect(backend.writes.length, 1);
      backend.firstSave!.complete();
      expect(await first, isTrue);
      expect(await second, isTrue);
      expect(backend.saved.notifOrders, isFalse);
      expect(backend.saved.notifDelivery, isFalse);
    },
  );

  test(
    'a failed change does not leak into a later successful change',
    () async {
      await provider.loadForUser('a');
      backend.failFirstSave = true;
      final first = provider.setNotifOrders('a', false);
      final second = provider.setNotifDelivery('a', false);
      expect(await first, isFalse);
      expect(await second, isTrue);
      expect(backend.saved.notifOrders, isTrue);
      expect(backend.saved.notifDelivery, isFalse);
      expect(provider.notifOrders, isTrue);
    },
  );

  test('late loading cannot restore a signed-out account', () async {
    backend.load = Completer<UserPreferences>();
    final pending = provider.loadForUser('a');
    provider.clear();
    backend.load!.complete(const UserPreferences(notifOrders: false));
    await pending;
    expect(provider.notifOrders, isTrue);
    expect(provider.loading, isFalse);
  });

  test('queued changes do not write through a different account', () async {
    await provider.loadForUser('a');
    final pending = provider.setNotifOrders('a', false);
    provider.clear();
    await provider.loadForUser('b');
    expect(await pending, isFalse);
    expect(backend.writes, isEmpty);
  });
}
