import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:meatshop_mobile/models/delivery_person_info_model.dart';

class DeliveryPersonInfoService {
  DeliveryPersonInfoService({FirebaseFirestore? firestore})
    : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  Future<DeliveryPersonInfoModel?> fetchInfo(String deliveryPersonId) async {
    final dpDoc = await _db
        .collection('delivery_persons')
        .doc(deliveryPersonId)
        .get();

    if (!dpDoc.exists) return null;
    final dpData = dpDoc.data()!;
    final userId = dpData['user_id'] as String? ?? '';

    final vehicleSnap = await _db
        .collection('delivery_persons')
        .doc(deliveryPersonId)
        .collection('vehicles')
        .where('is_active', isEqualTo: true)
        .limit(1)
        .get();

    Map<String, dynamic> vehicleData = {};
    if (vehicleSnap.docs.isNotEmpty) {
      vehicleData = vehicleSnap.docs.first.data();
    }

    String name = 'Entregador';
    String photoUrl = '';
    if (userId.isNotEmpty) {
      final userDoc = await _db.collection('users').doc(userId).get();
      final userData = userDoc.data() ?? {};
      name = userData['name'] as String? ?? 'Entregador';
      photoUrl = userData['photo_url'] as String? ?? '';
    }

    final rawUrls = vehicleData['photo_urls'];
    final photoUrls = rawUrls is List
        ? List<String>.from(rawUrls.whereType<String>())
        : <String>[];

    return DeliveryPersonInfoModel(
      deliveryPersonId: deliveryPersonId,
      name: name,
      photoUrl: photoUrl,
      vehicleType: vehicleData['type'] as String? ?? '',
      vehicleModel: vehicleData['model'] as String? ?? '',
      vehiclePlate: vehicleData['plate'] as String? ?? '',
      vehicleColor: vehicleData['color'] as String? ?? '',
      vehiclePhotoUrls: photoUrls,
    );
  }
}
