import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:meatshop_mobile/core/firebase/firestore_collections.dart';
import 'package:meatshop_mobile/models/order_model.dart';

class OrderService {
  OrderService({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _db = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _db;
  final FirebaseAuth _auth;

  String get _uid {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw StateError('No authenticated user.');
    return uid;
  }

  CollectionReference<Map<String, dynamic>> get _ordersRef =>
      _db.collection(FirestoreCollections.orders);

  CollectionReference<Map<String, dynamic>> get _unitsRef =>
      _db.collection(FirestoreCollections.units);

  Future<List<OrderItemModel>> _fetchItems(String orderId) async {
    final snap = await _ordersRef
        .doc(orderId)
        .collection(FirestoreCollections.items)
        .get();
    return snap.docs
        .map((d) => OrderItemModel.fromMap(d.data()))
        .toList();
  }

  final Map<String, ({String name, String logoUrl})> _unitCache = {};

  Future<({String name, String logoUrl})> _fetchUnit(String unitId) async {
    if (_unitCache.containsKey(unitId)) return _unitCache[unitId]!;

    final doc = await _unitsRef.doc(unitId).get();
    final data = doc.data() ?? {};
    final record = (
      name: data['name'] as String? ?? '',
      logoUrl: data['logo_url'] as String? ?? '',
    );
    _unitCache[unitId] = record;
    return record;
  }

  Stream<List<OrderModel>> activeOrdersStream() {
    const activeStatuses = [
      'PENDING',
      'CONFIRMED',
      'PREPARING',
      'READY',
      'OUT_FOR_DELIVERY',
    ];

    return _ordersRef
        .where('client_id', isEqualTo: _uid)
        .where('status', whereIn: activeStatuses)
        .orderBy('order_date', descending: true)
        .snapshots()
        .asyncMap((snap) => _enrichOrders(snap.docs));
  }

  Stream<List<OrderModel>> finishedOrdersStream() {
    final threeMonthsAgo = DateTime.now().subtract(const Duration(days: 90));

    return _ordersRef
        .where('client_id', isEqualTo: _uid)
        .where('status', whereIn: ['DELIVERED', 'CANCELLED'])
        .where('order_date',
            isGreaterThanOrEqualTo: Timestamp.fromDate(threeMonthsAgo))
        .orderBy('order_date', descending: true)
        .snapshots()
        .asyncMap((snap) => _enrichOrders(snap.docs));
  }

  Future<List<OrderModel>> _enrichOrders(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
  ) async {
    final futures = docs.map((doc) async {
      final data = doc.data();
      final unitId = data['unit_id'] as String? ?? '';

      final unitInfo =
          unitId.isNotEmpty ? await _fetchUnit(unitId) : (name: '', logoUrl: '');
      final items = await _fetchItems(doc.id);

      return OrderModel.fromDoc(
        doc,
        items: items,
        unitName: unitInfo.name,
        unitLogoUrl: unitInfo.logoUrl,
      );
    });

    return Future.wait(futures);
  }


}