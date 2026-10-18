final class LegalDocument {
  const LegalDocument({
    required this.id,
    required this.title,
    required this.version,
    required this.content,
  });
  final int id;
  final String title;
  final String version;
  final String content;

  factory LegalDocument.fromJson(Map<String, dynamic> json) => LegalDocument(
    id: (json['id'] as num).toInt(),
    title: json['title'] as String,
    version: json['version'] as String,
    content: json['content'] as String,
  );
}

final class LegalCatalog {
  const LegalCatalog({required this.enforced, required this.documents});
  final bool enforced;
  final List<LegalDocument> documents;

  factory LegalCatalog.fromJson(Object? value) {
    final json = Map<String, dynamic>.from(value as Map);
    return LegalCatalog(
      enforced: json['enforced'] == true,
      documents: (json['documents'] as List)
          .map(
            (item) =>
                LegalDocument.fromJson(Map<String, dynamic>.from(item as Map)),
          )
          .toList(),
    );
  }
}

final class LegalAcceptanceRecord {
  const LegalAcceptanceRecord({
    required this.documentId,
    required this.title,
    required this.version,
    required this.acceptedAt,
  });
  final int documentId;
  final String title;
  final String version;
  final DateTime acceptedAt;

  factory LegalAcceptanceRecord.fromJson(Map<String, dynamic> json) =>
      LegalAcceptanceRecord(
        documentId: (json['document_id'] as num).toInt(),
        title: json['title'] as String,
        version: json['version'] as String,
        acceptedAt: DateTime.parse(json['accepted_at'] as String),
      );
}
