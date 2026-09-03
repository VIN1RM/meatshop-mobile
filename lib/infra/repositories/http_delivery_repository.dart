import 'dart:typed_data';

import '../../core/network/api_failure.dart';
import '../../data/repositories/delivery_repository.dart';
import '../../models/delivery_earnings_model.dart';
import '../../models/delivery_goal_model.dart';
import '../../models/delivery_order_model.dart';
import '../http/api_client.dart';
import '../../core/config/api_config.dart';

final class HttpDeliveryRepository implements DeliveryRepository {
  HttpDeliveryRepository(this._client, [this._config]);
  final ApiClient _client;
  final ApiConfig? _config;

  @override
  Future<Map<String, Object?>> profile() => _client.get(
    '/delivery/me',
    decode: (value) {
      final data = _map(value);
      final vehicles = data['vehicles'];
      return {
        ...data,
        if (vehicles is List<Object?>)
          'vehicles': vehicles.map((item) => _vehicle(_map(item))).toList(),
      };
    },
  );
  @override
  Future<Map<String, Object?>> register(String vehicle) => _client.post(
    '/delivery/register',
    body: {'vehicle': vehicle},
    decode: _map,
  );
  @override
  Future<void> setAvailability(bool online) => _client.patch(
    '/delivery/me/availability',
    body: {'is_online': online},
    decode: (_) {},
  );
  @override
  Future<List<Map<String, Object?>>> vehicles() => _client.get(
    '/delivery/me/vehicles',
    decode: (value) =>
        _list(value).map((item) => _vehicle(_map(item))).toList(),
  );
  @override
  Future<Map<String, Object?>> createVehicle(Map<String, Object?> data) =>
      _client.post('/delivery/vehicles', body: data, decode: _map);
  @override
  Future<Map<String, Object?>> updateVehicle(
    int id,
    Map<String, Object?> data,
  ) => _client.patch('/delivery/me/vehicles/$id', body: data, decode: _map);
  @override
  Future<void> activateVehicle(int id) =>
      _client.patch('/delivery/vehicles/$id/activate', decode: (_) {});
  @override
  Future<void> deleteVehicle(int id) =>
      _client.delete('/delivery/me/vehicles/$id', decode: (_) {});
  @override
  Future<String> uploadVehiclePhoto(
    int id, {
    required Uint8List bytes,
    required String fileName,
    required String contentType,
  }) => _client.postMultipart(
    '/delivery/me/vehicles/$id/photos',
    bytes: bytes,
    fileName: fileName,
    contentType: contentType,
    decode: (value) {
      final url = _map(value)['url'];
      if (url is! String || url.isEmpty) throw _malformed();
      return _config?.resolveAsset(url) ?? url;
    },
  );
  @override
  Future<void> deleteVehiclePhoto(int id, String fileName) => _client.delete(
    '/delivery/me/vehicles/$id/photos/${Uri.encodeComponent(fileName)}',
    decode: (_) {},
  );
  @override
  Future<List<DeliveryOrder>> availableOrders() =>
      _orders('/delivery/me/orders/available');
  @override
  Future<DeliveryOrder?> activeOrder() => _client.get(
    '/delivery/me/orders/active',
    decode: (value) =>
        value == null ? null : DeliveryOrder.fromApi(_map(value)),
  );
  @override
  Future<List<DeliveryOrder>> history() =>
      _orders('/delivery/me/orders/history');
  @override
  Future<String> accept(int orderId) => _client.post(
    '/delivery/orders/$orderId/accept',
    decode: (value) {
      final code = _map(value)['pickup_code'];
      if (code is! String || !RegExp(r'^\d{6}$').hasMatch(code)) {
        throw _malformed();
      }
      return code;
    },
  );
  @override
  Future<void> reject(int orderId, List<String> reasons) => _client.post(
    '/delivery/orders/$orderId/reject',
    body: {'reasons': reasons},
    decode: (_) {},
  );
  @override
  Future<void> finish(int orderId, String code) => _client.post(
    '/delivery/orders/$orderId/finish',
    body: {'code': code},
    decode: (_) {},
  );
  @override
  Future<void> sendLocation(
    int orderId,
    double latitude,
    double longitude, {
    double? accuracy,
  }) => _client.post(
    '/delivery/orders/$orderId/location',
    body: _locationBody(latitude, longitude, accuracy),
    decode: (_) {},
  );
  @override
  Future<DeliveryTrackingPoint?> latestTracking(int orderId) => _client.get(
    '/delivery/orders/$orderId/tracking',
    decode: (value) {
      final points = _list(value);
      if (points.isEmpty) return null;
      final point = _map(points.first);
      return DeliveryTrackingPoint(
        orderId: (point['order_id'] as num).toInt(),
        latitude: _number(point['latitude']),
        longitude: _number(point['longitude']),
        accuracy: point['accuracy'] == null ? null : _number(point['accuracy']),
        recordedAt: DateTime.parse(point['created_at'] as String),
      );
    },
  );
  @override
  Future<List<DeliveryEarningModel>> earnings() => _client.get(
    '/delivery/me/earnings',
    decode: (value) => _list(
      _map(value)['entries'],
    ).map((item) => DeliveryEarningModel.fromApi(_map(item))).toList(),
  );
  @override
  Future<List<DeliveryGoalModel>> goals() => _client.get(
    '/delivery/me/goals',
    decode: (value) => _list(
      value,
    ).map((item) => DeliveryGoalModel.fromApi(_map(item))).toList(),
  );
  @override
  Future<DeliveryGoalModel> updateGoal(GoalPeriod period, double target) =>
      _client.patch(
        '/delivery/me/goals/${period.name}',
        body: {'target': target},
        decode: (value) => DeliveryGoalModel.fromApi(_map(value)),
      );
  @override
  Future<List<Map<String, Object?>>> reviews(int deliveryPersonId) =>
      _client.get(
        '/delivery-persons/$deliveryPersonId/reviews',
        decode: (value) => _list(value).map(_map).toList(),
      );

  Future<List<DeliveryOrder>> _orders(String path) => _client.get(
    path,
    decode: (value) =>
        _list(value).map((item) => DeliveryOrder.fromApi(_map(item))).toList(),
  );
  static Map<String, Object?> _map(Object? value) =>
      value is Map<String, Object?> ? value : throw _malformed();
  static List<Object?> _list(Object? value) =>
      value is List<Object?> ? value : throw _malformed();
  static double _number(Object? value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.parse(value);
    throw _malformed();
  }

  Map<String, Object?> _vehicle(Map<String, Object?> value) {
    final photos = value['photo_urls'];
    return {
      ...value,
      if (photos is List<Object?>)
        'photo_urls': photos
            .whereType<String>()
            .map((url) => _config?.resolveAsset(url) ?? url)
            .toList(growable: false),
    };
  }

  static Map<String, Object?> _locationBody(
    double latitude,
    double longitude,
    double? accuracy,
  ) {
    final body = <String, Object?>{
      'latitude': latitude,
      'longitude': longitude,
    };
    if (accuracy != null) body['accuracy'] = accuracy;
    return body;
  }

  static ApiFailure _malformed() => ApiFailure(
    kind: ApiFailureKind.malformedResponse,
    message: 'O servidor retornou dados de entrega inválidos.',
    code: 'MALFORMED_DELIVERY_RESPONSE',
  );
}
