import 'package:cloud_firestore/cloud_firestore.dart';

class ProductModel {
  final String id;
  final String name;
  final String description;
  final double price;
  final String unitOfMeasure;
  final bool active;
  final String brand;
  final String imageUrl;
  final String unitId;
  final String unitName;
  final String categoryId;
  final int stockQuantity;
  final DateTime? createdAt;

  const ProductModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.unitOfMeasure,
    required this.active,
    required this.brand,
    required this.imageUrl,
    required this.unitId,
    required this.unitName,
    required this.categoryId,
    required this.stockQuantity,
    this.createdAt,
  });

  String get precoFormatado =>
      'R\$${price.toStringAsFixed(2).replaceAll('.', ',')}';

  factory ProductModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};

    final stockRaw = data['stock'];
    int qty = 0;
    if (stockRaw is Map) {
      qty = (stockRaw['quantity'] as num?)?.toInt() ?? 0;
    }

    return ProductModel(
      id: doc.id,
      name: (data['name'] as String?) ?? '',
      description: (data['description'] as String?) ?? '',
      price: (data['price'] as num?)?.toDouble() ?? 0.0,
      unitOfMeasure: (data['unit_of_measure'] as String?) ?? '',
      active: (data['active'] as bool?) ?? true,
      brand: (data['brand'] as String?) ?? '',
      imageUrl: (data['image_url'] as String?) ?? '',
      unitId: (data['unit_id'] as String?) ?? '',
      unitName: '',
      categoryId: (data['category_id'] as String?) ?? '',
      stockQuantity: qty,
      createdAt: (data['created_at'] as Timestamp?)?.toDate(),
    );
  }

  ProductModel copyWith({String? unitName}) => ProductModel(
    id: id,
    name: name,
    description: description,
    price: price,
    unitOfMeasure: unitOfMeasure,
    active: active,
    brand: brand,
    imageUrl: imageUrl,
    unitId: unitId,
    unitName: unitName ?? this.unitName,
    categoryId: categoryId,
    stockQuantity: stockQuantity,
    createdAt: createdAt,
  );
}
