import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:meatshop_mobile/models/payment_model.dart';

class PaymentService {
  PaymentService({FirebaseFirestore? firestore, FirebaseAuth? auth})
    : _db = firestore ?? FirebaseFirestore.instance,
      _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _db;
  final FirebaseAuth _auth;

  String get _uid {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw Exception('Usuário não autenticado.');
    return uid;
  }

  CollectionReference<Map<String, dynamic>> get _col =>
      _db.collection('users').doc(_uid).collection('saved_payment_methods');

  Stream<List<PaymentMethodModel>> watchCards() {
    return _col
        .orderBy('created_at')
        .snapshots()
        .map(
          (snap) => snap.docs.map(PaymentMethodModel.fromFirestore).toList(),
        );
  }

  Future<List<PaymentMethodModel>> fetchCards() async {
    final snap = await _col.orderBy('created_at').get();
    return snap.docs.map(PaymentMethodModel.fromFirestore).toList();
  }

  Future<void> addCard(PaymentMethodModel card) async {
    if (card.isDefault) {
      await _clearDefaultFlag();
    }
    await _col.add(card.toFirestore());
  }

  Future<void> setDefault(String cardId) async {
    await _clearDefaultFlag();
    await _col.doc(cardId).update({'is_default': true});
  }

  Future<void> removeCard(String cardId) async {
    final doc = await _col.doc(cardId).get();
    final wasDefault = (doc.data()?['is_default'] as bool?) ?? false;

    await _col.doc(cardId).delete();

    if (wasDefault) {
      await _promoteOldestAsDefault();
    }
  }

  Future<void> _clearDefaultFlag() async {
    final snap = await _col.where('is_default', isEqualTo: true).get();
    final batch = _db.batch();
    for (final doc in snap.docs) {
      batch.update(doc.reference, {'is_default': false});
    }
    await batch.commit();
  }

  Future<void> _promoteOldestAsDefault() async {
    final snap = await _col.orderBy('created_at').limit(1).get();
    if (snap.docs.isNotEmpty) {
      await snap.docs.first.reference.update({'is_default': true});
    }
  }
}
