import '../../core/auth/session_coordinator.dart';
import '../../core/auth/session_tokens.dart';
import '../../core/enums/app_profile.dart';
import '../../core/network/api_failure.dart';
import '../../data/repositories/federated_auth_repository.dart';
import '../http/api_client.dart';
import '../http/json_http_transport.dart';

final class HttpFederatedAuthRepository implements FederatedAuthRepository {
  HttpFederatedAuthRepository({
    required JsonHttpTransport transport,
    required ApiClient client,
    required SessionCoordinator session,
  }) : _transport = transport,
       _client = client,
       _session = session;

  final JsonHttpTransport _transport;
  final ApiClient _client;
  final SessionCoordinator _session;

  @override
  Future<BackendAuthUser> exchangeFirebaseToken(
    String firebaseIdToken, {
    String? accountPassword,
  }) async {
    final response = await _transport.send(
      method: 'POST',
      path: '/auth/firebase/exchange',
      headers: {'authorization': 'Bearer $firebaseIdToken'},
      body: accountPassword == null
          ? const <String, Object?>{}
          : <String, Object?>{'password': accountPassword},
    );
    final json = _map(response);
    final tokens = SessionTokens.fromJson(json);
    await _session.save(tokens);
    return _decodeUser(json['user']);
  }

  @override
  Future<BackendAuthUser> restore(String firebaseIdToken) async {
    await _session.initialize();
    if (_session.current == null) {
      return exchangeFirebaseToken(firebaseIdToken);
    }
    try {
      return await _client.get('/users/me', decode: _decodeMe);
    } on ApiFailure catch (failure) {
      if (failure.kind != ApiFailureKind.unauthorized) rethrow;
      return exchangeFirebaseToken(firebaseIdToken);
    }
  }

  @override
  Future<BackendAuthUser> completeProfile({
    required String name,
    required String cpf,
    required String phone,
    required AppProfile appProfile,
  }) => _client.patch(
    '/users/me',
    body: {
      'name': name.trim(),
      'cpf': cpf.replaceAll(RegExp(r'\D'), ''),
      'phone': phone.replaceAll(RegExp(r'\D'), ''),
      'app_profile': appProfile.name.toUpperCase(),
    },
    decode: _decodeMe,
  );

  @override
  Future<void> logout() async {
    final refreshToken = _session.current?.refreshToken;
    if (refreshToken != null) {
      await _client.post(
        '/auth/logout',
        authenticated: false,
        body: {'refresh_token': refreshToken},
        decode: (_) {},
      );
    }
    await _session.clear();
  }

  @override
  Future<void> deleteAccount() async {
    await _client.delete('/users/me', decode: (_) {});
    await _session.clear();
  }

  BackendAuthUser _decodeMe(Object? value) {
    final json = _map(value);
    return _decodeUser(json['user']);
  }

  BackendAuthUser _decodeUser(Object? value) {
    final json = _map(value);
    final profile = json['app_profile'];
    return BackendAuthUser(
      id: json['id']! as int,
      email: json['email']! as String,
      name: json['name'] as String?,
      appProfile: profile is String ? AppProfile.fromString(profile) : null,
      profileComplete: json['profile_complete'] == true,
    );
  }

  Map<String, Object?> _map(Object? value) {
    if (value is Map<String, Object?>) return value;
    throw const ApiFailure(
      kind: ApiFailureKind.malformedResponse,
      message: 'O servidor retornou uma sessão inválida.',
      code: 'MALFORMED_AUTH_RESPONSE',
    );
  }
}
