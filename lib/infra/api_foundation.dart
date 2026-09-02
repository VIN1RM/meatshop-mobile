import '../core/auth/session_coordinator.dart';
import '../core/config/api_config.dart';
import '../data/repositories/backend_connection_repository.dart';
import 'auth/backend_session_refresher.dart';
import 'auth/secure_key_value_store.dart';
import 'auth/secure_session_store.dart';
import 'http/api_client.dart';
import 'http/json_http_transport.dart';
import 'repositories/http_backend_connection_repository.dart';
import '../data/repositories/federated_auth_repository.dart';
import 'repositories/http_federated_auth_repository.dart';

final class ApiFoundation {
  ApiFoundation._({
    required JsonHttpTransport transport,
    required this.session,
    required this.backendConnection,
    required this.federatedAuth,
  }) : _transport = transport;

  factory ApiFoundation.fromEnvironment() {
    final transport = JsonHttpTransport(config: ApiConfig.fromEnvironment());
    final session = SessionCoordinator(
      store: SecureSessionStore(FlutterSecureKeyValueStore()),
      refresher: BackendSessionRefresher(transport),
    );
    final client = ApiClient(transport: transport, session: session);
    return ApiFoundation._(
      transport: transport,
      session: session,
      backendConnection: HttpBackendConnectionRepository(client),
      federatedAuth: HttpFederatedAuthRepository(
        transport: transport,
        client: client,
        session: session,
      ),
    );
  }

  final JsonHttpTransport _transport;
  final SessionCoordinator session;
  final BackendConnectionRepository backendConnection;
  final FederatedAuthRepository federatedAuth;

  Future<void> initialize() => session.initialize();

  void dispose() => _transport.close();
}
