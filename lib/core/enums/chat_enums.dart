enum ChatParticipantType {
  unit,
  client;

  String get label {
    switch (this) {
      case ChatParticipantType.unit:
        return 'Açougue';
      case ChatParticipantType.client:
        return 'Cliente';
    }
  }

  String get icon {
    switch (this) {
      case ChatParticipantType.unit:
        return '🏪';
      case ChatParticipantType.client:
        return '👤';
    }
  }
}
