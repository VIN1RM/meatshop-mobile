import '../../core/network/api_failure.dart';
import '../../data/repositories/notification_repository.dart';
import '../../models/notification_model.dart';
import '../http/api_client.dart';

final class HttpNotificationRepository implements NotificationRepository {
  HttpNotificationRepository(this._client);
  final ApiClient _client;

  @override
  Future<void> registerDeviceToken({
    required String token,
    required String platform,
    String? appVersion,
  }) => _client.post(
    '/notifications/device-tokens',
    body: {
      'fcm_token': token,
      'platform': platform,
      ...appVersion == null ? const {} : {'app_version': appVersion},
    },
    decode: (_) {},
  );

  @override
  Future<void> unregisterDeviceToken(String token) => _client.delete(
    '/notifications/device-tokens',
    body: {'fcm_token': token},
    decode: (_) {},
  );

  @override
  Future<List<NotificationModel>> list({int page = 1, int limit = 50}) =>
      _client.get(
        '/notifications',
        query: {'page': page, 'limit': limit},
        decode: (value) {
          if (value is! List<Object?>) throw _malformed();
          return value
              .map((item) => NotificationModel.fromApi(_map(item)))
              .toList(growable: false);
        },
      );

  @override
  Future<void> markAsRead(String notificationId) =>
      _client.patch('/notifications/$notificationId/read', decode: (_) {});

  @override
  Future<void> markAllAsRead() =>
      _client.patch('/notifications/read-all', decode: (_) {});

  static Map<String, Object?> _map(Object? value) {
    if (value is Map<String, Object?>) return value;
    throw _malformed();
  }

  static ApiFailure _malformed() => const ApiFailure(
    kind: ApiFailureKind.malformedResponse,
    message: 'O servidor retornou notificações inválidas.',
    code: 'MALFORMED_NOTIFICATIONS',
  );
}
