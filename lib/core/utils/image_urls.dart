List<String> uniqueImageUrls(Iterable<String> values) => values
    .map((url) => url.trim())
    .where((url) => url.isNotEmpty)
    .toSet()
    .toList();
List<String> readImageUrls(Object? value) => value is List
    ? uniqueImageUrls(
        value.map(
          (item) => item is String
              ? item
              : item is Map
              ? '${item['image_url'] ?? item['url'] ?? ''}'
              : '',
        ),
      )
    : [];
