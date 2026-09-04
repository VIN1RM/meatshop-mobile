import '../../core/network/api_failure.dart';
import '../../data/repositories/recipe_repository.dart';
import '../../models/recipe_model.dart';
import '../http/api_client.dart';

final class HttpRecipeRepository implements RecipeRepository {
  HttpRecipeRepository(this._client);
  final ApiClient _client;

  @override
  Future<List<RecipeModel>> listActive() async {
    final summaries = await _client.get<List<Map<String, Object?>>>(
      '/recipes',
      authenticated: false,
      query: const {'active': true},
      decode: (json) {
        if (json is! List) throw _malformed();
        return json.map(_map).toList(growable: false);
      },
    );
    return Future.wait(summaries.map((item) => getById('${item['id']}')));
  }

  @override
  Future<RecipeModel> getById(String id) => _client.get(
    '/recipes/$id',
    authenticated: false,
    decode: (json) => _recipe(_map(json)),
  );

  static RecipeModel _recipe(Map<String, Object?> json) {
    final products = _list(json['products']);
    return RecipeModel(
      id: '${json['id']}',
      unitId: '${json['unit_id']}',
      title: _string(json['title']),
      description: _string(json['description']),
      tag: _string(json['tag']),
      imageUrl: _string(json['image_url']),
      videoUrl: _string(json['video_url']),
      displayOrder: (json['display_order'] as num?)?.toInt() ?? 0,
      steps: _list(json['steps'])
          .map(
            (item) => RecipeStepModel(
              stepNumber: (item['step_number'] as num?)?.toInt() ?? 0,
              description: _string(item['description']),
              spiceTip: _nullable(item['tip']),
            ),
          )
          .toList(growable: false),
      ingredients: _list(json['ingredients'])
          .map(
            (item) => RecipeIngredientModel(
              name: _string(item['name']),
              quantity: _string(item['quantity']),
              tip: _nullable(item['tip']),
            ),
          )
          .toList(growable: false),
      featuredProduct: products.isEmpty
          ? null
          : RecipeFeaturedProduct(
              productId: '${products.first['product_id']}',
              productName: _string(products.first['product_name']),
              callToAction: _string(products.first['call_to_action']),
              productImageUrl: _nullable(products.first['product_image_url']),
              price: (products.first['product_price'] as num?)?.toDouble(),
            ),
    );
  }

  static Map<String, Object?> _map(Object? value) {
    if (value is! Map) throw _malformed();
    return value.map((key, item) => MapEntry(key.toString(), item));
  }

  static List<Map<String, Object?>> _list(Object? value) =>
      value is List ? value.map(_map).toList(growable: false) : const [];
  static String _string(Object? value) => value?.toString() ?? '';
  static String? _nullable(Object? value) => value?.toString();
  static ApiFailure _malformed() => const ApiFailure(
    kind: ApiFailureKind.malformedResponse,
    message: 'Resposta de receitas inválida.',
  );
}
