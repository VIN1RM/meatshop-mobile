import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product_model.dart';
import '../data/repositories/marketplace_repository.dart';

class ProductPage {
  final List<ProductModel> items;

  final Object? lastDoc;

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
  final MarketplaceRepository? _marketplace;

  ProductService({FirebaseFirestore? db, MarketplaceRepository? marketplace})
    : _db = db ?? FirebaseFirestore.instance,
      _marketplace = marketplace;

  Future<ProductPage> fetchByCategory({
    required String categoryId,
    Object? startAfter,
    String searchQuery = '',
  }) async {
    if (_marketplace != null) {
      final pageNumber = startAfter is int ? startAfter : 1;
      final page = await _marketplace.listProducts(
        categoryId: categoryId,
        page: pageNumber,
        limit: _pageSize,
      );
      var items = page.items;
      if (searchQuery.isNotEmpty) {
        final q = searchQuery.toLowerCase();
        items = items.where((p) => p.name.toLowerCase().contains(q)).toList();
      }
      return ProductPage(
        items: items,
        lastDoc: page.meta.hasNextPage ? pageNumber + 1 : null,
        hasMore: page.meta.hasNextPage,
      );
    }
    Query query = _db
        .collection('products')
        .where('category_id', isEqualTo: categoryId)
        .where('active', isEqualTo: true)
        .orderBy('name')
        .limit(_pageSize);

    if (startAfter != null) {
      query = query.startAfterDocument(startAfter as DocumentSnapshot);
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
    Object? startAfter,
    String searchQuery = '',
  }) async {
    if (categoryIds.isEmpty) {
      return const ProductPage(items: [], lastDoc: null, hasMore: false);
    }
    if (_marketplace != null) {
      final pageNumber = startAfter is int ? startAfter : 1;
      final pages = await Future.wait(
        categoryIds.map(
          (id) => _marketplace.listProducts(
            categoryId: id,
            page: pageNumber,
            limit: _pageSize,
          ),
        ),
      );
      var items = pages.expand((page) => page.items).toList();
      if (searchQuery.isNotEmpty) {
        final q = searchQuery.toLowerCase();
        items = items.where((p) => p.name.toLowerCase().contains(q)).toList();
      }
      final hasMore = pages.any((page) => page.meta.hasNextPage);
      return ProductPage(
        items: items,
        lastDoc: hasMore ? pageNumber + 1 : null,
        hasMore: hasMore,
      );
    }

    Query query = _db
        .collection('products')
        .where('category_id', whereIn: categoryIds)
        .where('active', isEqualTo: true)
        .orderBy('name')
        .limit(_pageSize);

    if (startAfter != null) {
      query = query.startAfterDocument(startAfter as DocumentSnapshot);
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
    Object? startAfter,
  }) async {
    if (_marketplace != null) {
      final pageNumber = startAfter is int ? startAfter : 1;
      final page = await _marketplace.listProducts(
        unitId: unitId,
        page: pageNumber,
        limit: 50,
      );
      return ProductPage(
        items: page.items,
        lastDoc: page.meta.hasNextPage ? pageNumber + 1 : null,
        hasMore: page.meta.hasNextPage,
      );
    }
    Query query = _db
        .collection('products')
        .where('unit_id', isEqualTo: unitId)
        .where('active', isEqualTo: true)
        .orderBy('name')
        .limit(50);

    if (startAfter != null) {
      query = query.startAfterDocument(startAfter as DocumentSnapshot);
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
