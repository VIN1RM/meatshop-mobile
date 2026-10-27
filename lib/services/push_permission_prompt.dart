import 'package:shared_preferences/shared_preferences.dart';

enum PushPermissionStatus { notDetermined, granted, denied }

abstract interface class PushPermissionGateway {
  Future<PushPermissionStatus> permissionStatus();
  Future<PushPermissionStatus> requestPermission();
}

class PushPermissionPrompt {
  PushPermissionPrompt({required PushPermissionGateway gateway})
    : _gateway = gateway;

  static const _offeredKey = 'push_permission_offered';

  final PushPermissionGateway _gateway;

  Future<PushPermissionStatus> status() => _gateway.permissionStatus();

  Future<PushPermissionStatus> request() => _gateway.requestPermission();

  Future<bool> shouldOfferAfterOrder() async {
    final preferences = await SharedPreferences.getInstance();
    if (preferences.getBool(_offeredKey) ?? false) return false;
    return await status() == PushPermissionStatus.notDetermined;
  }

  Future<void> markOffered() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setBool(_offeredKey, true);
  }
}
