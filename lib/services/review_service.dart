import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:meatshop_mobile/models/review_model.dart';
import '../data/repositories/marketplace_repository.dart';

class ReviewService {
  ReviewService({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
    MarketplaceRepository? marketplace,
  }) : _db = firestore ?? FirebaseFirestore.instance,
       _auth = auth ?? FirebaseAuth.instance,
       _marketplace = marketplace;

  final FirebaseFirestore _db;
  final FirebaseAuth _auth;
  final MarketplaceRepository? _marketplace;

  String get _uid {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw Exception('Usuário não autenticado.');
    return uid;
  }

  Future<bool> hasReviewed(String orderId) async {
    final snap = await _db
        .collection('reviews')
        .where('order_id', isEqualTo: orderId)
        .where('client_id', isEqualTo: _uid)
        .limit(1)
        .get();
    return snap.docs.isNotEmpty;
  }

  Stream<List<ReviewModel>> watchUnitReviews(String unitId, {int? limit}) {
    if (_marketplace != null) {
      return Stream.fromFuture(
        _marketplace
            .listReviews(unitId: unitId, limit: limit ?? 20)
            .then((page) => page.items),
      );
    }
    Query<Map<String, dynamic>> query = _db
        .collection('reviews')
        .where('unit_id', isEqualTo: unitId)
        .orderBy('created_at', descending: true);

    if (limit != null) query = query.limit(limit);

    return query.snapshots().map(
      (s) => s.docs.map(ReviewModel.fromFirestore).toList(),
    );
  }

  Stream<List<ReviewModel>> watchProductReviews(
    String productId, {
    int? limit,
  }) {
    if (_marketplace != null) {
      return Stream.fromFuture(
        _marketplace
            .listReviews(productId: productId, limit: limit ?? 20)
            .then((page) => page.items),
      );
    }
    Query<Map<String, dynamic>> query = _db
        .collection('reviews')
        .where('product_id', isEqualTo: productId)
        .orderBy('created_at', descending: true);

    if (limit != null) query = query.limit(limit);

    return query.snapshots().map(
      (s) => s.docs.map(ReviewModel.fromFirestore).toList(),
    );
  }

  Future<void> submitReviews({
    required String orderId,
    required String unitId,
    required int unitRating,
    required String unitComment,
    String? productId,
    String? deliveryPersonId,
    int? deliveryRating,
    String? deliveryComment,
  }) async {
    final uid = _uid;
    String clientName = 'Cliente';
    try {
      final userDoc = await _db.collection('users').doc(uid).get();
      clientName =
          (userDoc.data()?['name'] as String?)?.trim().isNotEmpty == true
          ? userDoc.data()!['name'] as String
          : 'Cliente';

      final parts = clientName.split(' ');
      clientName = parts.first;
    } catch (_) {}

    final batch = _db.batch();

    final reviewRef = _db.collection('reviews').doc();
    batch.set(reviewRef, {
      'order_id': orderId,
      'client_id': uid,
      'client_name': clientName,
      'unit_id': unitId,
      'product_id': productId,
      'rating': unitRating,
      'comment': unitComment.trim(),
      'created_at': FieldValue.serverTimestamp(),
    });

    if (deliveryPersonId != null &&
        deliveryPersonId.isNotEmpty &&
        deliveryRating != null) {
      final dReviewRef = _db.collection('delivery_reviews').doc();
      batch.set(dReviewRef, {
        'order_id': orderId,
        'client_id': uid,
        'delivery_person_id': deliveryPersonId,
        'rating': deliveryRating,
        'comment': deliveryComment?.trim() ?? '',
        'created_at': FieldValue.serverTimestamp(),
      });
    }

    final orderRef = _db.collection('orders').doc(orderId);
    batch.update(orderRef, {'reviewed': true});

    await batch.commit();

    await Future.wait([
      _recalcUnitRating(unitId),
      if (deliveryPersonId != null && deliveryPersonId.isNotEmpty)
        _recalcDeliveryRating(deliveryPersonId),
    ]);
  }

  Future<void> _recalcUnitRating(String unitId) async {
    final snap = await _db
        .collection('reviews')
        .where('unit_id', isEqualTo: unitId)
        .get();

    if (snap.docs.isEmpty) return;

    final avg =
        snap.docs
            .map((d) => (d['rating'] as num).toDouble())
            .reduce((a, b) => a + b) /
        snap.docs.length;

    await _db.collection('units').doc(unitId).update({
      'average_rating': double.parse(avg.toStringAsFixed(1)),
      'review_count': snap.docs.length,
    });
  }

  Future<void> _recalcDeliveryRating(String deliveryPersonId) async {
    final snap = await _db
        .collection('delivery_reviews')
        .where('delivery_person_id', isEqualTo: deliveryPersonId)
        .get();

    if (snap.docs.isEmpty) return;

    final avg =
        snap.docs
            .map((d) => (d['rating'] as num).toDouble())
            .reduce((a, b) => a + b) /
        snap.docs.length;

    await _db.collection('delivery_persons').doc(deliveryPersonId).update({
      'average_rating': double.parse(avg.toStringAsFixed(1)),
    });
  }
}
