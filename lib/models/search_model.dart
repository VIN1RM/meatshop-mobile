import 'package:meatshop_mobile/core/enums/search_type_enum.dart';

class SearchResultModel {
  final String id;
  final String title;
  final String? subtitle;
  final String? imageUrl;
  final SearchResultType type;
  final Object? payload;

  const SearchResultModel({
    required this.id,
    required this.title,
    this.subtitle,
    this.imageUrl,
    required this.type,
    this.payload,
  });
}