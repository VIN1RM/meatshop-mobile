import '../../core/enums/app_profile.dart';

final class BackendAuthUser {
  const BackendAuthUser({
    required this.id,
    required this.email,
    required this.profileComplete,
    this.name,
    this.appProfile,
  });

  final int id;
  final String email;
  final String? name;
  final AppProfile? appProfile;
  final bool profileComplete;
}

abstract interface class FederatedAuthRepository {
  Future<BackendAuthUser> exchangeFirebaseToken(
    String firebaseIdToken, {
    String? accountPassword,
  });

  Future<BackendAuthUser> restore(String firebaseIdToken);

  Future<BackendAuthUser> completeProfile({
    required String name,
    required String cpf,
    required String phone,
    required AppProfile appProfile,
  });

  Future<void> logout();
}
