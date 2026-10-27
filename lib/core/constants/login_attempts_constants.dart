class LoginAttemptsConstants {
  LoginAttemptsConstants._();

  static const int maxAttempts = 5;
  static const Duration blockDuration = Duration(minutes: 15);
  static const Duration attemptsResetDuration = Duration(minutes: 15);
}
