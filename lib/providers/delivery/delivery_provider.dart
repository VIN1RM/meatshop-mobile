import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:meatshop_mobile/core/enums/delivery_enums.dart';
import 'package:meatshop_mobile/models/delivery_order_model.dart';
import 'package:meatshop_mobile/routes/app_routes.dart';
import 'package:meatshop_mobile/models/delivery_review.dart';
import 'package:meatshop_mobile/data/repositories/delivery_repository.dart';

class DeliveryProvider extends ChangeNotifier {
  DeliveryProvider({required this.repository});
  final DeliveryRepository repository;

  DeliveryAvailability _availability = DeliveryAvailability.unavailable;
  DeliveryOrder? _activeOrder;
  bool _isLoading = false;
  String? _pickupCode;
  Map<String, String> _vehicleInfo = {};
  String? _deliveryPersonUid;
  int? _deliveryPersonId;
  StreamSubscription<Position>? _locationSubscription;

  final List<DeliveryOrder> _pendingOrders = [];
  final List<DeliveryOrder> _historyOrders = [];
  bool _isLoadingHistory = false;
  String? _historyError;
  String? _lastError;

  double _averageRating = 0.0;
  int _reviewCount = 0;

  Map<String, String> get vehicleInfo => _vehicleInfo;
  bool get isOnline => isAvailable;
  DeliveryAvailability get availability => _availability;
  bool get isAvailable => _availability == DeliveryAvailability.available;
  DeliveryOrder? get activeOrder => _activeOrder;
  bool get hasActiveOrder => _activeOrder != null;
  bool get isLoading => _isLoading;
  String? get pickupCode => _pickupCode;
  List<DeliveryOrder> get pendingOrders => List.unmodifiable(_pendingOrders);
  List<DeliveryOrder> get historyOrders => List.unmodifiable(_historyOrders);
  bool get isLoadingHistory => _isLoadingHistory;
  String? get historyError => _historyError;
  String? get lastError => _lastError;

  String get deliveryPersonName => _vehicleInfo['name'] ?? 'Entregador';
  double get averageRating => _averageRating;
  int get reviewCount => _reviewCount;
  String get vehicle => _vehicleInfo['type'] ?? 'Moto';

  bool _isReloading = false;
  bool get isReloading => _isReloading;

  void startListeningOrders(String uid) {
    _deliveryPersonUid = uid;
    _refreshBackendState();
  }

  void stopListeningOrders() {
    stopLocationSharing();
  }

  Future<void> toggleOnline() => toggleAvailability();

  Future<void> toggleAvailability() async {
    final next = isAvailable
        ? DeliveryAvailability.unavailable
        : DeliveryAvailability.available;
    try {
      _lastError = null;
      await repository.setAvailability(next == DeliveryAvailability.available);
      _availability = next;
    } catch (error) {
      _lastError = 'Não foi possível alterar sua disponibilidade.';
      rethrow;
    } finally {
      notifyListeners();
    }
  }

  Future<void> acceptOrder(DeliveryOrder order) async {
    _isLoading = true;
    notifyListeners();

    try {
      _lastError = null;
      _pickupCode = await repository.accept(order.id);

      _pendingOrders.removeWhere((o) => o.id == order.id);
      order.status = DeliveryOrderStatus.onTheWay;
      order.step = DeliveryStep.pickup;
      _activeOrder = order;
    } catch (e) {
      _lastError = 'Não foi possível aceitar esta entrega.';
      debugPrint('Erro ao aceitar pedido: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> rejectOrder(
    int orderId,
    List<OrderRejectionReason> reasons,
  ) async {
    _isLoading = true;
    notifyListeners();

    try {
      _lastError = null;
      await repository.reject(orderId, reasons.map((r) => r.label).toList());
      _pendingOrders.removeWhere((o) => o.id == orderId);
    } catch (e) {
      _lastError = 'Não foi possível rejeitar esta oferta.';
      debugPrint('Erro ao rejeitar pedido: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> confirmPickup() async {
    if (_activeOrder == null) return;

    _isLoading = true;
    notifyListeners();

    try {
      _lastError = null;
      _activeOrder = await repository.activeOrder();
    } catch (e) {
      _lastError = 'Não foi possível confirmar a retirada.';
      debugPrint('Erro ao confirmar retirada: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> confirmDelivery([String? customerCode]) async {
    if (_activeOrder == null) return;

    _isLoading = true;
    notifyListeners();

    try {
      _lastError = null;
      if (customerCode == null || customerCode.length != 6) {
        throw ArgumentError('Código do cliente obrigatório');
      }
      await repository.finish(_activeOrder!.id, customerCode);
      _activeOrder!.status = DeliveryOrderStatus.delivered;
      _activeOrder = null;
      _pickupCode = null;
      stopLocationSharing();
    } catch (e) {
      _lastError = 'Não foi possível concluir a entrega.';
      debugPrint('Erro ao confirmar entrega: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadVehicle(String uid) async {
    {
      final data = await repository.profile();
      final vehicles = data['vehicles'] as List? ?? const [];
      final active = vehicles.cast<Map>().where(
        (item) => item['is_active'] == true,
      );
      final vehicle = active.isEmpty ? null : active.first;
      _vehicleInfo = {
        'name': '${data['name'] ?? 'Entregador'}',
        'type': '${vehicle?['type'] ?? data['vehicle'] ?? ''}',
        'model': '${vehicle?['model'] ?? ''}',
        'plate': '${vehicle?['plate'] ?? ''}',
        'color': '${vehicle?['color'] ?? ''}',
        'year': '${vehicle?['year'] ?? ''}',
      };
      _averageRating = (data['average_rating'] as num?)?.toDouble() ?? 0;
      _deliveryPersonId = (data['id'] as num?)?.toInt();
      _availability = data['is_online'] == true
          ? DeliveryAvailability.available
          : DeliveryAvailability.unavailable;
      notifyListeners();
    }
  }

  void logout(BuildContext context) {
    stopListeningOrders();
    _availability = DeliveryAvailability.unavailable;
    _activeOrder = null;
    _pickupCode = null;
    _deliveryPersonUid = null;
    _averageRating = 0.0;
    _reviewCount = 0;
    notifyListeners();

    Navigator.of(
      context,
    ).pushNamedAndRemoveUntil(AppRoutes.login, (route) => false);
  }

  void switchToClientMode(BuildContext context) {
    stopListeningOrders();
    _availability = DeliveryAvailability.unavailable;
    _activeOrder = null;
    _pickupCode = null;
    _deliveryPersonUid = null;
    _averageRating = 0.0;
    _reviewCount = 0;
    notifyListeners();

    Navigator.of(context).pushNamedAndRemoveUntil(
      AppRoutes.modeSwitch,
      (route) => false,
      arguments: AppRoutes.shell,
    );
  }

  Future<void> loadHistory() async {
    if (_deliveryPersonUid == null || _deliveryPersonUid!.isEmpty) return;

    _isLoadingHistory = true;
    _historyError = null;
    notifyListeners();

    try {
      final orders = await repository.history();
      _historyOrders
        ..clear()
        ..addAll(orders);
    } catch (e) {
      _historyError = 'Erro ao carregar histórico';
      debugPrint('Erro ao carregar histórico: $e');
    } finally {
      _isLoadingHistory = false;
      notifyListeners();
    }
  }

  Future<bool> reloadOrders() async {
    if (_deliveryPersonUid == null) return false;
    _isReloading = true;
    notifyListeners();

    try {
      await _refreshBackendState();
      _isReloading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isReloading = false;
      notifyListeners();
      return false;
    }
  }

  Future<Map<String, dynamic>> getRatingStats() async {
    if (_deliveryPersonId != null) {
      final reviews = await repository.reviews(_deliveryPersonId!);
      final distribution = {for (var i = 1; i <= 5; i++) i: 0};
      for (final review in reviews) {
        final rating = (review['rating'] as num?)?.toInt() ?? 0;
        if (distribution.containsKey(rating)) {
          distribution[rating] = distribution[rating]! + 1;
        }
      }
      return {
        'rating': _averageRating,
        'count': reviews.length,
        'distribution': distribution,
      };
    }
    return {};
  }

  Future<List<DeliveryReview>> getReviews() async {
    if (_deliveryPersonId != null) {
      final values = await repository.reviews(_deliveryPersonId!);
      return values
          .map(
            (data) => DeliveryReview(
              id: '${data['id'] ?? ''}',
              orderId: '${data['order_id'] ?? ''}',
              clientId: '${data['client_id'] ?? ''}',
              deliveryPersonId: '$_deliveryPersonId',
              rating: (data['rating'] as num?)?.toInt() ?? 0,
              comment: '${data['comment'] ?? ''}',
              createdAt:
                  DateTime.tryParse('${data['created_at'] ?? ''}') ??
                  DateTime.now(),
            ),
          )
          .toList();
    }
    return [];
  }

  Future<bool> startLocationSharing({required bool consent}) async {
    if (!consent || _activeOrder == null) return false;
    if (!await Geolocator.isLocationServiceEnabled()) return false;

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return false;
    }

    await _locationSubscription?.cancel();
    _locationSubscription =
        Geolocator.getPositionStream(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
            distanceFilter: 20,
          ),
        ).listen((position) {
          final order = _activeOrder;
          if (order == null || order.status == DeliveryOrderStatus.delivered) {
            stopLocationSharing();
            return;
          }
          repository
              .sendLocation(
                order.id,
                position.latitude,
                position.longitude,
                accuracy: position.accuracy,
              )
              .catchError((error) {
                _lastError = 'Falha temporária ao enviar localização.';
                debugPrint('Erro ao enviar localização: $error');
              });
        });
    return true;
  }

  void stopLocationSharing() {
    _locationSubscription?.cancel();
    _locationSubscription = null;
  }

  Future<void> _refreshBackendState() async {
    final results = await Future.wait<Object?>([
      repository.availableOrders(),
      repository.activeOrder(),
      repository.profile(),
    ]);
    _pendingOrders
      ..clear()
      ..addAll(results[0] as List<DeliveryOrder>);
    _activeOrder = results[1] as DeliveryOrder?;
    final profile = results[2] as Map<String, Object?>;
    _availability = profile['is_online'] == true
        ? DeliveryAvailability.available
        : DeliveryAvailability.unavailable;
    _averageRating = (profile['average_rating'] as num?)?.toDouble() ?? 0;
    _deliveryPersonId = (profile['id'] as num?)?.toInt();
    notifyListeners();
  }

  @override
  void dispose() {
    stopListeningOrders();
    super.dispose();
  }
}
