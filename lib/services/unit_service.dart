import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/unit_model.dart';
import '../data/repositories/marketplace_repository.dart';

class UnitService {
  UnitService({MarketplaceRepository? marketplace})
    : _marketplace = marketplace;
  final MarketplaceRepository? _marketplace;
  final CollectionReference _unitsRef = FirebaseFirestore.instance.collection(
    'units',
  );

  Future<UnitModel?> getUnitById(String unitId) async {
    if (_marketplace != null) return _marketplace.getUnit(unitId);
    final doc = await _unitsRef.doc(unitId).get();
    if (!doc.exists) return null;
    return UnitModel.fromMap(doc.id, doc.data() as Map<String, dynamic>);
  }

  Future<List<UnitModel>> getAllUnits({
    double? latitude,
    double? longitude,
    double? radiusKm,
  }) async {
    if (_marketplace != null) {
      return (await _marketplace.listUnits(
        latitude: latitude,
        longitude: longitude,
        radiusKm: radiusKm,
      )).items;
    }
    final snapshot = await _unitsRef
        .orderBy('average_rating', descending: true)
        .get();
    return snapshot.docs
        .map(
          (doc) =>
              UnitModel.fromMap(doc.id, doc.data() as Map<String, dynamic>),
        )
        .toList();
  }
}
