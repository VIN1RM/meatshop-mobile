import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:meatshop_mobile/models/cart_item_model.dart';

class CartService {
  final FirebaseFirestore _db;

  CartService({FirebaseFirestore? db}) : _db = db ?? FirebaseFirestore.instance;

  CollectionReference _itemsRef(String uid) =>
      _db.collection('carts').doc(uid).collection('items');

  Future<List<CartItemModel>> fetchItems(String uid) async {
    final snap = await _itemsRef(uid).get();
    return snap.docs
        .map((d) => CartItemModel.fromMap(d.data() as Map<String, dynamic>))
        .toList();
  }

  Future<String> fetchUnitName(String unitId) async {
    try {
      final doc = await _db.collection('units').doc(unitId).get();
      return (doc.data()?['name'] as String?) ?? '';
    } catch (_) {
      return '';
    }
  }

  Future<void> patchUnitName(
    String uid,
    String productId,
    String unitName,
  ) async {
    try {
      await _itemsRef(uid).doc(productId).update({'unit_name': unitName});
    } catch (_) {}
  }

  Future<void> updateQuantity(
    String uid,
    String productId,
    double quantity,
  ) async {
    await _itemsRef(uid).doc(productId).update({'quantity': quantity});
  }

  Future<void> removeItem(String uid, String productId) async {
    await _itemsRef(uid).doc(productId).delete();
  }

  Future<void> clearCart(String uid) async {
    final snap = await _itemsRef(uid).get();
    final batch = _db.batch();
    for (final doc in snap.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }

  Future<void> addItem(String uid, CartItemModel item) async {
    await _itemsRef(uid).doc(item.productId).set(item.toMap());
  }

  Future<String> fetchProductImageUrl(String productId) async {
    try {
      final doc = await _db.collection('products').doc(productId).get();
      return (doc.data()?['image_url'] as String?) ?? '';
    } catch (_) {
      return '';
    }
  }

  Future<void> patchProductSnapshot(
    String uid,
    String productId,
    String imageUrl,
  ) async {
    try {
      await _itemsRef(
        uid,
      ).doc(productId).update({'product_snapshot.image_url': imageUrl});
    } catch (_) {}
  }
}
