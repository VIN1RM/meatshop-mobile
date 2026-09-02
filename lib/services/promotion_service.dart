import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/promotion_model.dart';
import '../data/repositories/marketplace_repository.dart';

class PromotionService {
  final FirebaseFirestore _db;
  final MarketplaceRepository? _marketplace;

  PromotionService({FirebaseFirestore? db, MarketplaceRepository? marketplace})
    : _db = db ?? FirebaseFirestore.instance,
      _marketplace = marketplace;

  Future<List<PromotionModel>> fetchActivePromotions({int limit = 10}) async {
    if (_marketplace != null) {
      return (await _marketplace.listPromotions(limit: limit)).items;
    }
    final now = Timestamp.now();

    final snap = await _db
        .collection('promotions')
        .where('active', isEqualTo: true)
        .where('ends_at', isGreaterThanOrEqualTo: now)
        .orderBy('ends_at')
        .limit(limit)
        .get();

    final promotions = snap.docs
        .map((doc) => PromotionModel.fromFirestore(doc))
        .toList();

    final enriched = await Future.wait(
      promotions.map((promo) => _enrichWithProduct(promo)),
    );

    return enriched;
  }

  Future<PromotionModel> _enrichWithProduct(PromotionModel promo) async {
    if (promo.productId.isEmpty) return promo;

    try {
      final productDoc = await _db
          .collection('products')
          .doc(promo.productId)
          .get();

      if (!productDoc.exists) return promo;
      final data = productDoc.data() ?? {};
      return promo.copyWith(
        productName: (data['name'] as String?) ?? '',
        productImageUrl: (data['image_url'] as String?) ?? '',
        productUnitOfMeasure: (data['unit_of_measure'] as String?) ?? 'kg',
      );
    } catch (_) {
      return promo;
    }
  }

  Future<List<PromotionModel>> fetchActivePromotionsByUnit({
    required String unitId,
    int limit = 10,
  }) async {
    if (_marketplace != null) {
      return (await _marketplace.listPromotions(
        unitId: unitId,
        limit: limit,
      )).items;
    }
    final now = Timestamp.now();

    final snap = await _db
        .collection('promotions')
        .where('unit_id', isEqualTo: unitId)
        .where('active', isEqualTo: true)
        .where('ends_at', isGreaterThanOrEqualTo: now)
        .orderBy('ends_at')
        .limit(limit)
        .get();

    final promotions = snap.docs
        .map((doc) => PromotionModel.fromFirestore(doc))
        .toList();

    final enriched = await Future.wait(
      promotions.map((promo) => _enrichWithProduct(promo)),
    );

    return enriched;
  }
}
