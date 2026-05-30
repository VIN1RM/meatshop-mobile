import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product_model.dart';

class ProductPage {
  final List<ProductModel> items;

  final DocumentSnapshot? lastDoc;

  final bool hasMore;

  const ProductPage({
    required this.items,
    required this.lastDoc,
    required this.hasMore,
  });
}

class ProductService {
  static const int _pageSize = 10;

  final FirebaseFirestore _db;

  ProductService({FirebaseFirestore? db})
    : _db = db ?? FirebaseFirestore.instance;

  Future<ProductPage> fetchByCategory({
    required String categoryId,
    DocumentSnapshot? startAfter,
    String searchQuery = '',
  }) async {
    Query query = _db
        .collection('products')
        .where('category_id', isEqualTo: categoryId)
        .where('active', isEqualTo: true)
        .orderBy('name')
        .limit(_pageSize);

    if (startAfter != null) {
      query = query.startAfterDocument(startAfter);
    }

    final snapshot = await query.get();
    var items = snapshot.docs
        .map((doc) => ProductModel.fromFirestore(doc))
        .where((p) => p.name.isNotEmpty)
        .toList();

    if (searchQuery.isNotEmpty) {
      final q = searchQuery.toLowerCase();
      items = items.where((p) => p.name.toLowerCase().contains(q)).toList();
    }

    return ProductPage(
      items: items,
      lastDoc: snapshot.docs.isNotEmpty ? snapshot.docs.last : null,
      hasMore: snapshot.docs.length == _pageSize,
    );
  }

  Future<ProductPage> fetchByCategoryIds({
    required List<String> categoryIds,
    DocumentSnapshot? startAfter,
    String searchQuery = '',
  }) async {
    if (categoryIds.isEmpty) {
      return const ProductPage(items: [], lastDoc: null, hasMore: false);
    }

    Query query = _db
        .collection('products')
        .where('category_id', whereIn: categoryIds)
        .where('active', isEqualTo: true)
        .orderBy('name')
        .limit(_pageSize);

    if (startAfter != null) {
      query = query.startAfterDocument(startAfter);
    }

    final snapshot = await query.get();
    var items = snapshot.docs
        .map((doc) => ProductModel.fromFirestore(doc))
        .where((p) => p.name.isNotEmpty)
        .toList();

    if (searchQuery.isNotEmpty) {
      final q = searchQuery.toLowerCase();
      items = items.where((p) => p.name.toLowerCase().contains(q)).toList();
    }

    return ProductPage(
      items: items,
      lastDoc: snapshot.docs.isNotEmpty ? snapshot.docs.last : null,
      hasMore: snapshot.docs.length == _pageSize,
    );
  }

  Future<ProductPage> fetchByUnitId({
    required String unitId,
    DocumentSnapshot? startAfter,
  }) async {
    Query query = _db
        .collection('products')
        .where('unit_id', isEqualTo: unitId)
        .where('active', isEqualTo: true)
        .orderBy('name')
        .limit(50);

    if (startAfter != null) {
      query = query.startAfterDocument(startAfter);
    }

    final snapshot = await query.get();
    final items = snapshot.docs
        .map((doc) => ProductModel.fromFirestore(doc))
        .where((p) => p.name.isNotEmpty && p.stockQuantity > 0)
        .toList();

    return ProductPage(
      items: items,
      lastDoc: snapshot.docs.isNotEmpty ? snapshot.docs.last : null,
      hasMore: false,
    );
  }
}
