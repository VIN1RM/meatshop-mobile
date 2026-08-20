import 'package:flutter_test/flutter_test.dart';
import 'package:meatshop_mobile/core/constants/login_attempts_constants.dart';
import 'package:meatshop_mobile/models/login_attempt_model.dart';

void main() {
  group('LoginAttemptModel', () {
    final now = DateTime.utc(2026, 8, 20, 12);

    test('mantem as tentativas dentro da janela configurada', () {
      final model = LoginAttemptModel(
        attempts: 4,
        lastAttempt: now.subtract(const Duration(minutes: 4)),
      );

      expect(
        model.shouldResetAttempts(
          now,
          LoginAttemptsConstants.attemptsResetDuration,
        ),
        isFalse,
      );
    });

    test('zera as tentativas quando a janela expira', () {
      final model = LoginAttemptModel(
        attempts: 5,
        lastAttempt: now.subtract(LoginAttemptsConstants.attemptsResetDuration),
        blockedUntil: now,
      );

      expect(
        model.shouldResetAttempts(
          now,
          LoginAttemptsConstants.attemptsResetDuration,
        ),
        isTrue,
      );
      expect(model.isBlockedAt(now), isFalse);
    });

    test('considera o bloqueio ativo antes do prazo final', () {
      final model = LoginAttemptModel(
        attempts: 5,
        lastAttempt: now,
        blockedUntil: now.add(LoginAttemptsConstants.blockDuration),
      );

      expect(model.isBlockedAt(now), isTrue);
    });
  });
}
