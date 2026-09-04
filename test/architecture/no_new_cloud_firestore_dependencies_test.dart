import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

const _cloudFirestoreImport = "package:cloud_firestore/cloud_firestore.dart";

// Linha de base criada na Fase 0 da integração mobile/backend.
//
// Esta lista só pode diminuir. Ao migrar um arquivo, remova o import e a entrada
// correspondente no mesmo commit. Não adicione exceções para código novo.
const _legacyCloudFirestoreFiles = <String>{
  'lib/models/active_order_model.dart',
  'lib/models/category_model.dart',
  'lib/models/chat_model.dart',
  'lib/models/delivery_earnings_model.dart',
  'lib/models/delivery_goal_model.dart',
  'lib/models/login_attempt_model.dart',
  'lib/models/notification_model.dart',
  'lib/models/order_model.dart',
  'lib/models/payment_model.dart',
  'lib/models/product_model.dart',
  'lib/models/product_review_model.dart',
  'lib/models/promotion_model.dart',
  'lib/models/review_model.dart',
  'lib/providers/auth/auth_provider.dart',
  'lib/providers/delivery/delivery_provider.dart',
  'lib/providers/delivery/vehicle_provider.dart',
  'lib/providers/recipe_provider.dart',
  'lib/services/address_service.dart',
  'lib/services/auth_service.dart',
  'lib/services/business_hours_service.dart',
  'lib/services/cart_service.dart',
  'lib/services/category_service.dart',
  'lib/services/chat_service.dart',
  'lib/services/delivery_earnings_service.dart',
  'lib/services/delivery_fee_service.dart',
  'lib/services/delivery_order_service.dart',
  'lib/services/delivery_person_info_service.dart',
  'lib/services/delivery_rating_service.dart',
  'lib/services/firestore_service.dart',
  'lib/services/login_attempts_service.dart',
  'lib/services/notification_service.dart',
  'lib/services/order_service.dart',
  'lib/services/order_status_notification_service.dart',
  'lib/services/payment_service.dart',
  'lib/services/product_review_service.dart',
  'lib/services/product_service.dart',
  'lib/services/promotion_service.dart',
  'lib/services/review_service.dart',
  'lib/services/search_service.dart',
  'lib/services/storage_service.dart',
  'lib/services/unit_service.dart',
  'lib/services/user_service.dart',
  'lib/ui/screens/cart/cart_screen.dart',
  'lib/ui/screens/cart/review_order_screen.dart',
  'lib/ui/screens/recipes/recipe_details_screen.dart',
};

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
