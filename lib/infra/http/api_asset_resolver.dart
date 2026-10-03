import '../../core/config/api_config.dart';

/// Resolves only image fields in API responses, including nested resources.
final class ApiAssetResolver {
  const ApiAssetResolver(this.config);

  final ApiConfig config;

  static const _imageFields = {
    'image_url',
    'cover_url',
    'avatar_url',
    'photo_url',
    'product_image_url',
    'unit_image_url',
    'unit_logo_url',
  };

  Object? resolve(Object? value) {
    if (value is List) {
      return value.map(resolve).toList(growable: false);
    }
    if (value is Map<String, Object?>) {
      return value.map((key, item) {
        if (_imageFields.contains(key) && item is String) {
          return MapEntry(key, config.resolveAsset(item));
        }
        if (key == 'photo_urls' && item is List) {
          return MapEntry(
            key,
            item
                .map(
                  (photo) =>
                      photo is String ? config.resolveAsset(photo) : photo,
                )
                .toList(growable: false),
          );
        }
        return MapEntry(key, resolve(item));
      });
    }
    return value;
  }
}
