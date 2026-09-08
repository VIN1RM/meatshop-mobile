import 'package:meatshop_mobile/core/enums/app_profile.dart';
import 'package:meatshop_mobile/models/user_model.dart';

class MissingProfileData {
  final bool missingName;
  final bool missingCpf;
  final bool missingPhone;
  final bool missingVehicle;
  final bool missingAddress;

  const MissingProfileData({
    this.missingName = false,
    this.missingCpf = false,
    this.missingPhone = false,
    this.missingVehicle = false,
    this.missingAddress = false,
  });

  bool get hasPending =>
      missingName ||
      missingCpf ||
      missingPhone ||
      missingVehicle ||
      missingAddress;
}

class PendingProfileChecker {
  PendingProfileChecker._();

  static MissingProfileData check({
    required UserModel? user,
    required AppProfile? profile,
    bool hasVehicle = true,
    bool hasAddress = true,
  }) {
    if (user == null) return const MissingProfileData();

    final needsVehicle =
        profile == AppProfile.delivery || profile == AppProfile.both;
    final needsAddress =
        profile == AppProfile.client || profile == AppProfile.both;

    return MissingProfileData(
      missingName: user.name.trim().isEmpty,
      missingCpf: user.cpf.trim().isEmpty,
      missingPhone: user.phone.trim().isEmpty,
      missingVehicle: needsVehicle && !hasVehicle,
      missingAddress: needsAddress && !hasAddress,
    );
  }
}
