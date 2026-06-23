import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/unit_model.dart';

class UnitService {
  final CollectionReference _unitsRef = FirebaseFirestore.instance.collection(
    'units',
  );

  Future<UnitModel?> getUnitById(String unitId) async {
    final doc = await _unitsRef.doc(unitId).get();
    if (!doc.exists) return null;
    return UnitModel.fromMap(doc.id, doc.data() as Map<String, dynamic>);
  }

  Future<List<UnitModel>> getAllUnits() async {
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
