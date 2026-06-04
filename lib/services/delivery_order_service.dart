import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:meatshop_mobile/models/address_model.dart';
import 'package:meatshop_mobile/models/delivery_order_model.dart';

class DeliveryOrderService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<DeliveryOrder?> _buildOrder(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) async {
    final data = doc.data();
    if (data == null) return null;

    final clientId = data['client_id'] as String? ?? '';
    final unitId = data['unit_id'] as String? ?? '';
    final addressId = data['address_id'] as String? ?? '';

    try {
      String clientName = 'Cliente';
      if (clientId.isNotEmpty) {
        final clientDoc = await _db.collection('users').doc(clientId).get();
        clientName = clientDoc.data()?['name'] as String? ?? 'Cliente';
      }

      String unitName = 'Açougue';
      double? unitLat;
      double? unitLng;
      AddressModel unitAddress = _emptyAddress();
      if (unitId.isNotEmpty) {
        final unitDoc = await _db.collection('units').doc(unitId).get();
        final unitData = unitDoc.data() ?? {};
        unitName = unitData['name'] as String? ?? 'Açougue';
        unitLat = (unitData['lat'] as num?)?.toDouble();
        unitLng = (unitData['lng'] as num?)?.toDouble();
        final unitAddrData = unitData['address'];
        if (unitAddrData != null) {
          unitAddress = AddressModel.fromMap(
            Map<String, dynamic>.from(unitAddrData as Map),
          );
        }
      }

      AddressModel deliveryAddress = _emptyAddress();
      if (clientId.isNotEmpty && addressId.isNotEmpty) {
        final addrDoc = await _db
            .collection('users')
            .doc(clientId)
            .collection('addresses')
            .doc(addressId)
            .get();
        final addrData = addrDoc.data();
        if (addrData != null) {
          deliveryAddress = AddressModel.fromFirestore(addrDoc.id, addrData);
        }
      }

      final itemsLabel = await _fetchItemsLabel(doc.id);

      return DeliveryOrder(
        id: doc.id.hashCode,
        firestoreId: doc.id,
        clientId: clientId,
        clientName: clientName,
        unitId: unitId,
        unitName: unitName,
        unitLat: unitLat,
        unitLng: unitLng,
        destLat: (data['dest_lat'] as num?)?.toDouble(),
        destLng: (data['dest_lng'] as num?)?.toDouble(),
        items: itemsLabel,
        total: (data['total_amount'] as num?)?.toDouble() ?? 0.0,
        address: deliveryAddress,
        unitAddress: unitAddress,
      );
    } catch (e) {
      debugPrint('Erro ao montar pedido ${doc.id}: $e');
      return null;
    }
  }

  Future<String> _fetchItemsLabel(String orderId) async {
    try {
      final snap = await _db
          .collection('orders')
          .doc(orderId)
          .collection('items')
          .get();

      final parts = snap.docs.map((d) {
        final data = d.data();
        final snapshot =
            data['product_snapshot'] as Map<String, dynamic>? ?? {};
        final name = snapshot['name'] as String? ?? 'Item';
        final qty = (data['quantity'] as num?)?.toStringAsFixed(0) ?? '1';
        return '${qty}x $name';
      });

      return parts.join(', ');
    } catch (_) {
      return '';
    }
  }

  Future<List<DeliveryOrder>> fetchDeliveryHistory(
    String deliveryPersonId,
  ) async {
    final since = DateTime.now().subtract(const Duration(days: 30));

    final snap = await _db
        .collection('orders')
        .where('delivery_person_id', isEqualTo: deliveryPersonId)
        .where('delivery_status', isEqualTo: 'DELIVERED')
        .where('order_date', isGreaterThanOrEqualTo: Timestamp.fromDate(since))
        .orderBy('order_date', descending: true)
        .get();

    final futures = snap.docs.map(_buildOrder);
    final results = await Future.wait(futures);
    return results.whereType<DeliveryOrder>().toList();
  }

  AddressModel _emptyAddress() => const AddressModel(
    id: '',
    label: '',
    street: '',
    number: '',
    complement: '',
    neighborhood: '',
    city: '',
    state: '',
    zipCode: '',
    isDefault: false,
  );

  Stream<List<DeliveryOrder>> watchAvailableOrders(String deliveryPersonUid) {
    debugPrint('🔍 Iniciando watchAvailableOrders...');
    return _db
        .collection('orders')
        .where('delivery_status', isEqualTo: 'WAITING_DELIVERY_PERSON')
        .where('delivery_type', isEqualTo: 'DELIVERY')
        .where(
          'status',
          whereIn: ['PENDING', 'CONFIRMED', 'PREPARING', 'READY'],
        )
        .where('client_id', isNotEqualTo: deliveryPersonUid)
        .orderBy('order_date', descending: true)
        .snapshots()
        .handleError((e) => debugPrint('ERRO NA QUERY: $e'))
        .asyncMap((snap) async {
          debugPrint('📦 Docs retornados: ${snap.docs.length}');
          for (final doc in snap.docs) {
            debugPrint(
              '  → ${doc.id} | status=${doc.data()['status']} | delivery_status=${doc.data()['delivery_status']}',
            );
          }
          final futures = snap.docs.map(_buildOrder);
          final results = await Future.wait(futures);
          return results.whereType<DeliveryOrder>().toList();
        });
  }

  Future<void> acceptOrder({
    required String firestoreId,
    required String deliveryPersonId,
  }) async {
    await _db.collection('orders').doc(firestoreId).update({
      'delivery_person_id': deliveryPersonId,
      'delivery_status': 'PICKUP',
      'delivery_step': 'PICKUP',
      'status': 'OUT_FOR_DELIVERY',
    });
  }

  Future<void> rejectOrder({
    required String firestoreId,
    required List<String> reasons,
  }) async {
    debugPrint('Pedido $firestoreId recusado. Motivos: ${reasons.join(', ')}');
  }

  Future<void> confirmPickup(String firestoreId) async {
    await _db.collection('orders').doc(firestoreId).update({
      'delivery_step': 'DELIVERING',
      'delivery_status': 'ON_THE_WAY',
    });
  }

  Future<void> confirmDelivery(String firestoreId) async {
    await _db.collection('orders').doc(firestoreId).update({
      'delivery_step': 'DELIVERING',
      'delivery_status': 'DELIVERED',
      'status': 'DELIVERED',
    });
  }

  Future<DeliveryOrder?> fetchActiveOrder(String deliveryPersonId) async {
    final snap = await _db
        .collection('orders')
        .where('delivery_person_id', isEqualTo: deliveryPersonId)
        .where('delivery_status', whereIn: ['PICKUP', 'ON_THE_WAY'])
        .limit(1)
        .get();

    if (snap.docs.isEmpty) return null;
    return _buildOrder(snap.docs.first);
  }
}
