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

enum ChatChannel {
  unit('UNIT'),
  deliveryPerson('DELIVERY_PERSON'),
  unitDeliveryPerson('UNIT_DELIVERY_PERSON');

  const ChatChannel(this.apiValue);
  final String apiValue;

  factory ChatChannel.fromApi(String value) => ChatChannel.values.firstWhere(
    (channel) => channel.apiValue == value,
    orElse: () => throw FormatException('Canal de chat inválido: $value'),
  );

  static ChatChannel between(
    ChatParticipantType current,
    ChatParticipantType other,
  ) {
    final participants = {current, other};
    if (participants.contains(ChatParticipantType.unit) &&
        participants.contains(ChatParticipantType.delivery)) {
      return ChatChannel.unitDeliveryPerson;
    }
    if (participants.contains(ChatParticipantType.delivery)) {
      return ChatChannel.deliveryPerson;
    }
    return ChatChannel.unit;
  }
}
