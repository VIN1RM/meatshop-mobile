import 'package:cloud_firestore/cloud_firestore.dart';

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

  factory CategoryModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return CategoryModel(
      id: doc.id,
      name: (data['name'] as String?) ?? '',
      description: (data['description'] as String?) ?? '',
      active: (data['active'] as bool?) ?? true,
      unitId: (data['unit_id'] as String?) ?? '',
      createdAt: (data['created_at'] as Timestamp?)?.toDate(),
    );
  }
}
