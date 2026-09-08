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
  final String unitName;
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
    this.unitName = '',
  });

  String get precoFormatado =>
      'R\$${promotionalPrice.toStringAsFixed(2).replaceAll('.', ',')}';

  String get descontoLabel => '${discountPercentage.toStringAsFixed(0)}% OFF';

  PromotionModel copyWith({
    String? productName,
    String? productImageUrl,
    String? productUnitOfMeasure,
    String? unitName,
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
      unitName: unitName ?? this.unitName,
    );
  }
}
