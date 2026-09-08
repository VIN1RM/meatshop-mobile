enum AppEnvironment { development, staging, production }

final class ApiConfig {
  ApiConfig({
    required this.baseUrl,
    required this.environment,
    this.requestTimeout = const Duration(seconds: 20),
  }) {
    _validate();
  }

  factory ApiConfig.fromEnvironment() {
    const rawUrl = String.fromEnvironment('MEATSHOP_API_URL');
    const rawEnvironment = String.fromEnvironment(
      'MEATSHOP_ENV',
      defaultValue: 'development',
    );
    if (rawUrl.trim().isEmpty) {
      throw StateError(
        'MEATSHOP_API_URL não foi definida. Use '
        '--dart-define=MEATSHOP_API_URL=<url-da-api>.',
      );
    }
    return ApiConfig(
      baseUrl: Uri.parse(rawUrl),
      environment: switch (rawEnvironment.toLowerCase()) {
        'development' => AppEnvironment.development,
        'staging' => AppEnvironment.staging,
        'production' => AppEnvironment.production,
        _ => throw StateError('MEATSHOP_ENV inválido: $rawEnvironment.'),
      },
    );
  }

  final Uri baseUrl;
  final AppEnvironment environment;
  final Duration requestTimeout;

  Uri resolve(String path, [Map<String, Object?> query = const {}]) {
    final normalizedBase = baseUrl.toString().replaceFirst(RegExp(r'/$'), '');
    final normalizedPath = path.startsWith('/') ? path : '/$path';
    final queryParameters = <String, String>{
      for (final entry in query.entries)
        if (entry.value != null) entry.key: entry.value.toString(),
    };
    return Uri.parse('$normalizedBase$normalizedPath').replace(
      queryParameters: queryParameters.isEmpty ? null : queryParameters,
    );
  }

  String resolveAsset(String value) {
    if (value.isEmpty) return '';
    final uri = Uri.tryParse(value);
    if (uri?.hasScheme ?? false) return value;
    return resolve(value).toString();
  }

  void _validate() {
    if (!baseUrl.hasScheme || !baseUrl.hasAuthority) {
      throw ArgumentError.value(baseUrl, 'baseUrl', 'URL absoluta inválida.');
    }
    if (environment != AppEnvironment.development &&
        baseUrl.scheme.toLowerCase() != 'https') {
      throw ArgumentError.value(
        baseUrl,
        'baseUrl',
        'HTTPS é obrigatório em homologação e produção.',
      );
    }
    if (requestTimeout <= Duration.zero) {
      throw ArgumentError.value(
        requestTimeout,
        'requestTimeout',
        'O timeout deve ser maior que zero.',
      );
    }
  }
}
