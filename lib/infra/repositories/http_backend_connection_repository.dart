import '../../core/network/cancellation_token.dart';
import '../../data/repositories/backend_connection_repository.dart';
import '../http/api_client.dart';

final class HttpBackendConnectionRepository
    implements BackendConnectionRepository {
  HttpBackendConnectionRepository(this._client);

  final ApiClient _client;

  @override
  Future<void> checkPublicHealth({CancellationToken? cancellationToken}) {
    return _client.get<void>(
      '/health',
      authenticated: false,
      cancellationToken: cancellationToken,
      decode: (_) {},
    );
  }

  @override
  Future<void> checkAuthenticatedSession({
    CancellationToken? cancellationToken,
  }) {
    return _client.get<void>(
      '/users/me',
      cancellationToken: cancellationToken,
      decode: (_) {},
    );
  }
}
