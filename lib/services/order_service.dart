import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:meatshop_mobile/models/active_order_model.dart';
import 'package:meatshop_mobile/models/cart_item_model.dart';
import 'package:meatshop_mobile/models/checkout_summary_model.dart';
import 'package:meatshop_mobile/models/order_model.dart';

class OrderService {
  OrderService({FirebaseFirestore? firestore, FirebaseAuth? auth})
    : _db = firestore ?? FirebaseFirestore.instance,
      _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _db;
  final FirebaseAuth _auth;

  String get _uid {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw Exception('Usuário não autenticado.');
    return uid;
  }

  Future<List<OrderItemModel>> _fetchItems(String orderId) async {
    final snap = await _db
        .collection('orders')
        .doc(orderId)
        .collection('items')
        .get();

    return snap.docs.map((d) {
      final data = d.data();
      final snapshot = data['product_snapshot'] as Map<String, dynamic>? ?? {};
      return OrderItemModel(
        productName: snapshot['name'] as String? ?? '',
        unitOfMeasure: snapshot['unit_of_measure'] as String? ?? 'un',
        quantity: (data['quantity'] as num?)?.toDouble() ?? 1,
        unitPrice: (data['unit_price'] as num?)?.toDouble() ?? 0,
        productImageUrl: snapshot['image_url'] as String? ?? '',
      );
    }).toList();
  }

  Future<OrderModel> _toModelWithItems(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) async {
    final base = OrderModel.fromFirestore(doc);

    final unitDoc = await _db.collection('units').doc(base.unitId).get();
    final unitData = unitDoc.data() ?? {};

    final items = await _fetchItems(doc.id);

    return base.copyWith(
      unitName: unitData['name'] as String? ?? '',
      unitLogoUrl: unitData['logo_url'] as String? ?? '',
      items: items,
    );
  }

  Stream<List<OrderModel>> activeOrdersStream() {
    final uid = _uid;
    return _db
        .collection('orders')
        .where('client_id', isEqualTo: uid)
        .where('status', whereIn: ['PENDING', 'IN_PROGRESS'])
        .orderBy('order_date', descending: true)
        .snapshots()
        .asyncMap((snap) => Future.wait(snap.docs.map(_toModelWithItems)));
  }

  Stream<List<OrderModel>> finishedOrdersStream() {
    final uid = _uid;
    final since = DateTime.now().subtract(const Duration(days: 90));
    return _db
        .collection('orders')
        .where('client_id', isEqualTo: uid)
        .where('status', whereIn: ['DELIVERED', 'CANCELLED'])
        .where('order_date', isGreaterThanOrEqualTo: Timestamp.fromDate(since))
        .orderBy('order_date', descending: true)
        .snapshots()
        .asyncMap((snap) => Future.wait(snap.docs.map(_toModelWithItems)));
  }

  Future<String> createOrder({
    required CheckoutSummaryModel summary,
    required List<CartItemModel> items,
    required double total,
  }) async {
    final uid = _uid;

    final byUnit = <String, List<CartItemModel>>{};
    for (final item in items) {
      byUnit.putIfAbsent(item.unitId, () => []).add(item);
    }

    String firstOrderId = '';

    for (final entry in byUnit.entries) {
      final unitId = entry.key;
      final unitItems = entry.value;
      final subtotal = unitItems.fold<double>(0, (s, i) => s + i.subtotal);

      final order = OrderModel(
        id: '',
        clientId: uid,
        unitId: unitId,
        addressId: summary.addressId,
        status: 'PENDING',
        deliveryStatus: 'WAITING_DELIVERY_PERSON',
        deliveryType: 'DELIVERY',
        paymentStatus: 'PENDING',
        paymentMethod: summary.paymentMethod,
        subtotal: subtotal,
        deliveryFee: 0,
        discountAmount: 0,
        totalAmount: subtotal,
        isScheduled: summary.isScheduled,
        scheduledDeliveryDate: summary.scheduledDate,
        scheduledTime: summary.scheduledTime,
      );

      final orderRef = await _db.collection('orders').add(order.toFirestore());

      if (firstOrderId.isEmpty) firstOrderId = orderRef.id;

      final batch = _db.batch();
      for (final item in unitItems) {
        final itemRef = orderRef.collection('items').doc();
        batch.set(itemRef, {
          'product_id': item.productId,
          'product_ref': null,
          'product_snapshot': {
            'name': item.productName,
            'unit_of_measure': item.unitOfMeasure,
            'image_url': item.productImageUrl,
          },
          'quantity': item.quantity,
          'unit_price': item.unitPrice,
        });
      }

      final histRef = orderRef.collection('status_history').doc();
      batch.set(histRef, {
        'status': 'PENDING',
        'updated_by': uid,
        'updated_by_ref': null,
        'created_at': FieldValue.serverTimestamp(),
      });

      await batch.commit();
    }

    return firstOrderId;
  }

  Stream<List<ActiveOrderModel>> activeOrdersTrackingStream() {
    final uid = _uid;
    return _db
        .collection('orders')
        .where('client_id', isEqualTo: uid)
        .where(
          'status',
          whereIn: [
            'PENDING',
            'CONFIRMED',
            'PREPARING',
            'READY',
            'OUT_FOR_DELIVERY',
          ],
        )
        .orderBy('order_date', descending: true)
        .snapshots()
        .asyncMap((snap) async {
          final futures = snap.docs.map((doc) async {
            final unitId = doc.data()['unit_id'] as String? ?? '';
            final unitDoc = await _db.collection('units').doc(unitId).get();
            final unitData = unitDoc.data() ?? {};
            return ActiveOrderModel.fromFirestore(
              doc,
              unitName: unitData['name'] as String? ?? '',
              unitLogoUrl: unitData['logo_url'] as String? ?? '',
            );
          });
          return Future.wait(futures);
        });
  }

  Future<void> cancelOrder({
    required String orderId,
    required String reason,
  }) async {
    final uid = _uid;
    await _db.collection('orders').doc(orderId).update({
      'status': 'CANCELLED',
      'cancellation_reason': reason,
      'cancelled_at': FieldValue.serverTimestamp(),
      'cancelled_by': 'CLIENT',
    });

    await _db
        .collection('orders')
        .doc(orderId)
        .collection('status_history')
        .add({
          'status': 'CANCELLED',
          'updated_by': uid,
          'updated_by_ref': null,
          'created_at': FieldValue.serverTimestamp(),
        });
  }
}
