import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ReviewService {
  ReviewService({FirebaseFirestore? firestore, FirebaseAuth? auth})
    : _db = firestore ?? FirebaseFirestore.instance,
      _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _db;
  final FirebaseAuth _auth;

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

  Future<void> submitReviews({
    required String orderId,
    required String unitId,
    required int unitRating,
    required String unitComment,
    String? deliveryPersonId,
    int? deliveryRating,
    String? deliveryComment,
  }) async {
    final uid = _uid;
    final batch = _db.batch();

    final reviewRef = _db.collection('reviews').doc();
    batch.set(reviewRef, {
      'order_id': orderId,
      'client_id': uid,
      'unit_id': unitId,
      'product_id': null,
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
