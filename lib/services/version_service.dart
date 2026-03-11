import 'package:package_info_plus/package_info_plus.dart';

class VersionService {
  static final VersionService _instance = VersionService._internal();
  factory VersionService() => _instance;
  VersionService._internal();

  String? _version;

  Future<String> getAppVersion() async {
    if (_version != null) return _version!;
    final info = await PackageInfo.fromPlatform();
    _version = info.version;
    return _version!;
  }
}