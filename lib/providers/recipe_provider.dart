import 'dart:developer' as dev;
import 'package:flutter/material.dart';
import 'package:meatshop_mobile/models/recipe_model.dart';
import '../data/repositories/recipe_repository.dart';

enum RecipeLoadState { idle, loading, loaded, error }

class RecipeProvider extends ChangeNotifier {
  RecipeProvider({required RecipeRepository repository})
    : _repository = repository;
  final RecipeRepository _repository;

  RecipeLoadState _state = RecipeLoadState.idle;
  RecipeLoadState get state => _state;

  List<RecipeModel> _recipes = [];
  List<RecipeModel> get recipes => _recipes;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Future<void> loadAllRecipes() async {
    if (_state == RecipeLoadState.loading) return;
    _state = RecipeLoadState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      _recipes = await _repository.listActive();

      _state = RecipeLoadState.loaded;
    } catch (e, stack) {
      _errorMessage = 'Não foi possível carregar as receitas.';
      _state = RecipeLoadState.error;
      dev.log(
        'RecipeProvider.loadAllRecipes error',
        error: e,
        stackTrace: stack,
      );
    }

    notifyListeners();
  }

  void clear() {
    _recipes = [];
    _state = RecipeLoadState.idle;
    notifyListeners();
  }
}
