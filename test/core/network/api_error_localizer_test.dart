import 'package:flutter_test/flutter_test.dart';
import 'package:meatshop_mobile/core/network/api_error_localizer.dart';

void main() {
  test('traduz códigos conhecidos para pt-BR', () {
    expect(
      ApiErrorLocalizer.translate(code: 'PROFILE_INCOMPLETE', statusCode: 403),
      'Complete seu cadastro para continuar.',
    );
  });

  test('usa fallback pt-BR para códigos desconhecidos', () {
    expect(
      ApiErrorLocalizer.translate(code: 'NEW_BACKEND_CODE', statusCode: 500),
      'O serviço está indisponível. Tente novamente mais tarde.',
    );
  });
}
