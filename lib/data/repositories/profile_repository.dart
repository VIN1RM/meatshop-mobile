import 'dart:typed_data';

import '../../models/user_model.dart';

abstract interface class ProfileRepository {
  Future<UserModel> getProfile();

  Future<UserModel> updateProfile({
    required String name,
    required String email,
    required String phone,
  });

  Future<String> uploadAvatar({
    required Uint8List bytes,
    required String fileName,
    required String contentType,
  });

  Future<void> clearAvatar();
}
