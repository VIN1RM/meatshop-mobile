import 'package:cloud_firestore/cloud_firestore.dart';
import '../data/repositories/marketplace_repository.dart';

class CategoryService {
  final FirebaseFirestore _db;

  CategoryService({FirebaseFirestore? db, MarketplaceRepository? marketplace})
    : _db = db ?? FirebaseFirestore.instance,
      _marketplace = marketplace;
  final MarketplaceRepository? _marketplace;

  Future<List<String>> fetchCategoryIdsByName(String name) async {
    if (_marketplace != null) {
      final categories = await _marketplace.listCategories();
      return categories
          .where((item) => item.name.toLowerCase() == name.toLowerCase())
          .map((item) => item.id)
          .toList();
    }
    final snap = await _db
        .collectionGroup('categories')
        .where('name', isEqualTo: name)
        .where('active', isEqualTo: true)
        .get();

    return snap.docs.map((doc) => doc.id).toList();
  }
}
