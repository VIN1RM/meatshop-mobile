import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:meatshop_mobile/core/firebase/firestore_collections.dart';

class AuthService {
  AuthService._();
  static final AuthService instance = AuthService._();

  final _auth = FirebaseAuth.instance;
  final _db = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;

  Future<String> login({
    required String email,
    required String password,
  }) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    final doc = await _db
        .collection(FirestoreCollections.users)
        .doc(credential.user!.uid)
        .get();

    return doc.data()?['app_profile'] as String? ?? 'CLIENT';
  }


  Future<String> registerClient({
    required String name,
    required String email,
    required String password,
    required String cpf,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    await _db
        .collection(FirestoreCollections.users)
        .doc(credential.user!.uid)
        .set({
      'name': name.trim(),
      'email': email.trim(),
      'cpf': cpf.trim(),
      'global_role': 'USER',
      'app_profile': 'CLIENT',
      'created_at': FieldValue.serverTimestamp(),
    });

    return 'CLIENT';
  }

  Future<String> registerDelivery({
    required String name,
    required String email,
    required String password,
    required String cpf,
    required String vehicleType,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    final uid = credential.user!.uid;


    await _db.collection(FirestoreCollections.users).doc(uid).set({
      'name': name.trim(),
      'email': email.trim(),
      'cpf': cpf.trim(),
      'global_role': 'USER',
      'app_profile': 'DELIVERY',
      'created_at': FieldValue.serverTimestamp(),
    });


    await _db.collection(FirestoreCollections.deliveryPersons).doc(uid).set({
      'user_id': uid,
      'status': 'PENDING',
      'average_rating': 0.0,
      'created_at': FieldValue.serverTimestamp(),
    });


    await _db
        .collection(FirestoreCollections.deliveryPersons)
        .doc(uid)
        .collection(FirestoreCollections.vehicles)
        .add({
      'type': vehicleType,
      'model': '',
      'plate': '',
      'color': '',
      'year': '',
      'is_active': true,
      'created_at': FieldValue.serverTimestamp(),
    });

    return 'DELIVERY';
  }

  Future<void> logout() async {
    await _auth.signOut();
  }

  Future<void> sendPasswordResetEmail(String email) async {
    await _auth.sendPasswordResetEmail(email: email.trim());
  }
}