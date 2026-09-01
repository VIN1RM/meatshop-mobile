import '../../core/auth/session_refresher.dart';
import '../../core/auth/session_tokens.dart';
import '../http/json_http_transport.dart';

final class BackendSessionRefresher implements SessionRefresher {
  BackendSessionRefresher(this._transport);

  final JsonHttpTransport _transport;

  @override
  Future<SessionTokens> refresh(String refreshToken) async {
    final response = await _transport.send(
      method: 'POST',
      path: '/auth/refresh',
      body: {'refresh_token': refreshToken},
    );
    return SessionTokens.fromJson(response);
  }
}
