class PaymentMethodModel {
  final String id;
  final String mpCardId;
  final String mpCustomerId;
  final String brand;
  final String lastFour;
  final String holderName;
  final String expirationMonth;
  final String expirationYear;
  final bool isDefault;
  final DateTime? createdAt;

  const PaymentMethodModel({
    required this.id,
    required this.mpCardId,
    required this.mpCustomerId,
    required this.brand,
    required this.lastFour,
    required this.holderName,
    required this.expirationMonth,
    required this.expirationYear,
    this.isDefault = false,
    this.createdAt,
  });

  PaymentMethodModel copyWith({bool? isDefault}) {
    return PaymentMethodModel(
      id: id,
      mpCardId: mpCardId,
      mpCustomerId: mpCustomerId,
      brand: brand,
      lastFour: lastFour,
      holderName: holderName,
      expirationMonth: expirationMonth,
      expirationYear: expirationYear,
      isDefault: isDefault ?? this.isDefault,
      createdAt: createdAt,
    );
  }

  factory PaymentMethodModel.fromApi(Map<String, Object?> data) {
    return PaymentMethodModel(
      id: '${data['id'] ?? ''}',
      mpCardId: '',
      mpCustomerId: '',
      brand: data['brand'] as String? ?? 'credit_card',
      lastFour: data['last_four'] as String? ?? '????',
      holderName: data['holder_name'] as String? ?? '',
      expirationMonth: data['expiration_month'] as String? ?? '',
      expirationYear: data['expiration_year'] as String? ?? '',
      isDefault: data['is_default'] as bool? ?? false,
      createdAt: data['created_at'] is String
          ? DateTime.tryParse(data['created_at']! as String)
          : null,
    );
  }
}
