import '../../data/repositories/legal_repository.dart';
import '../../models/legal_document.dart';
import '../http/api_client.dart';

final class HttpLegalRepository implements LegalRepository {
  HttpLegalRepository(this._client);
  final ApiClient _client;

  @override
  Future<LegalCatalog> catalog() => _client.get(
    '/legal/documents',
    decode: LegalCatalog.fromJson,
    authenticated: false,
  );

  @override
  Future<LegalCatalog> pending() =>
      _client.get('/legal/pending', decode: LegalCatalog.fromJson);

  @override
  Future<void> accept(List<int> documentIds) => _client.post(
    '/legal/acceptances',
    body: {'accepted': true, 'channel': 'mobile', 'document_ids': documentIds},
    decode: (_) {},
  );

  @override
  Future<List<LegalAcceptanceRecord>> history() => _client.get(
    '/legal/acceptances',
    decode: (value) => (value as List)
        .map(
          (item) => LegalAcceptanceRecord.fromJson(
            Map<String, dynamic>.from(item as Map),
          ),
        )
        .toList(),
  );

  @override
  Future<LegalDocument> document(int id) => _client.get(
    '/legal/documents/$id',
    authenticated: false,
    decode: (value) =>
        LegalDocument.fromJson(Map<String, dynamic>.from(value as Map)),
  );
}
