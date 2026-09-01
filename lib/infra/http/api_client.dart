import '../../core/auth/session_coordinator.dart';
import '../../core/network/api_failure.dart';
import '../../core/network/cancellation_token.dart';
import 'json_http_transport.dart';

final class ApiClient {
  ApiClient({
    required JsonHttpTransport transport,
    required SessionCoordinator session,
  }) : _transport = transport,
       _session = session;

  final JsonHttpTransport _transport;
  final SessionCoordinator _session;

  Future<T> get<T>(
    String path, {
    required T Function(Object? json) decode,
    Map<String, Object?> query = const {},
    bool authenticated = true,
    CancellationToken? cancellationToken,
  }) => _request(
    method: 'GET',
    path: path,
    decode: decode,
    query: query,
    authenticated: authenticated,
    cancellationToken: cancellationToken,
  );

  Future<T> post<T>(
    String path, {
    required T Function(Object? json) decode,
    Object? body,
    bool authenticated = true,
    CancellationToken? cancellationToken,
  }) => _request(
    method: 'POST',
    path: path,
    decode: decode,
    body: body,
    authenticated: authenticated,
    cancellationToken: cancellationToken,
  );

  Future<T> put<T>(
    String path, {
    required T Function(Object? json) decode,
    Object? body,
    bool authenticated = true,
    CancellationToken? cancellationToken,
  }) => _request(
    method: 'PUT',
    path: path,
    decode: decode,
    body: body,
    authenticated: authenticated,
    cancellationToken: cancellationToken,
  );

  Future<T> patch<T>(
    String path, {
    required T Function(Object? json) decode,
    Object? body,
    bool authenticated = true,
    CancellationToken? cancellationToken,
  }) => _request(
    method: 'PATCH',
    path: path,
    decode: decode,
    body: body,
    authenticated: authenticated,
    cancellationToken: cancellationToken,
  );

  Future<T> delete<T>(
    String path, {
    required T Function(Object? json) decode,
    Object? body,
    bool authenticated = true,
    CancellationToken? cancellationToken,
  }) => _request(
    method: 'DELETE',
    path: path,
    decode: decode,
    body: body,
    authenticated: authenticated,
    cancellationToken: cancellationToken,
  );

  Future<T> _request<T>({
    required String method,
    required String path,
    required T Function(Object? json) decode,
    required bool authenticated,
    Map<String, Object?> query = const {},
    Object? body,
    CancellationToken? cancellationToken,
  }) async {
    await _session.initialize();
    try {
      final response = await _send(
        method: method,
        path: path,
        query: query,
        body: body,
        authenticated: authenticated,
        cancellationToken: cancellationToken,
      );
      return decode(response);
    } on ApiFailure catch (failure) {
      if (!authenticated ||
          failure.kind != ApiFailureKind.unauthorized ||
          _session.current == null) {
        rethrow;
      }
      await _session.refresh();
      final response = await _send(
        method: method,
        path: path,
        query: query,
        body: body,
        authenticated: true,
        cancellationToken: cancellationToken,
      );
      return decode(response);
    }
  }

  Future<Object?> _send({
    required String method,
    required String path,
    required bool authenticated,
    required Map<String, Object?> query,
    Object? body,
    CancellationToken? cancellationToken,
  }) async {
    final accessToken = _session.current?.accessToken;
    if (authenticated && accessToken == null) {
      throw const ApiFailure(
        kind: ApiFailureKind.unauthorized,
        message: 'Entre na sua conta para continuar.',
        code: 'SESSION_REQUIRED',
      );
    }
    return _transport.send(
      method: method,
      path: path,
      query: query,
      body: body,
      headers: {if (authenticated) 'authorization': 'Bearer $accessToken'},
      cancellationToken: cancellationToken,
    );
  }
}
