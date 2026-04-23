import 'package:flutter/material.dart';
import 'package:meatshop_mobile/core/enums/app_profile.dart';
import 'package:meatshop_mobile/routes/app_routes.dart';

enum DeliveryAvailability { available, unavailable }

enum DeliveryOrderStatus { waiting, onTheWay, delivered }

class DeliveryOrder {
  final int id;
  final String clientName;
  final String address;
  final String items;
  final double total;
  DeliveryOrderStatus status;

  DeliveryOrder({
    required this.id,
    required this.clientName,
    required this.address,
    required this.items,
    required this.total,
    this.status = DeliveryOrderStatus.waiting,
  });
}

class DeliveryProvider extends ChangeNotifier {
  DeliveryAvailability _availability = DeliveryAvailability.unavailable;
  DeliveryOrder? _activeOrder;
  bool _isLoading = false;

  // Mock data
  final List<DeliveryOrder> _pendingOrders = [
    DeliveryOrder(
      id: 1001,
      clientName: 'João Silva',
      address: 'Rua das Flores, 123 – Jardim América',
      items: '2x Picanha, 1x Costela',
      total: 187.90,
    ),
    DeliveryOrder(
      id: 1002,
      clientName: 'Maria Souza',
      address: 'Av. Paulista, 456 – Bela Vista',
      items: '1x Fraldinha, 1x Linguiça',
      total: 94.50,
    ),
  ];

  final List<DeliveryOrder> _historyOrders = [
    DeliveryOrder(
      id: 998,
      clientName: 'Carlos Lima',
      address: 'Rua Augusta, 789',
      items: '3x Alcatra',
      total: 210.00,
      status: DeliveryOrderStatus.delivered,
    ),
    DeliveryOrder(
      id: 999,
      clientName: 'Ana Paula',
      address: 'Alameda Santos, 321',
      items: '1x Filé Mignon',
      total: 135.00,
      status: DeliveryOrderStatus.delivered,
    ),
  ];

  // Getters
  DeliveryAvailability get availability => _availability;
  bool get isAvailable => _availability == DeliveryAvailability.available;
  DeliveryOrder? get activeOrder => _activeOrder;
  bool get hasActiveOrder => _activeOrder != null;
  bool get isLoading => _isLoading;
  List<DeliveryOrder> get pendingOrders => List.unmodifiable(_pendingOrders);
  List<DeliveryOrder> get historyOrders => List.unmodifiable(_historyOrders);

  // Mock: nome e rating do entregador
  String get deliveryPersonName => 'Rafael Mendes';
  double get averageRating => 4.8;
  String get vehicle => 'Moto';

  void toggleAvailability() {
    _availability = isAvailable
        ? DeliveryAvailability.unavailable
        : DeliveryAvailability.available;
    notifyListeners();
  }

  Future<void> acceptOrder(DeliveryOrder order) async {
    _isLoading = true;
    notifyListeners();

    // TODO: chamar API PATCH /orders/{id}/accept
    await Future.delayed(const Duration(seconds: 1));

    _pendingOrders.removeWhere((o) => o.id == order.id);
    order.status = DeliveryOrderStatus.onTheWay;
    _activeOrder = order;

    _isLoading = false;
    notifyListeners();
  }

  Future<void> rejectOrder(int orderId) async {
    _isLoading = true;
    notifyListeners();

    // TODO: chamar API PATCH /orders/{id}/reject
    await Future.delayed(const Duration(milliseconds: 500));

    _pendingOrders.removeWhere((o) => o.id == orderId);

    _isLoading = false;
    notifyListeners();
  }

  Future<void> confirmDelivery() async {
    if (_activeOrder == null) return;

    _isLoading = true;
    notifyListeners();

    // TODO: chamar API PATCH /orders/{id}/deliver
    await Future.delayed(const Duration(seconds: 1));

    _activeOrder!.status = DeliveryOrderStatus.delivered;
    _historyOrders.insert(0, _activeOrder!);
    _activeOrder = null;

    _isLoading = false;
    notifyListeners();
  }

  void logout(BuildContext context) {
    _availability = DeliveryAvailability.unavailable;
    _activeOrder = null;
    notifyListeners();

    Navigator.of(
      context,
    ).pushNamedAndRemoveUntil(AppRoutes.login, (route) => false);
  }

  void switchToClientMode(BuildContext context) {
    _availability = DeliveryAvailability.unavailable;
    _activeOrder = null;
    notifyListeners();

    Navigator.of(
      context,
    ).pushNamedAndRemoveUntil(AppRoutes.shell, (route) => false);
  }
}