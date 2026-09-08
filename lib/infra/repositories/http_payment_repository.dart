import '../../core/network/api_failure.dart';
import '../../data/repositories/payment_repository.dart';
import '../../models/payment_model.dart';
import '../http/api_client.dart';

final class HttpPaymentRepository implements PaymentRepository {
  HttpPaymentRepository(this._client);
  final ApiClient _client;

  @override
  Future<List<PaymentMethodModel>> list() => _client.get(
    '/saved-payment-methods',
    decode: (value) {
      if (value is! List<Object?>) throw _malformed();
      return value
          .map((item) => PaymentMethodModel.fromApi(_map(item)))
          .toList(growable: false);
    },
  );

  @override
  Future<PaymentMethodModel> saveTokenizedCard(
    String cardToken, {
    required bool isDefault,
  }) => _client.post(
    '/saved-payment-methods',
    body: {'card_token_id': cardToken, 'is_default': isDefault},
    decode: (value) => PaymentMethodModel.fromApi(_map(value)),
  );

  @override
  Future<void> setDefault(String id) =>
      _client.patch('/saved-payment-methods/$id/default', decode: (_) {});

  @override
  Future<void> remove(String id) =>
      _client.delete('/saved-payment-methods/$id', decode: (_) {});

  static Map<String, Object?> _map(Object? value) {
    if (value is Map<String, Object?>) return value;
    throw _malformed();
  }

  static ApiFailure _malformed() => const ApiFailure(
    kind: ApiFailureKind.malformedResponse,
    message: 'O servidor retornou um método de pagamento inválido.',
    code: 'MALFORMED_PAYMENT_METHOD',
  );
}
