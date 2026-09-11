import 'package:flutter_test/flutter_test.dart';
import 'package:meatshop_mobile/core/network/api_error_localizer.dart';

void main() {
  test('translates known codes to pt-BR', () {
    expect(
      ApiErrorLocalizer.translate(code: 'PROFILE_INCOMPLETE', statusCode: 403),
      'Complete seu cadastro para continuar.',
    );
  });

  test('uses a pt-BR fallback for unknown codes', () {
    expect(
      ApiErrorLocalizer.translate(code: 'NEW_BACKEND_CODE', statusCode: 500),
      'O serviço está indisponível. Tente novamente mais tarde.',
    );
  });
}
