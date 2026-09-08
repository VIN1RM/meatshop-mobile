import '../../models/recipe_model.dart';

abstract interface class RecipeRepository {
  Future<List<RecipeModel>> listActive();
  Future<RecipeModel> getById(String id);
}
