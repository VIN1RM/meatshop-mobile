import 'api_failure.dart';

final class PageMeta {
  const PageMeta({
    required this.page,
    required this.limit,
    required this.total,
    required this.totalPages,
  });

  factory PageMeta.fromJson(Map<String, Object?> json) => PageMeta(
    page: _requiredInt(json, 'page'),
    limit: _requiredInt(json, 'limit'),
    total: _requiredInt(json, 'total'),
    totalPages: _requiredInt(json, 'total_pages', fallback: 'totalPages'),
  );

  final int page;
  final int limit;
  final int total;
  final int totalPages;

  bool get hasNextPage => page < totalPages;
}

final class Page<T> {
  const Page({required this.items, required this.meta});

  factory Page.fromJson(
    Object? value,
    T Function(Map<String, Object?> json) decodeItem,
  ) {
    if (value is! Map<String, Object?>) {
      throw _malformed('A página não é um objeto JSON.');
    }
    final rawItems = value['data'];
    final rawMeta = value['meta'];
    if (rawItems is! List<Object?> || rawMeta is! Map<String, Object?>) {
      throw _malformed('A página não contém data e meta válidos.');
    }
    return Page<T>(
      items: List.unmodifiable(
        rawItems.map((item) {
          if (item is! Map<String, Object?>) {
            throw _malformed('Um item da página não é um objeto JSON.');
          }
          return decodeItem(item);
        }),
      ),
      meta: PageMeta.fromJson(rawMeta),
    );
  }

  final List<T> items;
  final PageMeta meta;
}

int _requiredInt(Map<String, Object?> json, String key, {String? fallback}) {
  final value = json[key] ?? (fallback == null ? null : json[fallback]);
  if (value is int) return value;
  if (value is num) return value.toInt();
  throw _malformed('O campo $key da paginação é inválido.');
}

ApiFailure _malformed(String message) => ApiFailure(
  kind: ApiFailureKind.malformedResponse,
  message: message,
  code: 'MALFORMED_RESPONSE',
);
