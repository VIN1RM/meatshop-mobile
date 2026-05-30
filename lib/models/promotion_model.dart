import 'package:cloud_firestore/cloud_firestore.dart';

class PromotionModel {
  final String id;
  final String unitId;
  final String productId;
  final String title;
  final String description;
  final double discountPercentage;
  final double promotionalPrice;
  final DateTime startsAt;
  final DateTime endsAt;
  final bool active;

  final String productName;
  final String productImageUrl;
  final String productUnitOfMeasure;

  const PromotionModel({
    required this.id,
    required this.unitId,
    required this.productId,
    required this.title,
    required this.description,
    required this.discountPercentage,
    required this.promotionalPrice,
    required this.startsAt,
    required this.endsAt,
    required this.active,
    this.productName = '',
    this.productImageUrl = '',
    this.productUnitOfMeasure = 'kg',
  });

  String get precoFormatado =>
      'R\$${promotionalPrice.toStringAsFixed(2).replaceAll('.', ',')}';

  String get descontoLabel => '${discountPercentage.toStringAsFixed(0)}% OFF';

  factory PromotionModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return PromotionModel(
      id: doc.id,
      unitId: (data['unit_id'] as String?) ?? '',
      productId: (data['product_id'] as String?) ?? '',
      title: (data['title'] as String?) ?? '',
      description: (data['description'] as String?) ?? '',
      discountPercentage:
          (data['discount_percentage'] as num?)?.toDouble() ?? 0.0,
      promotionalPrice: (data['promotional_price'] as num?)?.toDouble() ?? 0.0,
      startsAt: (data['starts_at'] as Timestamp?)?.toDate() ?? DateTime.now(),
      endsAt: (data['ends_at'] as Timestamp?)?.toDate() ?? DateTime.now(),
      active: (data['active'] as bool?) ?? false,
    );
  }

  PromotionModel copyWith({
    String? productName,
    String? productImageUrl,
    String? productUnitOfMeasure,
  }) {
    return PromotionModel(
      id: id,
      unitId: unitId,
      productId: productId,
      title: title,
      description: description,
      discountPercentage: discountPercentage,
      promotionalPrice: promotionalPrice,
      startsAt: startsAt,
      endsAt: endsAt,
      active: active,
      productName: productName ?? this.productName,
      productImageUrl: productImageUrl ?? this.productImageUrl,
      productUnitOfMeasure: productUnitOfMeasure ?? this.productUnitOfMeasure,
    );
  }
}
