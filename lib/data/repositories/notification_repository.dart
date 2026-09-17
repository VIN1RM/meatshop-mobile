import '../../models/notification_model.dart';

abstract interface class NotificationRepository {
  Future<void> registerDeviceToken({
    required String token,
    required String platform,
    String? appVersion,
  });
  Future<void> unregisterDeviceToken(String token);
  Future<List<NotificationModel>> list({int page = 1, int limit = 50});
  Future<void> markAsRead(String notificationId);
  Future<void> markAllAsRead();
}
