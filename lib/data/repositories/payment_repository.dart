import '../../models/payment_model.dart';

abstract interface class PaymentRepository {
  Future<List<PaymentMethodModel>> list();
  Future<PaymentMethodModel> saveTokenizedCard(
    String cardToken, {
    required bool isDefault,
  });
  Future<void> setDefault(String id);
  Future<void> remove(String id);
}
