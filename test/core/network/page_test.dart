import 'package:flutter_test/flutter_test.dart';
import 'package:meatshop_mobile/core/network/api_failure.dart';
import 'package:meatshop_mobile/core/network/page.dart';

void main() {
  test('converte página e encapsula compatibilidade com totalPages', () {
    final page = Page<int>.fromJson({
      'data': [
        {'id': 10},
      ],
      'meta': {'page': 1, 'limit': 20, 'total': 21, 'totalPages': 2},
    }, (json) => json['id']! as int);

    expect(page.items, [10]);
    expect(page.meta.totalPages, 2);
    expect(page.meta.hasNextPage, isTrue);
  });

  test('rejeita resposta de paginação malformada', () {
    expect(
      () => Page<int>.fromJson({'data': []}, (_) => 0),
      throwsA(
        isA<ApiFailure>().having(
          (failure) => failure.kind,
          'kind',
          ApiFailureKind.malformedResponse,
        ),
      ),
    );
  });
}
