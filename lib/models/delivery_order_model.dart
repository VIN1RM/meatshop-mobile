import 'package:meatshop_mobile/core/enums/delivery_enums.dart';
import 'package:meatshop_mobile/models/address_model.dart';

class DeliveryOrder {
  final int id;
  final String clientName;
  final AddressModel address;
  final String unitName;
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
    required this.clientName,
    required this.address,
    required this.unitName,
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
}
