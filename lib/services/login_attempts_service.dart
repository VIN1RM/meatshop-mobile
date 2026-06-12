import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:meatshop_mobile/core/constants/login_attempts_constants.dart';
import 'package:meatshop_mobile/core/exceptions/login_blocked_exception.dart';
import 'package:meatshop_mobile/models/login_attempt_model.dart';

class LoginAttemptsService {
  LoginAttemptsService._();
  static final LoginAttemptsService instance = LoginAttemptsService._();

  final _db = FirebaseFirestore.instance;

  String _docId(String email) => email.trim().toLowerCase();

  DocumentReference<Map<String, dynamic>> _ref(String email) {
    return _db.collection(LoginAttemptsConstants.collection).doc(_docId(email));
  }

  Future<void> guardLogin(String email) async {
    final doc = await _ref(email).get();
    if (!doc.exists) return;

    final model = LoginAttemptModel.fromMap(doc.data()!);
    if (model.isBlocked) {
      throw LoginBlockedException(blockedUntil: model.blockedUntil!);
    }
  }

  Future<void> registerFailedAttempt(String email) async {
    final ref = _ref(email);
    final doc = await ref.get();

    final current = doc.exists
        ? LoginAttemptModel.fromMap(doc.data()!)
        : LoginAttemptModel(attempts: 0, lastAttempt: DateTime.now());

    final newAttempts = current.attempts + 1;

    debugPrint('LOGIN FAILED ATTEMPT: $email -> $newAttempts');

    final willBlock = newAttempts >= LoginAttemptsConstants.maxAttempts;

    debugPrint('WILL BLOCK: $willBlock');

    final blockedUntil = willBlock
        ? DateTime.now().add(LoginAttemptsConstants.blockDuration)
        : null;

    final updated = LoginAttemptModel(
      attempts: newAttempts,
      lastAttempt: DateTime.now(),
      blockedUntil: blockedUntil,
    );

    await ref.set(updated.toMap());

    if (willBlock) {
      debugPrint('THROWING LoginBlockedException');
      throw LoginBlockedException(blockedUntil: blockedUntil!);
    }
  }

  Future<void> clearAttempts(String email) async {
    await _ref(email).delete();
  }
}
