import '../../core/enums/search_type_enum.dart';
import '../../core/network/api_failure.dart';
import '../../core/network/page.dart';
import '../../data/repositories/marketplace_repository.dart';
import '../../models/business_hours_model.dart';
import '../../models/category_model.dart';
import '../../models/product_model.dart';
import '../../models/promotion_model.dart';
import '../../models/review_model.dart';
import '../../models/search_model.dart';
import '../../models/unit_model.dart';
import '../http/api_client.dart';

final class HttpMarketplaceRepository implements MarketplaceRepository {
  HttpMarketplaceRepository(this._client);
  final ApiClient _client;

  @override
  Future<Page<UnitModel>> listUnits({
    int page = 1,
    int limit = 50,
    double? latitude,
    double? longitude,
    double? radiusKm,
  }) => _client.get(
    '/units',
    authenticated: false,
    query: {
      'page': page,
      'limit': limit,
      'lat': ?latitude,
      'lng': ?longitude,
      'radius_km': ?radiusKm,
    },
    decode: (json) => Page.fromJson(json, _unit),
  );

  @override
  Future<UnitModel> getUnit(String id) => _client.get(
    '/units/$id',
    authenticated: false,
    decode: (json) => _unit(_map(json)),
  );

  @override
  Future<List<CategoryModel>> listCategories({String? unitId}) => _client.get(
    '/categories',
    authenticated: false,
    query: {'active': true, 'unit_id': ?unitId},
    decode: (json) => _list(json, _category),
  );

  @override
  Future<Page<ProductModel>> listProducts({
    String? unitId,
    String? categoryId,
    int page = 1,
    int limit = 10,
  }) => _client.get(
    '/products',
    authenticated: false,
    query: {
      'available': true,
      'page': page,
      'limit': limit,
      'unit_id': ?unitId,
      'category_id': ?categoryId,
    },
    decode: (json) => Page.fromJson(json, _product),
  );

  @override
  Future<Page<PromotionModel>> listPromotions({
    String? unitId,
    int page = 1,
    int limit = 10,
  }) => _client.get(
    '/promotions',
    authenticated: false,
    query: {
      'marketplace': true,
      'page': page,
      'limit': limit,
      'unit_id': ?unitId,
    },
    decode: (json) => Page.fromJson(json, _promotion),
  );

  @override
  Future<List<BusinessHoursModel>> listBusinessHours(String unitId) =>
      _client.get(
        '/units/$unitId/business-hours',
        authenticated: false,
        decode: (json) =>
            _list(json, (item) => BusinessHoursModel.fromMap(item)),
      );

  @override
  Future<Page<ReviewModel>> listReviews({
    String? unitId,
    String? productId,
    int page = 1,
    int limit = 20,
  }) => _client.get(
    '/reviews',
    authenticated: false,
    query: {
      'marketplace': true,
      'page': page,
      'limit': limit,
      'unit_id': ?unitId,
      'product_id': ?productId,
    },
    decode: (json) => Page.fromJson(json, _review),
  );

  @override
  Future<Page<SearchResultModel>> search(
    String query, {
    String? unitId,
    String? categoryId,
    double? minPrice,
    double? maxPrice,
    int page = 1,
    int limit = 20,
  }) => _client.get(
    '/search',
    authenticated: false,
    query: {
      'q': query,
      'page': page,
      'limit': limit,
      'unit_id': ?unitId,
      'category_id': ?categoryId,
      'min_price': ?minPrice,
      'max_price': ?maxPrice,
    },
    decode: (json) => Page.fromJson(json, _searchResult),
  );

  static UnitModel _unit(Map<String, Object?> json) => UnitModel(
    id: '${json['id']}',
    name: _string(json, 'name'),
    cnpj: '',
    street: _nullableString(json['street']),
    number: _nullableString(json['number']),
    complement: _nullableString(json['complement']),
    neighborhood: _nullableString(json['neighborhood']),
    city: _string(json, 'city'),
    state: _string(json, 'state'),
    zipCode: _string(json, 'zip_code'),
    adminId: '',
    imageUrl: _nullableString(json['image_url']),
    coverUrl: _nullableString(json['cover_url']),
    createdAt: DateTime.fromMillisecondsSinceEpoch(0),
    averageRating: (json['average_rating'] as num?)?.toDouble() ?? 0,
  );
  static CategoryModel _category(Map<String, Object?> json) => CategoryModel(
    id: '${json['id']}',
    name: _string(json, 'name'),
    description: _nullableString(json['description']),
    active: json['active'] == true,
    unitId: '${json['unit_id']}',
  );
  static ProductModel _product(Map<String, Object?> json) => ProductModel(
    id: '${json['id']}',
    name: _string(json, 'name'),
    description: _nullableString(json['description']),
    price: _number(json, 'price'),
    unitOfMeasure: _string(json, 'unit_of_measure'),
    active: json['active'] == true,
    brand: _nullableString(json['brand']),
    imageUrl: _nullableString(json['image_url']),
    unitId: '${json['unit_id']}',
    unitName: _nullableString(json['unit_name']),
    categoryId: '${json['category_id']}',
    stockQuantity: (json['stock_quantity'] as num?)?.toInt() ?? 0,
  );
  static PromotionModel _promotion(Map<String, Object?> json) {
    final product = json['product'] is Map<String, Object?>
        ? json['product'] as Map<String, Object?>
        : const <String, Object?>{};
    final unit = json['unit'] is Map<String, Object?>
        ? json['unit'] as Map<String, Object?>
        : const <String, Object?>{};
    final discount = _nullableNumber(json['discount_percentage']);
    final explicitPrice = _nullableNumber(json['promotional_price']);
    final basePrice = _nullableNumber(product['price']);
    return PromotionModel(
      id: '${json['id']}',
      unitId: '${json['unit_id']}',
      productId: '${json['product_id']}',
      title: _string(json, 'title'),
      description: _nullableString(json['description']),
      discountPercentage: discount,
      promotionalPrice: explicitPrice > 0
          ? explicitPrice
          : basePrice * (1 - discount / 100),
      startsAt: DateTime.parse(_string(json, 'starts_at')),
      endsAt: DateTime.parse(_string(json, 'ends_at')),
      active: json['active'] == true,
      productName: _nullableString(product['name']),
      productImageUrl: _nullableString(product['image_url']),
      productUnitOfMeasure: _nullableString(product['unit_of_measure']).isEmpty
          ? 'kg'
          : _nullableString(product['unit_of_measure']),
      unitName: _nullableString(unit['name']),
    );
  }

  static ReviewModel _review(Map<String, Object?> json) => ReviewModel(
    id: '${json['id']}',
    orderId: '${json['order_id']}',
    clientId: '',
    clientName: _string(json, 'client_name'),
    unitId: '${json['unit_id']}',
    rating: (json['rating'] as num).toInt(),
    comment: _nullableString(json['comment']),
    createdAt: DateTime.parse(_string(json, 'created_at')),
  );
  static SearchResultModel _searchResult(Map<String, Object?> json) {
    final type = _string(json, 'type');
    if (type == 'UNIT') {
      final unit = _unit(_map(json['unit']));
      return SearchResultModel(
        id: unit.id,
        title: unit.name,
        subtitle: unit.city,
        imageUrl: unit.imageUrl.isEmpty ? null : unit.imageUrl,
        type: SearchResultType.butcher,
        payload: unit,
      );
    }
    if (type == 'CATEGORY') {
      final category = _category(_map(json['category']));
      return SearchResultModel(
        id: category.id,
        title: category.name,
        subtitle: 'Categoria',
        type: SearchResultType.category,
        payload: category.id,
      );
    }
    final product = _product(_map(json['product']));
    return SearchResultModel(
      id: product.id,
      title: product.name,
      subtitle: product.unitName.isEmpty ? null : product.unitName,
      imageUrl: product.imageUrl.isEmpty ? null : product.imageUrl,
      type: SearchResultType.product,
      payload: product,
    );
  }

  static List<T> _list<T>(
    Object? value,
    T Function(Map<String, Object?>) decode,
  ) {
    if (value is! List) throw _malformed();
    return value.map((item) => decode(_map(item))).toList(growable: false);
  }

  static Map<String, Object?> _map(Object? value) {
    if (value is Map<String, Object?>) return value;
    throw _malformed();
  }

  static String _string(Map<String, Object?> json, String key) {
    final value = json[key];
    if (value is String) return value;
    throw _malformed();
  }

  static String _nullableString(Object? value) => value is String ? value : '';
  static double _number(Map<String, Object?> json, String key) {
    final value = json[key];
    if (value is num) return value.toDouble();
    if (value is String) return double.parse(value);
    throw _malformed();
  }

  static double _nullableNumber(Object? value) {
    if (value == null) return 0;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0;
    throw _malformed();
  }

  static ApiFailure _malformed() => const ApiFailure(
    kind: ApiFailureKind.malformedResponse,
    message: 'O marketplace retornou dados inválidos.',
    code: 'MALFORMED_MARKETPLACE_RESPONSE',
  );
}
