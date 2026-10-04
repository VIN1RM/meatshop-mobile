import 'dart:async';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:meatshop_mobile/data/repositories/profile_repository.dart';
import 'package:meatshop_mobile/models/user_model.dart';
import 'package:meatshop_mobile/providers/user/user_provider.dart';

void main() {
  test('ignores a profile response completed after session cleanup', () async {
    final repository = _FakeProfileRepository();
    final provider = UserProvider(repository: repository);

    final loading = provider.loadUser('old-firebase-user');
    provider.clear();
    repository.pending.complete(_user('Old user'));
    await loading;

    expect(provider.user, isNull);
    expect(provider.isLoading, isFalse);
  });
}

UserModel _user(String name) => UserModel(
  uid: '7',
  name: name,
  email: 'old@example.com',
  cpf: '12345678901',
  phone: '11999999999',
  photoUrl: '',
);

final class _FakeProfileRepository implements ProfileRepository {
  final pending = Completer<UserModel>();

  @override
  Future<void> clearAvatar() async {}

  @override
  Future<UserModel> getProfile() => pending.future;

  @override
  Future<UserModel> updateProfile({
    required String name,
    required String email,
    required String phone,
  }) async => _user(name);

  @override
  Future<String> uploadAvatar({
    required Uint8List bytes,
    required String fileName,
    required String contentType,
  }) async => '';
}
