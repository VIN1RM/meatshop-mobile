import 'package:meatshop_mobile/data/repositories/delivery_repository.dart';
import 'package:meatshop_mobile/models/delivery_person_info_model.dart';

class DeliveryPersonInfoService {
  DeliveryPersonInfoService(this._repository);

  final DeliveryRepository _repository;

  Future<DeliveryPersonInfoModel?> fetchInfo(String deliveryPersonId) async {
    final data = await _repository.publicProfile(int.parse(deliveryPersonId));
    final vehicleData = data['vehicle'] is Map
        ? Map<String, dynamic>.from(data['vehicle']! as Map)
        : <String, dynamic>{};

    final rawUrls = vehicleData['photo_urls'];
    final photoUrls = rawUrls is List
        ? List<String>.from(rawUrls.whereType<String>())
        : <String>[];

    return DeliveryPersonInfoModel(
      deliveryPersonId: deliveryPersonId,
      name: data['name'] as String? ?? 'Entregador',
      photoUrl: data['photo_url'] as String? ?? '',
      vehicleType: vehicleData['type'] as String? ?? '',
      vehicleModel: vehicleData['model'] as String? ?? '',
      vehiclePlate: vehicleData['plate'] as String? ?? '',
      vehicleColor: vehicleData['color'] as String? ?? '',
      vehiclePhotoUrls: photoUrls,
    );
  }
}
