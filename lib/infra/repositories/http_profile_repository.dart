import 'dart:typed_data';

import '../../core/config/api_config.dart';
import '../../core/network/api_failure.dart';
import '../../data/repositories/profile_repository.dart';
import '../../models/user_model.dart';
import '../http/api_client.dart';

final class HttpProfileRepository implements ProfileRepository {
  HttpProfileRepository(this._client, this._config);

  final ApiClient _client;
  final ApiConfig _config;

  @override
  Future<UserModel> getProfile() => _client.get(
    '/users/me',
    decode: (json) => _user(_map(_map(json)['user'])),
  );

  @override
  Future<UserModel> updateProfile({
    required String name,
    required String email,
    required String phone,
  }) => _client.patch(
    '/users/me',
    body: {
      'name': name.trim(),
      'email': email.trim(),
      'phone': phone.replaceAll(RegExp(r'\D'), ''),
    },
    decode: (json) => _user(_map(_map(json)['user'])),
  );

  @override
  Future<String> uploadAvatar({
    required Uint8List bytes,
    required String fileName,
    required String contentType,
  }) => _client.postMultipart(
    '/users/me/avatar',
    bytes: bytes,
    fileName: fileName,
    contentType: contentType,
    decode: (json) =>
        _config.resolveAsset(_map(json)['avatar_url'] as String? ?? ''),
  );

  @override
  Future<void> clearAvatar() =>
      _client.delete('/users/me/avatar', decode: (_) {});

  UserModel _user(Map<String, Object?> json) => UserModel.fromApi(
    json,
    _config.resolveAsset(json['avatar_url'] as String? ?? ''),
  );

  static Map<String, Object?> _map(Object? value) {
    if (value is Map<String, Object?>) return value;
    throw const ApiFailure(
      kind: ApiFailureKind.malformedResponse,
      message: 'O perfil retornado é inválido.',
      code: 'MALFORMED_PROFILE_RESPONSE',
    );
  }
}
