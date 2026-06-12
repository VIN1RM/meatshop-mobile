import 'dart:developer' as dev;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:meatshop_mobile/models/recipe_model.dart';

enum RecipeLoadState { idle, loading, loaded, error }

class RecipeProvider extends ChangeNotifier {
  RecipeProvider();

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  RecipeLoadState _state = RecipeLoadState.idle;
  RecipeLoadState get state => _state;

  List<RecipeModel> _recipes = [];
  List<RecipeModel> get recipes => _recipes;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;
  
  Future<void> loadRecipes(String unitId) async {
    if (_state == RecipeLoadState.loading) return;

    _state = RecipeLoadState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final snapshot = await _db
          .collection('units')
          .doc(unitId)
          .collection('recipes')
          .where('active', isEqualTo: true)
          .orderBy('displayOrder')
          .get();

      _recipes = snapshot.docs
          .map((doc) => RecipeModel.fromMap(doc.id, doc.data()))
          .toList();

      _state = RecipeLoadState.loaded;
    } catch (e, stack) {
      _errorMessage = 'Não foi possível carregar as receitas.';
      _state = RecipeLoadState.error;
      dev.log('RecipeProvider.loadRecipes error', error: e, stackTrace: stack);
    }

    notifyListeners();
  }

  void clear() {
    _recipes = [];
    _state = RecipeLoadState.idle;
    notifyListeners();
  }
}