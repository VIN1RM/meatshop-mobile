class LoginBlockedException implements Exception {
  const LoginBlockedException({required this.blockedUntil});

  final DateTime blockedUntil;

  Duration get remainingDuration {
    final remaining = blockedUntil.difference(DateTime.now());
    return remaining.isNegative ? Duration.zero : remaining;
  }

  @override
  String toString() => 'LoginBlockedException(blockedUntil: $blockedUntil)';
}
