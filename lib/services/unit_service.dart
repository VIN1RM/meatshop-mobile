import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/unit_model.dart';

class UnitService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final CollectionReference _unitsRef =
      FirebaseFirestore.instance.collection('units');
  final CollectionReference _uniqueCnpjsRef =
      FirebaseFirestore.instance.collection('unique_cnpjs');


  Future<String> createUnit(UnitModel unit) async {

    final cnpjDoc = await _uniqueCnpjsRef.doc(unit.cnpj).get();
    if (cnpjDoc.exists) {
      throw Exception('CNPJ já cadastrado: ${unit.cnpj}');
    }

    final docRef = await _unitsRef.add({
      ...unit.toMap(),
      'created_at': FieldValue.serverTimestamp(),
    });

    await _uniqueCnpjsRef.doc(unit.cnpj).set({'unit_id': docRef.id});

    await _seedBusinessHours(docRef.id);

    return docRef.id;
  }

  Future<UnitModel?> getUnitById(String unitId) async {
    final doc = await _unitsRef.doc(unitId).get();
    if (!doc.exists) return null;
    return UnitModel.fromMap(doc.id, doc.data() as Map<String, dynamic>);
  }

  Future<List<UnitModel>> getAllUnits() async {
    final snapshot = await _unitsRef.get();
    return snapshot.docs
        .map((doc) =>
            UnitModel.fromMap(doc.id, doc.data() as Map<String, dynamic>))
        .toList();
  }

  Future<void> _seedBusinessHours(String unitId) async {
    final ref = _unitsRef.doc(unitId);
    final weekdays = {
      'monday': true,
      'tuesday': true,
      'wednesday': true,
      'thursday': true,
      'friday': true,
      'saturday': true,
      'sunday': false,
    };

    final batch = _db.batch();
    weekdays.forEach((day, isOpen) {
      final hourRef = ref.collection('business_hours').doc(day);
      batch.set(hourRef, {
        'weekday': day,
        'opening_time': '08:00',
        'closing_time': '18:00',
        'is_open': isOpen,
      });
    });
    await batch.commit();
  }
}