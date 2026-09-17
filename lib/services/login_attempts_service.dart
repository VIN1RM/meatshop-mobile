import 'package:meatshop_mobile/core/constants/login_attempts_constants.dart';
import 'package:meatshop_mobile/core/exceptions/login_blocked_exception.dart';
import 'package:meatshop_mobile/models/login_attempt_model.dart';

class LoginAttemptsService {
  LoginAttemptsService._();
  static final LoginAttemptsService instance = LoginAttemptsService._();

  final Map<String, LoginAttemptModel> _attempts = {};

  String _docId(String email) => email.trim().toLowerCase();

  Future<void> guardLogin(String email) async {
    final key = _docId(email);
    final model = _attempts[key];
    if (model == null) return;
    final now = DateTime.now();

    if (model.isBlockedAt(now)) {
      throw LoginBlockedException(blockedUntil: model.blockedUntil!);
    }

    if (model.shouldResetAttempts(
      now,
      LoginAttemptsConstants.attemptsResetDuration,
    )) {
      _attempts.remove(key);
    }
  }

  Future<void> registerFailedAttempt(String email) async {
    final key = _docId(email);
    final current =
        _attempts[key] ??
        LoginAttemptModel(attempts: 0, lastAttempt: DateTime.now());

    final now = DateTime.now();
    final attempts =
        current.shouldResetAttempts(
          now,
          LoginAttemptsConstants.attemptsResetDuration,
        )
        ? 0
        : current.attempts;
    final newAttempts = attempts + 1;

    final willBlock = newAttempts >= LoginAttemptsConstants.maxAttempts;

    final blockedUntil = willBlock
        ? now.add(LoginAttemptsConstants.blockDuration)
        : null;

    final updated = LoginAttemptModel(
      attempts: newAttempts,
      lastAttempt: now,
      blockedUntil: blockedUntil,
    );

    _attempts[key] = updated;

    if (willBlock) {
      throw LoginBlockedException(blockedUntil: blockedUntil!);
    }
  }

  Future<void> clearAttempts(String email) async {
    _attempts.remove(_docId(email));
  }
}
