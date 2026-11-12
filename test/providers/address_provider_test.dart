import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:meatshop_mobile/data/repositories/address_repository.dart';
import 'package:meatshop_mobile/models/address_model.dart';
import 'package:meatshop_mobile/providers/user/address_provider.dart';

AddressModel address(String id, {bool isDefault = false}) => AddressModel(
  id: id,
  label: 'Casa',
  street: 'Rua de teste',
  number: '10',
  complement: '',
  neighborhood: 'Centro',
  city: 'Goiânia',
  state: 'GO',
  zipCode: '74000000',
  isDefault: isDefault,
);

void main() {
  test(
    'deletes the only address loaded from a fixed-length list and notifies the empty state',
    () async {
      final repository = _Addresses(
        [address('35', isDefault: true)].toList(growable: false),
      );
      final provider = AddressProvider(repository: repository);
      addTearDown(provider.dispose);
      await provider.load('user');
      var notifications = 0;
      provider.addListener(() => notifications++);
      await provider.delete('user', '35');
      expect(repository.deleted, ['35']);
      expect(provider.addresses, isEmpty);
      expect(notifications, 1);
      expect(repository.rows, hasLength(1));
    },
  );
  test(
    'adding after loading a fixed-length empty list works without changing repository-owned data',
    () async {
      final repository = _Addresses(List<AddressModel>.empty(growable: false));
      final provider = AddressProvider(repository: repository);
      addTearDown(provider.dispose);
      await provider.load('user');
      await provider.add('user', address('36'));
      expect(provider.addresses.single.id, '36');
      expect(repository.rows, isEmpty);
      expect(() => provider.addresses.clear(), throwsUnsupportedError);
    },
  );
  test(
    'updating and deleting work with an unmodifiable repository list',
    () async {
      final original = address('35');
      final repository = _Addresses(
        List.unmodifiable([original, address('36')]),
      );
      final provider = AddressProvider(repository: repository);
      addTearDown(provider.dispose);
      await provider.load('user');
      await provider.update('user', original.copyWith(street: 'Outra rua'));
      await provider.delete('user', '36');
      expect(provider.addresses.single.street, 'Outra rua');
      expect(repository.rows.first.street, 'Rua de teste');
      expect(repository.rows, hasLength(2));
    },
  );
  test('a failed deletion keeps the address available for retry', () async {
    final repository = _Addresses([address('35')])..fail = true;
    final provider = AddressProvider(repository: repository);
    addTearDown(provider.dispose);
    await provider.load('user');
    await expectLater(provider.delete('user', '35'), throwsStateError);
    expect(provider.addresses.single.id, '35');
    repository.fail = false;
    await provider.delete('user', '35');
    expect(provider.addresses, isEmpty);
  });
  test(
    'a deletion completed after session cleanup cannot change the next session',
    () async {
      final repository = _Addresses([address('35')]);
      final provider = AddressProvider(repository: repository);
      addTearDown(provider.dispose);
      await provider.load('old-user');
      repository.pending = Completer<void>();
      final deleting = provider.delete('old-user', '35');
      provider.clear();
      repository.rows = [address('36')];
      await provider.load('new-user');
      repository.pending!.complete();
      await deleting;
      expect(provider.addresses.single.id, '36');
    },
  );
}

class _Addresses implements AddressRepository {
  _Addresses(this.rows);
  List<AddressModel> rows;
  final deleted = <String>[];
  bool fail = false;
  Completer<void>? pending;
  @override
  Future<List<AddressModel>> list() async => rows;
  @override
  Future<AddressModel> create(AddressModel value) async => value;
  @override
  Future<AddressModel> update(AddressModel value) async => value;
  @override
  Future<void> delete(String id) async {
    if (fail) throw StateError('Offline');
    await pending?.future;
    deleted.add(id);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
