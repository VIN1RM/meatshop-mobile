import 'session_tokens.dart';

abstract interface class SessionRefresher {
  Future<SessionTokens> refresh(String refreshToken);
}
