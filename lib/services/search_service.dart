import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:meatshop_mobile/core/firebase/firestore_collections.dart';
import 'package:meatshop_mobile/models/unit_model.dart';
import 'package:meatshop_mobile/models/product_model.dart';
import 'package:meatshop_mobile/models/search_model.dart';
import 'package:meatshop_mobile/core/enums/search_type_enum.dart';

class SearchService {
  static final _db = FirebaseFirestore.instance;

  static const _categories = [
    {'id': 'bovinos', 'label': 'Bovino', 'route': '/cortes/bovinos'},
    {'id': 'suinos', 'label': 'Suíno', 'route': '/cortes/suinos'},
    {'id': 'aves', 'label': 'Frango', 'route': '/cortes/aves'},
    {'id': 'peixes', 'label': 'Peixe', 'route': '/cortes/peixes'},
  ];

  Future<List<SearchResultModel>> search(String query) async {
    if (query.trim().isEmpty) return [];
    final q = query.toLowerCase();

    final results = await Future.wait([_searchButchers(q), _searchProducts(q)]);

    final categoryResults = _searchCategories(q);

    return [...results[0], ...categoryResults, ...results[1]];
  }

  List<SearchResultModel> _searchCategories(String q) {
    return _categories
        .where((c) => (c['label']!).toLowerCase().contains(q))
        .map(
          (c) => SearchResultModel(
            id: c['id']!,
            title: c['label']!,
            subtitle: 'Categoria',
            type: SearchResultType.category,
            payload: c['route'],
          ),
        )
        .toList();
  }

  Future<List<SearchResultModel>> _searchButchers(String q) async {
    try {
      final snap = await _db.collection(FirestoreCollections.units).get();
      return snap.docs
          .where((d) => (d['name'] as String).toLowerCase().contains(q))
          .map((d) {
            final unit = UnitModel.fromMap(d.id, d.data());
            return SearchResultModel(
              id: d.id,
              title: unit.name,
              subtitle: unit.city,
              imageUrl: unit.imageUrl.isNotEmpty ? unit.imageUrl : null,
              type: SearchResultType.butcher,
              payload: unit,
            );
          })
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<List<SearchResultModel>> _searchProducts(String q) async {
    try {
      final snap = await _db
          .collection(FirestoreCollections.products)
          .where('active', isEqualTo: true)
          .get();

      final filtered = snap.docs
          .where((d) => (d['name'] as String).toLowerCase().contains(q))
          .toList();

      if (filtered.isEmpty) return [];

      final unitIds = filtered
          .map((d) => (d['unit_id'] as String?) ?? '')
          .where((id) => id.isNotEmpty)
          .toSet();

      final unitNames = <String, String>{};
      await Future.wait(
        unitIds.map((unitId) async {
          final doc = await _db
              .collection(FirestoreCollections.units)
              .doc(unitId)
              .get();
          if (doc.exists) {
            unitNames[unitId] = (doc['name'] as String?) ?? '';
          }
        }),
      );

      return filtered.map((d) {
        final product = ProductModel.fromMap(d.data(), d.id);
        final unitName = unitNames[product.unitId] ?? '';
        return SearchResultModel(
          id: d.id,
          title: product.name,
          subtitle: unitName.isNotEmpty ? unitName : null,
          imageUrl: product.imageUrl.isNotEmpty ? product.imageUrl : null,
          type: SearchResultType.product,
          payload: product.copyWith(unitName: unitName),
        );
      }).toList();
    } catch (_) {
      return [];
    }
  }
}
