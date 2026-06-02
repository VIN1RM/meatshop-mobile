import 'package:cloud_firestore/cloud_firestore.dart';

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

  factory PaymentMethodModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data()!;
    return PaymentMethodModel(
      id: doc.id,
      mpCardId: data['mp_card_id'] as String? ?? '',
      mpCustomerId: data['mp_customer_id'] as String? ?? '',
      brand: data['brand'] as String? ?? 'credit_card',
      lastFour: data['last_four'] as String? ?? '????',
      holderName: data['holder_name'] as String? ?? '',
      expirationMonth: data['expiration_month'] as String? ?? '',
      expirationYear: data['expiration_year'] as String? ?? '',
      isDefault: data['is_default'] as bool? ?? false,
      createdAt: (data['created_at'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() => {
    'mp_card_id': mpCardId,
    'mp_customer_id': mpCustomerId,
    'brand': brand,
    'last_four': lastFour,
    'holder_name': holderName,
    'expiration_month': expirationMonth,
    'expiration_year': expirationYear,
    'is_default': isDefault,
    'created_at': FieldValue.serverTimestamp(),
  };

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
}
