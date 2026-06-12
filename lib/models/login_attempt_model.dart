import 'package:cloud_firestore/cloud_firestore.dart';

class LoginAttemptModel {
  const LoginAttemptModel({
    required this.attempts,
    required this.lastAttempt,
    this.blockedUntil,
  });

  final int attempts;
  final DateTime lastAttempt;
  final DateTime? blockedUntil;

  bool get isBlocked {
    if (blockedUntil == null) return false;
    return DateTime.now().isBefore(blockedUntil!);
  }

  factory LoginAttemptModel.fromMap(Map<String, dynamic> map) {
    return LoginAttemptModel(
      attempts: (map['attempts'] as num?)?.toInt() ?? 0,
      lastAttempt: (map['last_attempt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      blockedUntil: (map['blocked_until'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'attempts': attempts,
      'last_attempt': Timestamp.fromDate(lastAttempt),
      'blocked_until': blockedUntil != null
          ? Timestamp.fromDate(blockedUntil!)
          : null,
    };
  }
}