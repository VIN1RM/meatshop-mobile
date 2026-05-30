import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/category_model.dart';

class CategoryService {
  final FirebaseFirestore _db;

  CategoryService({FirebaseFirestore? db})
    : _db = db ?? FirebaseFirestore.instance;

  Future<List<String>> fetchCategoryIdsByName(String name) async {
    final snap = await _db
        .collectionGroup('categories')
        .where('name', isEqualTo: name)
        .where('active', isEqualTo: true)
        .get();

    return snap.docs.map((doc) => doc.id).toList();
  }
}
