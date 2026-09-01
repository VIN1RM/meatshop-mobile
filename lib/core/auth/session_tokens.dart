import '../network/api_failure.dart';

final class SessionTokens {
  const SessionTokens({required this.accessToken, required this.refreshToken});

  factory SessionTokens.fromJson(Object? value) {
    if (value is! Map<String, Object?>) {
      throw const ApiFailure(
        kind: ApiFailureKind.malformedResponse,
        message: 'A resposta de autenticação é inválida.',
        code: 'MALFORMED_SESSION',
      );
    }
    final accessToken = value['access_token'] ?? value['accessToken'];
    final refreshToken = value['refresh_token'] ?? value['refreshToken'];
    if (accessToken is! String ||
        accessToken.isEmpty ||
        refreshToken is! String ||
        refreshToken.isEmpty) {
      throw const ApiFailure(
        kind: ApiFailureKind.malformedResponse,
        message: 'A resposta não contém uma sessão válida.',
        code: 'MALFORMED_SESSION',
      );
    }
    return SessionTokens(accessToken: accessToken, refreshToken: refreshToken);
  }

  final String accessToken;
  final String refreshToken;
}
