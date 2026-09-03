import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:meatshop_mobile/core/enums/delivery_enums.dart';
import 'package:meatshop_mobile/models/delivery_order_model.dart';
import 'package:meatshop_mobile/routes/app_routes.dart';
import 'package:meatshop_mobile/services/delivery_order_service.dart';
import 'package:meatshop_mobile/services/delivery_rating_service.dart';
import 'package:meatshop_mobile/data/repositories/delivery_repository.dart';

class DeliveryProvider extends ChangeNotifier {
  DeliveryProvider({this.repository});
  final DeliveryRepository? repository;
  final DeliveryOrderService _orderService = DeliveryOrderService();
  final DeliveryRatingService _ratingService = DeliveryRatingService.instance;

  DeliveryAvailability _availability = DeliveryAvailability.unavailable;
  DeliveryOrder? _activeOrder;
  bool _isLoading = false;
  String? _pickupCode;
  Map<String, String> _vehicleInfo = {};
  String? _deliveryPersonUid;
  int? _deliveryPersonId;
  StreamSubscription<List<DeliveryOrder>>? _ordersSubscription;
  StreamSubscription<double>? _ratingSubscription;
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
    if (repository != null) {
      _refreshBackendState();
      return;
    }
    _ordersSubscription?.cancel();
    _ordersSubscription = _orderService.watchAvailableOrders(uid).listen((
      orders,
    ) {
      _pendingOrders
        ..clear()
        ..addAll(orders);
      notifyListeners();
    }, onError: (e) => debugPrint('Erro ao ouvir pedidos: $e'));

    _restoreActiveOrder(uid);

    _ratingSubscription?.cancel();
    _ratingSubscription = _ratingService.watchAverageRating(uid).listen((
      rating,
    ) {
      _averageRating = rating;
      notifyListeners();
    });

    _loadRatingStats(uid);
  }

  Future<void> _loadRatingStats(String uid) async {
    final stats = await _ratingService.calculateAverageRating(uid);
    _averageRating = stats['rating'] as double;
    _reviewCount = stats['count'] as int;
    notifyListeners();
  }

  void stopListeningOrders() {
    _ordersSubscription?.cancel();
    _ordersSubscription = null;
    _ratingSubscription?.cancel();
    _ratingSubscription = null;
    stopLocationSharing();
  }

  Future<void> _restoreActiveOrder(String uid) async {
    if (repository != null) {
      _activeOrder = await repository!.activeOrder();
      notifyListeners();
      return;
    }
    final order = await _orderService.fetchActiveOrder(uid);
    if (order != null) {
      _activeOrder = order;
      notifyListeners();
    }
  }

  Future<void> toggleOnline() => toggleAvailability();

  Future<void> toggleAvailability() async {
    final next = isAvailable
        ? DeliveryAvailability.unavailable
        : DeliveryAvailability.available;
    if (repository != null) {
      try {
        _lastError = null;
        await repository!.setAvailability(
          next == DeliveryAvailability.available,
        );
        _availability = next;
      } catch (error) {
        _lastError = 'Não foi possível alterar sua disponibilidade.';
        rethrow;
      } finally {
        notifyListeners();
      }
      return;
    }
    _availability = next;
    notifyListeners();
  }

  Future<void> acceptOrder(DeliveryOrder order) async {
    _isLoading = true;
    notifyListeners();

    try {
      _lastError = null;
      if (repository != null) {
        _pickupCode = await repository!.accept(order.id);
      } else {
        await _orderService.acceptOrder(
          firestoreId: order.firestoreId,
          deliveryPersonId: _deliveryPersonUid ?? '',
        );
      }

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
      final order = _pendingOrders.firstWhere((o) => o.id == orderId);
      if (repository != null) {
        await repository!.reject(orderId, reasons.map((r) => r.label).toList());
      } else {
        await _orderService.rejectOrder(
          firestoreId: order.firestoreId,
          reasons: reasons.map((r) => r.label).toList(),
        );
      }
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
      if (repository != null) {
        _activeOrder = await repository!.activeOrder();
      } else {
        await _orderService.confirmPickup(_activeOrder!.firestoreId);
        _activeOrder!.step = DeliveryStep.delivering;
      }
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
      if (repository != null) {
        if (customerCode == null || customerCode.length != 6) {
          throw ArgumentError('Código do cliente obrigatório');
        }
        await repository!.finish(_activeOrder!.id, customerCode);
      } else {
        await _orderService.confirmDelivery(_activeOrder!.firestoreId);
      }
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
    if (repository != null) {
      final data = await repository!.profile();
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
      return;
    }
    final snap = await FirebaseFirestore.instance
        .collection('delivery_persons')
        .doc(uid)
        .collection('vehicles')
        .where('is_active', isEqualTo: true)
        .limit(1)
        .get();

    if (snap.docs.isNotEmpty) {
      final data = snap.docs.first.data();
      _vehicleInfo = {
        'type': data['type'] ?? '',
        'model': data['model'] ?? '',
        'plate': data['plate'] ?? '',
        'color': data['color'] ?? '',
        'year': data['year'] ?? '',
      };
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
      final orders = repository != null
          ? await repository!.history()
          : await _orderService.fetchDeliveryHistory(_deliveryPersonUid!);
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
      if (repository != null) {
        await _refreshBackendState();
        _isReloading = false;
        notifyListeners();
        return true;
      }
      stopListeningOrders();
      startListeningOrders(_deliveryPersonUid!);
      await Future.delayed(const Duration(milliseconds: 800));
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
    if (repository != null && _deliveryPersonId != null) {
      final reviews = await repository!.reviews(_deliveryPersonId!);
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
    if (_deliveryPersonUid == null) return {};
    return await _ratingService.getDetailedRatingStats(_deliveryPersonUid!);
  }

  Future<List<DeliveryReview>> getReviews() async {
    if (repository != null && _deliveryPersonId != null) {
      final values = await repository!.reviews(_deliveryPersonId!);
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
    if (_deliveryPersonUid == null) return [];
    return await _ratingService.getDeliveryReviews(_deliveryPersonUid!);
  }

  Future<bool> startLocationSharing({required bool consent}) async {
    if (!consent || repository == null || _activeOrder == null) return false;
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
          repository!
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
      repository!.availableOrders(),
      repository!.activeOrder(),
      repository!.profile(),
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
