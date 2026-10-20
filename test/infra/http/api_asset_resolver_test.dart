import 'package:flutter_test/flutter_test.dart';
import 'package:meatshop_mobile/core/config/api_config.dart';
import 'package:meatshop_mobile/infra/http/api_asset_resolver.dart';

void main() {
  final resolver = ApiAssetResolver(
    ApiConfig(
      baseUrl: Uri.parse('http://10.0.2.2:3001'),
      environment: AppEnvironment.development,
    ),
  );

  test('resolves nested cart, order, recipe, chat and vehicle images', () {
    final result =
        resolver.resolve({
              'unit_logo_url': '/uploads/units/logo.png',
              'items': [
                {
                  'product_image_url': '/uploads/products/product.png',
                  'unit_image_url': '/uploads/units/logo.png',
                },
              ],
              'products': [
                {'product_image_url': 'uploads/products/product.png'},
              ],
              'participant': {'avatar_url': '/uploads/avatars/avatar.png'},
              'photo_urls': ['/uploads/vehicles/photo.png'],
            })
            as Map<String, Object?>;
    expect(
      result['unit_logo_url'],
      'http://10.0.2.2:3001/uploads/units/logo.png',
    );
    final item = (result['items'] as List).single as Map;
    expect(
      item['product_image_url'],
      'http://10.0.2.2:3001/uploads/products/product.png',
    );
    expect(
      item['unit_image_url'],
      'http://10.0.2.2:3001/uploads/units/logo.png',
    );
    expect(
      ((result['products'] as List).single as Map)['product_image_url'],
      'http://10.0.2.2:3001/uploads/products/product.png',
    );
    expect(
      (result['participant'] as Map)['avatar_url'],
      'http://10.0.2.2:3001/uploads/avatars/avatar.png',
    );
    expect(result['photo_urls'], [
      'http://10.0.2.2:3001/uploads/vehicles/photo.png',
    ]);
  });

  test('preserves external URLs, missing images and unrelated text', () {
    final input = {
      'image_url': 'https://cdn.example.com/image.png?version=2',
      'cover_url': '',
      'avatar_url': null,
      'message': '/uploads/this-is-message-text',
      'checkout_url': '/payment',
      'quantity': 2,
    };
    expect(resolver.resolve(input), input);
    expect(resolver.resolve(resolver.resolve(input)), input);
  });
}
