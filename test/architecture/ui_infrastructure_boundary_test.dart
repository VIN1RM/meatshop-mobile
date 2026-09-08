import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

const _forbiddenImports = <String>{
  'package:http/http.dart',
  'package:flutter_secure_storage/flutter_secure_storage.dart',
  '/infra/',
};

void main() {
  test('UI e Providers não conhecem HTTP, armazenamento ou infraestrutura', () {
    final violations = <String>[];
    for (final directoryPath in ['lib/ui', 'lib/providers']) {
      for (final file
          in Directory(directoryPath)
              .listSync(recursive: true)
              .whereType<File>()
              .where((file) => file.path.endsWith('.dart'))) {
        final imports = file.readAsLinesSync().where(
          (line) => line.trimLeft().startsWith('import '),
        );
        for (final import in imports) {
          if (_forbiddenImports.any(import.contains)) {
            violations.add('${file.path}: $import');
          }
        }
      }
    }

    expect(
      violations,
      isEmpty,
      reason:
          'Telas e Providers devem depender de contratos de repositório, não '
          'de detalhes de infraestrutura. Violações: $violations',
    );
  });
}
