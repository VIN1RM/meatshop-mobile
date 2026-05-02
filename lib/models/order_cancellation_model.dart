import 'package:flutter/material.dart';

enum CancellationReason {
  mistake,
  tooLong,
  wantToChange,
  cheaperFound,
  other;

  String get label {
    switch (this) {
      case CancellationReason.mistake:
        return 'Fiz o pedido por engano';
      case CancellationReason.tooLong:
        return 'Demorou mais do que esperava';
      case CancellationReason.wantToChange:
        return 'Preciso alterar o pedido';
      case CancellationReason.cheaperFound:
        return 'Encontrei produto mais barato';
      case CancellationReason.other:
        return 'Outro motivo';
    }
  }

  IconData get icon {
    switch (this) {
      case CancellationReason.mistake:
        return Icons.undo_rounded;
      case CancellationReason.tooLong:
        return Icons.timer_off_outlined;
      case CancellationReason.wantToChange:
        return Icons.edit_outlined;
      case CancellationReason.cheaperFound:
        return Icons.price_change_outlined;
      case CancellationReason.other:
        return Icons.more_horiz_rounded;
    }
  }
}
