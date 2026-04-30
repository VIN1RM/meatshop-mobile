enum DeliveryAvailability { available, unavailable }

enum DeliveryOrderStatus { waiting, onTheWay, delivered }

enum DeliveryStep { pickup, delivering }

enum OrderRejectionReason {
  tooFar,
  vehicleIssue,
  dangerousArea,
  tooManyItems,
  lowValue,
  other;

  String get label {
    switch (this) {
      case OrderRejectionReason.tooFar:
        return 'Muito longe';
      case OrderRejectionReason.vehicleIssue:
        return 'Problema com o veículo';
      case OrderRejectionReason.dangerousArea:
        return 'Área de risco';
      case OrderRejectionReason.tooManyItems:
        return 'Muitos itens / peso elevado';
      case OrderRejectionReason.lowValue:
        return 'Valor muito baixo';
      case OrderRejectionReason.other:
        return 'Outro motivo';
    }
  }

  String get icon {
    switch (this) {
      case OrderRejectionReason.tooFar:
        return '📍';
      case OrderRejectionReason.vehicleIssue:
        return '🔧';
      case OrderRejectionReason.dangerousArea:
        return '⚠️';
      case OrderRejectionReason.tooManyItems:
        return '📦';
      case OrderRejectionReason.lowValue:
        return '💸';
      case OrderRejectionReason.other:
        return '💬';
    }
  }
}
