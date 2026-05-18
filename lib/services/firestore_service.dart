import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  FirestoreService._();
  static final FirestoreService instance = FirestoreService._();

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> collection(String name) {
    return _db.collection(name);
  }

  DocumentReference<Map<String, dynamic>> doc(String path) {
    return _db.doc(path);
  }
}