class CartItemModel {
  final String cartItemId;
  final String productId;
  final String productName;
  final String productImageUrl;
  final String unitOfMeasure;
  final double unitPrice;
  final double quantity;
  final String unitId;
  final String unitName;
  final String unitImageUrl;
  final double? availableStock;

  const CartItemModel({
    this.cartItemId = '',
    required this.productId,
    required this.productName,
    required this.productImageUrl,
    required this.unitOfMeasure,
    required this.unitPrice,
    required this.quantity,
    required this.unitId,
    required this.unitName,
    this.unitImageUrl = '',
    this.availableStock,
  });

  double get subtotal => unitPrice * quantity;

  String get precoFormatado =>
      'R\$${unitPrice.toStringAsFixed(2).replaceAll('.', ',')}';

  String get subtotalFormatado =>
      'R\$${subtotal.toStringAsFixed(2).replaceAll('.', ',')}';

  factory CartItemModel.fromMap(Map<String, dynamic> map) {
    final snapshot = map['product_snapshot'] as Map<String, dynamic>? ?? {};
    return CartItemModel(
      cartItemId: map['id']?.toString() ?? '',
      productId: (map['product_id'] as String?) ?? '',
      productName: (snapshot['name'] as String?) ?? '',
      productImageUrl: (snapshot['image_url'] as String?) ?? '',
      unitOfMeasure: (snapshot['unit_of_measure'] as String?) ?? '',
      unitPrice: (map['unit_price'] as num?)?.toDouble() ?? 0.0,
      quantity: (map['quantity'] as num?)?.toDouble() ?? 1.0,
      unitId: (map['unit_id'] as String?) ?? '',
      unitName: (map['unit_name'] as String?) ?? '',
      unitImageUrl: (map['unit_image_url'] as String?) ?? '',
    );
  }

  factory CartItemModel.fromApi(Map<String, Object?> map) {
    double number(String key) {
      final value = map[key];
      if (value is num) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? 0;
      return 0;
    }

    return CartItemModel(
      cartItemId: '${map['id'] ?? ''}',
      productId: '${map['product_id'] ?? ''}',
      productName: map['product_name'] as String? ?? '',
      productImageUrl: map['product_image_url'] as String? ?? '',
      unitOfMeasure: map['unit_of_measure'] as String? ?? '',
      unitPrice: number('unit_price'),
      quantity: number('quantity'),
      unitId: '${map['unit_id'] ?? ''}',
      unitName: map['unit_name'] as String? ?? '',
      unitImageUrl: map['unit_image_url'] as String? ?? '',
      availableStock: number('available_stock'),
    );
  }

  Map<String, dynamic> toMap() => {
    'product_id': productId,
    'unit_id': unitId,
    'unit_name': unitName,
    'unit_image_url': unitImageUrl,
    'unit_price': unitPrice,
    'quantity': quantity,
    'product_snapshot': {
      'name': productName,
      'image_url': productImageUrl,
      'unit_of_measure': unitOfMeasure,
    },
  };

  CartItemModel copyWith({
    double? quantity,
    String? unitName,
    String? unitImageUrl,
    String? productImageUrl,
    double? availableStock,
  }) => CartItemModel(
    cartItemId: cartItemId,
    productId: productId,
    productName: productName,
    productImageUrl: productImageUrl ?? this.productImageUrl,
    unitOfMeasure: unitOfMeasure,
    unitPrice: unitPrice,
    quantity: quantity ?? this.quantity,
    unitId: unitId,
    unitName: unitName ?? this.unitName,
    unitImageUrl: unitImageUrl ?? this.unitImageUrl,
    availableStock: availableStock ?? this.availableStock,
  );
}
