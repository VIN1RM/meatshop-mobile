import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:meatshop_mobile/core/enums/chat_enums.dart';
import 'package:meatshop_mobile/core/enums/delivery_enums.dart';
import 'package:meatshop_mobile/core/utils/chat_args.dart';
import 'package:meatshop_mobile/models/delivery_order_model.dart';
import 'package:meatshop_mobile/routes/app_routes.dart';
import 'package:meatshop_mobile/services/delivery_order_service.dart';
import 'package:meatshop_mobile/services/delivery_rating_service.dart';

class DeliveryProvider extends ChangeNotifier {
  final DeliveryOrderService _orderService = DeliveryOrderService();
  final DeliveryRatingService _ratingService = DeliveryRatingService.instance;

  DeliveryAvailability _availability = DeliveryAvailability.unavailable;
  DeliveryOrder? _activeOrder;
  bool _isLoading = false;
  Map<String, String> _vehicleInfo = {};
  String? _deliveryPersonUid;
  StreamSubscription<List<DeliveryOrder>>? _ordersSubscription;
  StreamSubscription<double>? _ratingSubscription;

  final List<DeliveryOrder> _pendingOrders = [];
  final List<DeliveryOrder> _historyOrders = [];
  bool _isLoadingHistory = false;
  String? _historyError;

  double _averageRating = 0.0;
  int _reviewCount = 0;

  Map<String, String> get vehicleInfo => _vehicleInfo;
  bool get isOnline => isAvailable;
  DeliveryAvailability get availability => _availability;
  bool get isAvailable => _availability == DeliveryAvailability.available;
  DeliveryOrder? get activeOrder => _activeOrder;
  bool get hasActiveOrder => _activeOrder != null;
  bool get isLoading => _isLoading;
  List<DeliveryOrder> get pendingOrders => List.unmodifiable(_pendingOrders);
  List<DeliveryOrder> get historyOrders => List.unmodifiable(_historyOrders);
  bool get isLoadingHistory => _isLoadingHistory;
  String? get historyError => _historyError;

  String get deliveryPersonName => _vehicleInfo['name'] ?? 'Entregador';
  double get averageRating => _averageRating;
  int get reviewCount => _reviewCount;
  String get vehicle => _vehicleInfo['type'] ?? 'Moto';

  bool _isReloading = false;
  bool get isReloading => _isReloading;

  void startListeningOrders(String uid) {
    _deliveryPersonUid = uid;
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
  }

  Future<void> _restoreActiveOrder(String uid) async {
    final order = await _orderService.fetchActiveOrder(uid);
    if (order != null) {
      _activeOrder = order;
      notifyListeners();
    }
  }

  void toggleOnline() => toggleAvailability();

  void toggleAvailability() {
    _availability = isAvailable
        ? DeliveryAvailability.unavailable
        : DeliveryAvailability.available;
    notifyListeners();
  }

  Future<void> acceptOrder(DeliveryOrder order) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _orderService.acceptOrder(
        firestoreId: order.firestoreId,
        deliveryPersonId: _deliveryPersonUid ?? '',
      );

      _pendingOrders.removeWhere((o) => o.firestoreId == order.firestoreId);
      order.status = DeliveryOrderStatus.onTheWay;
      order.step = DeliveryStep.pickup;
      _activeOrder = order;
    } catch (e) {
      debugPrint('Erro ao aceitar pedido: $e');
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
      final order = _pendingOrders.firstWhere((o) => o.id == orderId);
      await _orderService.rejectOrder(
        firestoreId: order.firestoreId,
        reasons: reasons.map((r) => r.label).toList(),
      );
      _pendingOrders.removeWhere((o) => o.id == orderId);
    } catch (e) {
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
      await _orderService.confirmPickup(_activeOrder!.firestoreId);
      _activeOrder!.step = DeliveryStep.delivering;
    } catch (e) {
      debugPrint('Erro ao confirmar retirada: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> confirmDelivery() async {
    if (_activeOrder == null) return;

    _isLoading = true;
    notifyListeners();

    try {
      await _orderService.confirmDelivery(_activeOrder!.firestoreId);
      _activeOrder!.status = DeliveryOrderStatus.delivered;
      _activeOrder = null;
    } catch (e) {
      debugPrint('Erro ao confirmar entrega: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadVehicle(String uid) async {
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
      final orders = await _orderService.fetchDeliveryHistory(
        _deliveryPersonUid!,
      );
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
    if (_deliveryPersonUid == null) return {};
    return await _ratingService.getDetailedRatingStats(_deliveryPersonUid!);
  }

  Future<List<DeliveryReview>> getReviews() async {
    if (_deliveryPersonUid == null) return [];
    return await _ratingService.getDeliveryReviews(_deliveryPersonUid!);
  }
}
