enum ChatParticipantType {
  unit,
  client,
  delivery;

  String get label {
    switch (this) {
      case ChatParticipantType.unit:
        return 'Açougue';
      case ChatParticipantType.client:
        return 'Cliente';
      case ChatParticipantType.delivery:
        return 'Entregador';
    }
  }

  String get icon {
    switch (this) {
      case ChatParticipantType.unit:
        return '🏪';
      case ChatParticipantType.client:
        return '👤';
      case ChatParticipantType.delivery:
        return '🛵';
    }
  }
}
