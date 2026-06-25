import 'package:flutter/material.dart';

enum OrderStatus {
  pending,
  confirmed,
  preparing,
  ready,
  outForDelivery,
  delivered,
  cancelled,
}

extension OrderStatusX on OrderStatus {
  static OrderStatus fromString(String value) {
    switch (value.toUpperCase()) {
      case 'PENDING':
        return OrderStatus.pending;
      case 'CONFIRMED':
        return OrderStatus.confirmed;
      case 'PREPARING':
        return OrderStatus.preparing;
      case 'READY':
        return OrderStatus.ready;
      case 'OUT_FOR_DELIVERY':
        return OrderStatus.outForDelivery;
      case 'DELIVERED':
        return OrderStatus.delivered;
      case 'CANCELLED':
        return OrderStatus.cancelled;
      default:
        return OrderStatus.pending;
    }
  }

  String get label {
    switch (this) {
      case OrderStatus.pending:
        return 'Aguardando confirmação';
      case OrderStatus.confirmed:
        return 'Confirmado';
      case OrderStatus.preparing:
        return 'Em preparo';
      case OrderStatus.ready:
        return 'Pronto para entrega';
      case OrderStatus.outForDelivery:
        return 'Em rota';
      case OrderStatus.delivered:
        return 'Entregue';
      case OrderStatus.cancelled:
        return 'Cancelado';
    }
  }

  bool get canCancel =>
      this == OrderStatus.pending || this == OrderStatus.confirmed;

  Color get color {
    switch (this) {
      case OrderStatus.pending:
        return const Color(0xFFE67E00);
      case OrderStatus.confirmed:
        return const Color(0xFF1565C0);
      case OrderStatus.preparing:
        return const Color(0xFF7B1FA2);
      case OrderStatus.ready:
        return const Color(0xFF2E7D32);
      case OrderStatus.outForDelivery:
        return const Color.fromARGB(255, 103, 121, 5);
      case OrderStatus.delivered:
        return const Color(0xFF2E7D32);
      case OrderStatus.cancelled:
        return const Color.fromARGB(255, 255, 0, 0);
    }
  }

  IconData get icon {
    switch (this) {
      case OrderStatus.pending:
        return Icons.hourglass_empty_rounded;
      case OrderStatus.confirmed:
        return Icons.check_circle_outline_rounded;
      case OrderStatus.preparing:
        return Icons.restaurant_rounded;
      case OrderStatus.ready:
        return Icons.done_all_rounded;
      case OrderStatus.outForDelivery:
        return Icons.delivery_dining_rounded;
      case OrderStatus.delivered:
        return Icons.check_circle_rounded;
      case OrderStatus.cancelled:
        return Icons.cancel_outlined;
    }
  }
}
