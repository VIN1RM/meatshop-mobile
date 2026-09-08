class RecipeModel {
  const RecipeModel({
    required this.id,
    required this.unitId,
    required this.title,
    required this.description,
    required this.tag,
    required this.imageUrl,
    required this.videoUrl,
    required this.steps,
    required this.ingredients,
    this.featuredProduct,
    this.displayOrder = 0,
  });

  final String id;
  final String unitId;
  final String title;
  final String description;
  final String tag;
  final String imageUrl;

  final String videoUrl;

  final List<RecipeStepModel> steps;
  final List<RecipeIngredientModel> ingredients;
  final RecipeFeaturedProduct? featuredProduct;
  final int displayOrder;

  factory RecipeModel.fromMap(String id, Map<String, dynamic> map) {
    return RecipeModel(
      id: id,
      unitId: map['unitId'] as String? ?? '',
      title: map['title'] as String? ?? '',
      description: map['description'] as String? ?? '',
      tag: map['tag'] as String? ?? '',
      imageUrl: map['imageUrl'] as String? ?? '',
      videoUrl: map['videoUrl'] as String? ?? '',
      displayOrder: map['displayOrder'] as int? ?? 0,
      steps: (map['steps'] as List<dynamic>? ?? [])
          .map((e) => RecipeStepModel.fromMap(e as Map<String, dynamic>))
          .toList(),
      ingredients: (map['ingredients'] as List<dynamic>? ?? [])
          .map((e) => RecipeIngredientModel.fromMap(e as Map<String, dynamic>))
          .toList(),
      featuredProduct: map['featuredProduct'] != null
          ? RecipeFeaturedProduct.fromMap(
              map['featuredProduct'] as Map<String, dynamic>,
            )
          : null,
    );
  }

  Map<String, dynamic> toMap() => {
    'unitId': unitId,
    'title': title,
    'description': description,
    'tag': tag,
    'imageUrl': imageUrl,
    'videoUrl': videoUrl,
    'displayOrder': displayOrder,
    'steps': steps.map((s) => s.toMap()).toList(),
    'ingredients': ingredients.map((i) => i.toMap()).toList(),
    if (featuredProduct != null) 'featuredProduct': featuredProduct!.toMap(),
  };
}

class RecipeStepModel {
  const RecipeStepModel({
    required this.stepNumber,
    required this.description,
    this.spiceTip,
  });

  final int stepNumber;
  final String description;
  final String? spiceTip;

  factory RecipeStepModel.fromMap(Map<String, dynamic> map) => RecipeStepModel(
    stepNumber: map['stepNumber'] as int? ?? 0,
    description: map['description'] as String? ?? '',
    spiceTip: map['spiceTip'] as String?,
  );

  Map<String, dynamic> toMap() => {
    'stepNumber': stepNumber,
    'description': description,
    if (spiceTip != null) 'spiceTip': spiceTip,
  };
}

class RecipeIngredientModel {
  const RecipeIngredientModel({
    required this.name,
    required this.quantity,
    this.tip,
  });

  final String name;
  final String quantity;

  final String? tip;

  factory RecipeIngredientModel.fromMap(Map<String, dynamic> map) =>
      RecipeIngredientModel(
        name: map['name'] as String? ?? '',
        quantity: map['quantity'] as String? ?? '',
        tip: map['tip'] as String?,
      );

  Map<String, dynamic> toMap() => {
    'name': name,
    'quantity': quantity,
    if (tip != null) 'tip': tip,
  };
}

class RecipeFeaturedProduct {
  const RecipeFeaturedProduct({
    required this.productId,
    required this.productName,
    required this.callToAction,
    this.productImageUrl,
    this.price,
  });

  final String productId;
  final String productName;
  final String callToAction;
  final String? productImageUrl;
  final double? price;

  factory RecipeFeaturedProduct.fromMap(Map<String, dynamic> map) =>
      RecipeFeaturedProduct(
        productId: map['productId'] as String? ?? '',
        productName: map['productName'] as String? ?? '',
        callToAction:
            map['callToAction'] as String? ??
            'Adquira esse corte em nossa loja',
        productImageUrl: map['productImageUrl'] as String?,
        price: (map['price'] as num?)?.toDouble(),
      );

  Map<String, dynamic> toMap() => {
    'productId': productId,
    'productName': productName,
    'callToAction': callToAction,
    if (productImageUrl != null) 'productImageUrl': productImageUrl,
    if (price != null) 'price': price,
  };
}
