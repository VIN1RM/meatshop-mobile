class CategoryModel {
  final String id;
  final String name;
  final String description;
  final bool active;
  final String unitId;
  final DateTime? createdAt;

  const CategoryModel({
    required this.id,
    required this.name,
    required this.description,
    required this.active,
    required this.unitId,
    this.createdAt,
  });
}
