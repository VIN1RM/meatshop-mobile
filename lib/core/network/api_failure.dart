enum ApiFailureKind {
  network,
  timeout,
  cancelled,
  unauthorized,
  forbidden,
  notFound,
  conflict,
  validation,
  rateLimited,
  server,
  malformedResponse,
  unexpected,
}

final class ApiFailure implements Exception {
  const ApiFailure({
    required this.kind,
    required this.message,
    this.statusCode,
    this.code,
    this.details = const [],
    this.requestId,
    this.retryAfter,
  });

  factory ApiFailure.forStatus({
    required int statusCode,
    required String message,
    String? code,
    List<Object?> details = const [],
    String? requestId,
    Duration? retryAfter,
  }) {
    final kind = switch (statusCode) {
      401 => ApiFailureKind.unauthorized,
      403 => ApiFailureKind.forbidden,
      404 => ApiFailureKind.notFound,
      409 => ApiFailureKind.conflict,
      400 || 422 => ApiFailureKind.validation,
      429 => ApiFailureKind.rateLimited,
      >= 500 => ApiFailureKind.server,
      _ => ApiFailureKind.unexpected,
    };
    return ApiFailure(
      kind: kind,
      message: message,
      statusCode: statusCode,
      code: code,
      details: List.unmodifiable(details),
      requestId: requestId,
      retryAfter: retryAfter,
    );
  }

  final ApiFailureKind kind;
  final String message;
  final int? statusCode;
  final String? code;
  final List<Object?> details;
  final String? requestId;
  final Duration? retryAfter;

  @override
  String toString() => 'ApiFailure($kind, $code): $message';
}
