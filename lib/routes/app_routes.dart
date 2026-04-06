class AppRoutes {
  AppRoutes._();

  // ── Initial ──
  static const String splash = '/splash';
  static const String welcome = '/welcome';

  // ── Auth ──
  static const String login = '/auth/login';
  static const String selectRegister = '/auth/select_register';
  static const String register = '/auth/register';
  static const String changePassword = '/auth/change_password';

  // ── Shell (Home + abas principais) ──
  static const String shell = '/shell';

  // Mantido por compatibilidade – redireciona para shell
  static const String home = '/shell';
}