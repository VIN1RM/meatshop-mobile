import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:meatshop_mobile/models/product_review_model.dart';

class ProductReviewService {
  ProductReviewService({FirebaseFirestore? firestore, FirebaseAuth? auth})
    : _db = firestore ?? FirebaseFirestore.instance,
      _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _db;
  final FirebaseAuth _auth;

  String get _uid {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw Exception('Usuário não autenticado.');
    return uid;
  }

  Future<bool> hasReviewedProduct({
    required String orderId,
    required String productId,
  }) async {
    final snap = await _db
        .collection('reviews')
        .where('order_id', isEqualTo: orderId)
        .where('product_id', isEqualTo: productId)
        .where('client_id', isEqualTo: _uid)
        .limit(1)
        .get();
    return snap.docs.isNotEmpty;
  }

  Future<void> submitProductReview({
    required String orderId,
    required String productId,
    required String productName,
    required String productImageUrl,
    required String unitId,
    required int rating,
    required String comment,
  }) async {
    final uid = _uid;

    await _db.collection('reviews').add({
      'order_id': orderId,
      'client_id': uid,
      'unit_id': unitId,
      'product_id': productId,
      'product_name': productName,
      'product_image_url': productImageUrl,
      'rating': rating,
      'comment': comment.trim(),
      'created_at': FieldValue.serverTimestamp(),
    });

    await _recalcProductRating(productId);
  }

  Future<void> submitMultipleProductReviews({
    required List<ProductReviewModel> reviews,
  }) async {
    String clientName = 'Cliente';
    try {
      final userDoc = await _db.collection('users').doc(_uid).get();
      final name = (userDoc.data()?['name'] as String?)?.trim() ?? '';
      if (name.isNotEmpty) clientName = name.split(' ').first;
    } catch (_) {}

    final batch = _db.batch();
    for (final review in reviews) {
      final ref = _db.collection('reviews').doc();
      batch.set(ref, {...review.toFirestore(), 'client_name': clientName});
    }
    final orderRef = _db.collection('orders').doc(reviews.first.orderId);
    batch.update(orderRef, {'products_reviewed': true});
    await batch.commit();

    final productIds = reviews.map((r) => r.productId).toSet();
    await Future.wait(productIds.map((id) => _recalcProductRating(id)));
  }

  Future<List<ProductReviewModel>> getProductReviews(String productId) async {
    final snap = await _db
        .collection('reviews')
        .where('product_id', isEqualTo: productId)
        .orderBy('created_at', descending: true)
        .limit(20)
        .get();

    return snap.docs.map((d) => ProductReviewModel.fromFirestore(d)).toList();
  }

  Stream<List<ProductReviewModel>> watchProductReviews(String productId) {
    return _db
        .collection('reviews')
        .where('product_id', isEqualTo: productId)
        .orderBy('created_at', descending: true)
        .limit(20)
        .snapshots()
        .map(
          (snap) => snap.docs
              .map((d) => ProductReviewModel.fromFirestore(d))
              .toList(),
        );
  }

  Future<void> _recalcProductRating(String productId) async {
    final snap = await _db
        .collection('reviews')
        .where('product_id', isEqualTo: productId)
        .get();

    if (snap.docs.isEmpty) return;

    final ratings = snap.docs
        .map((d) => (d['rating'] as num).toDouble())
        .toList();
    final avg = ratings.reduce((a, b) => a + b) / ratings.length;

    await _db.collection('products').doc(productId).update({
      'average_rating': double.parse(avg.toStringAsFixed(1)),
      'review_count': snap.docs.length,
    });
  }
}
