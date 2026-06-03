import 'package:meatshop_mobile/core/enums/delivery_enums.dart';
import 'package:meatshop_mobile/models/address_model.dart';

class DeliveryOrder {
  final int id;
  final String firestoreId;
  final String clientId;
  final String clientName;
  final String unitId;
  final String unitName;
  final AddressModel address;
  final AddressModel unitAddress;
  final String items;
  final double total;
  final double? destLat;
  final double? destLng;
  final double? unitLat;
  final double? unitLng;
  DeliveryOrderStatus status;
  DeliveryStep step;

  DeliveryOrder({
    required this.id,
    this.firestoreId = '',
    this.clientId = '',
    required this.clientName,
    this.unitId = '',
    required this.unitName,
    required this.address,
    required this.unitAddress,
    required this.items,
    required this.total,
    this.destLat,
    this.destLng,
    this.unitLat,
    this.unitLng,
    this.status = DeliveryOrderStatus.waiting,
    this.step = DeliveryStep.pickup,
  });

  factory DeliveryOrder.fromFirestore(Map<String, dynamic> data, String docId) {
    return DeliveryOrder(
      id: docId.hashCode,
      firestoreId: docId,
      clientId: data['client_id'] as String? ?? '',
      clientName: data['client_name'] as String? ?? '',
      unitId: data['unit_id'] as String? ?? '',
      unitName: data['unit_name'] as String? ?? '',
      unitLat: (data['unit_lat'] as num?)?.toDouble(),
      unitLng: (data['unit_lng'] as num?)?.toDouble(),
      destLat: (data['dest_lat'] as num?)?.toDouble(),
      destLng: (data['dest_lng'] as num?)?.toDouble(),
      items: data['items'] as String? ?? '',
      total: (data['total_amount'] as num?)?.toDouble() ?? 0.0,
      status: DeliveryOrderStatus.waiting,
      unitAddress: AddressModel.fromMap(
        Map<String, dynamic>.from(data['unit_address'] as Map? ?? {}),
      ),
      address: AddressModel.fromMap(
        Map<String, dynamic>.from(data['delivery_address'] as Map? ?? {}),
      ),
    );
  }
}
