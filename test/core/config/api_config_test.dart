import 'package:flutter_test/flutter_test.dart';
import 'package:meatshop_mobile/core/config/api_config.dart';

void main() {
  group('ApiConfig', () {
    test('resolves paths and query parameters', () {
      final config = ApiConfig(
        baseUrl: Uri.parse('http://10.0.2.2:3001/'),
        environment: AppEnvironment.development,
      );

      expect(
        config.resolve('/products', {
          'page': 2,
          'search': 'picanha',
        }).toString(),
        'http://10.0.2.2:3001/products?page=2&search=picanha',
      );
    });

    test('requires HTTPS outside development', () {
      expect(
        () => ApiConfig(
          baseUrl: Uri.parse('http://api.meatshop.dev'),
          environment: AppEnvironment.production,
        ),
        throwsArgumentError,
      );
    });
  });
}
