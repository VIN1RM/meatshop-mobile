import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:meatshop_mobile/models/user_model.dart';
import 'package:meatshop_mobile/core/firebase/firestore_collections.dart';

class UserService {
  UserService._();
  static final UserService instance = UserService._();

  final _db = FirebaseFirestore.instance;

  Future<UserModel?> fetchUser(String uid) async {
    final doc = await _db
        .collection(FirestoreCollections.users)
        .doc(uid)
        .get();

    if (!doc.exists || doc.data() == null) return null;
    return UserModel.fromMap(uid, doc.data()!);
  }

  Future<void> updateUser(String uid, {
    required String name,
    required String email,
    required String phone,
  }) async {
    await _db.collection(FirestoreCollections.users).doc(uid).update({
      'name': name.trim(),
      'email': email.trim(),
      'phone': phone.trim(),
    });
  }
}