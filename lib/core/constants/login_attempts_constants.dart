class LoginAttemptsConstants {
  LoginAttemptsConstants._();

  static const int maxAttempts = 5;
  static const Duration blockDuration = Duration(minutes: 5);
  static const Duration attemptsResetDuration = Duration(minutes: 5);
  static const String collection = 'login_attempts';
}
