import '../../models/legal_document.dart';

abstract interface class LegalRepository {
  Future<LegalCatalog> catalog();
  Future<LegalCatalog> pending();
  Future<void> accept(List<int> documentIds);
  Future<List<LegalAcceptanceRecord>> history();
  Future<LegalDocument> document(int id);
}
