import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

const _cloudFirestoreImport = "package:cloud_firestore/cloud_firestore.dart";

const _legacyCloudFirestoreFiles = <String>{};

void main() {
  test('não permite novos imports do Cloud Firestore', () {
    final actualFiles = Directory('lib')
        .listSync(recursive: true)
        .whereType<File>()
        .where((file) => file.path.endsWith('.dart'))
        .where(
          (file) => file.readAsStringSync().contains(_cloudFirestoreImport),
        )
        .map((file) => _repositoryRelativePath(file.path))
        .toSet();

    final unexpectedFiles = actualFiles.difference(_legacyCloudFirestoreFiles);
    final staleBaseline = _legacyCloudFirestoreFiles.difference(actualFiles);

    expect(
      unexpectedFiles,
      isEmpty,
      reason:
          'Código novo não pode importar Cloud Firestore. Use um contrato de '
          'repositório e a API NestJS. Imports inesperados: '
          '${(unexpectedFiles.toList()..sort())}',
    );
    expect(
      staleBaseline,
      isEmpty,
      reason:
          'A linha de base deve diminuir junto com a migração. Remova estas '
          'entradas obsoletas: ${(staleBaseline.toList()..sort())}',
    );
  });
}

String _repositoryRelativePath(String path) {
  final normalized = path.replaceAll('\\', '/');
  final libMarker = normalized.lastIndexOf('/lib/');
  if (libMarker >= 0) {
    return normalized.substring(libMarker + 1);
  }
  return normalized.startsWith('lib/') ? normalized : 'lib/$normalized';
}
