import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:meatshop_mobile/core/constants/login_attempts_constants.dart';
import 'package:meatshop_mobile/core/exceptions/login_blocked_exception.dart';
import 'package:meatshop_mobile/models/login_attempt_model.dart';
import 'package:meatshop_mobile/infra/auth/secure_key_value_store.dart';

class LoginAttemptsService {
  LoginAttemptsService({
    required SecureKeyValueStore storage,
    DateTime Function()? now,
  }) : _storage = storage,
       _now = now ?? DateTime.now;

  static final instance = LoginAttemptsService(
    storage: FlutterSecureKeyValueStore(),
  );
  final SecureKeyValueStore _storage;
  final DateTime Function() _now;
  final Set<String> _pending = {};

  String _key(String email) =>
      'meatshop.login.attempts.v1.${sha256.convert(utf8.encode(email.trim().toLowerCase()))}';

  Future<LoginAttemptModel?> _read(String email) async {
    final raw = await _storage.read(_key(email));
    if (raw == null) return null;
    return LoginAttemptModel.fromMap(jsonDecode(raw) as Map<String, dynamic>);
  }

  Future<T> authenticate<T>(String email, Future<T> Function() signIn) async {
    final key = _key(email);
    if (!_pending.add(key)) {
      throw FirebaseAuthException(code: 'login-in-progress');
    }
    try {
      await guardLogin(email);
      try {
        final result = await signIn();
        await clearAttempts(email);
        return result;
      } on FirebaseAuthException catch (error) {
        if (const {
          'invalid-credential',
          'wrong-password',
          'user-not-found',
          'INVALID_LOGIN_CREDENTIALS',
        }.contains(error.code)) {
          await registerFailedAttempt(email);
        }
        rethrow;
      }
    } finally {
      _pending.remove(key);
    }
  }

  Future<void> guardLogin(String email) async {
    final model = await _read(email);
    if (model == null) return;
    final now = _now();
    if (model.isBlockedAt(now)) {
      throw LoginBlockedException(blockedUntil: model.blockedUntil!);
    }
    if (model.shouldResetAttempts(
      now,
      LoginAttemptsConstants.attemptsResetDuration,
    )) {
      await clearAttempts(email);
    }
  }

  Future<void> registerFailedAttempt(String email) async {
    final current = await _read(email);
    final now = _now();
    final attempts =
        current == null ||
            current.shouldResetAttempts(
              now,
              LoginAttemptsConstants.attemptsResetDuration,
            )
        ? 1
        : current.attempts + 1;
    final blockedUntil = attempts >= LoginAttemptsConstants.maxAttempts
        ? now.add(LoginAttemptsConstants.blockDuration)
        : null;
    final updated = LoginAttemptModel(
      attempts: attempts,
      lastAttempt: now,
      blockedUntil: blockedUntil,
    );
    await _storage.write(_key(email), jsonEncode(updated.toMap()));
    if (blockedUntil != null) {
      throw LoginBlockedException(blockedUntil: blockedUntil);
    }
  }

  Future<void> clearAttempts(String email) => _storage.delete(_key(email));
}
