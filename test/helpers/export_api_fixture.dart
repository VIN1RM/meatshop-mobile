import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:meatshop_mobile/core/auth/session_coordinator.dart';
import 'package:meatshop_mobile/core/auth/session_refresher.dart';
import 'package:meatshop_mobile/core/auth/session_store.dart';
import 'package:meatshop_mobile/core/auth/session_tokens.dart';
import 'package:meatshop_mobile/core/config/api_config.dart';
import 'package:meatshop_mobile/infra/http/api_client.dart';
import 'package:meatshop_mobile/infra/http/json_http_transport.dart';

class ExportApiFixture {
  ExportApiFixture(http.Client httpClient) {
    transport = JsonHttpTransport(
      config: ApiConfig(
        baseUrl: Uri.parse('http://localhost:3001'),
        environment: AppEnvironment.development,
      ),
      client: httpClient,
    );
    session = SessionCoordinator(store: _Store(), refresher: refresher);
    client = ApiClient(transport: transport, session: session);
    addTearDown(transport.close);
  }
  late final JsonHttpTransport transport;
  late final ApiClient client;
  late final SessionCoordinator session;
  final refresher = ExportRefresher();
}

class _Store implements SessionStore {
  SessionTokens? tokens = const SessionTokens(
    accessToken: 'e30.eyJzdWIiOjd9.original',
    refreshToken: 'refresh',
  );
  @override
  Future<SessionTokens?> read() async => tokens;
  @override
  Future<void> write(SessionTokens value) async {
    tokens = value;
  }

  @override
  Future<void> clear() async {
    tokens = null;
  }
}

class ExportRefresher implements SessionRefresher {
  int calls = 0;
  @override
  Future<SessionTokens> refresh(String token) async {
    calls++;
    return const SessionTokens(
      accessToken: 'e30.eyJzdWIiOjd9.renewed',
      refreshToken: 'renewed-refresh',
    );
  }
}
