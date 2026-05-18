import 'dart:io';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:meatshop_mobile/core/firebase/firestore_collections.dart';

class StorageService {
  StorageService._();
  static final StorageService instance = StorageService._();

  Future<String> uploadImage({required File file, required String path}) async {
    final bytes = await file.readAsBytes();
    final base64Str = base64Encode(bytes);
    final dataUri = 'data:image/jpeg;base64,$base64Str';

    if (path.startsWith('users/')) {
      final uid = path.split('/')[1];
      await FirebaseFirestore.instance
          .collection(FirestoreCollections.users)
          .doc(uid)
          .update({'photo_url': dataUri});
    }

    return dataUri;
  }

  Future<void> deleteImage(String path) async {}
}
