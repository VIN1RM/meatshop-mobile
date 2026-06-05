import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:meatshop_mobile/core/enums/app_profile.dart';
import 'package:meatshop_mobile/core/exceptions/api_exception.dart';
import 'package:meatshop_mobile/providers/payment_provider.dart';
import 'package:meatshop_mobile/routes/app_routes.dart';
import 'package:meatshop_mobile/services/auth_service.dart';
import 'package:meatshop_mobile/services/notification_service.dart';
import 'package:meatshop_mobile/ui/dialogs/custom_dialog.dart';
import 'package:meatshop_mobile/providers/user/user_provider.dart';
import 'package:provider/provider.dart';
import 'package:meatshop_mobile/services/order_status_notification_service.dart';

class AuthProvider extends ChangeNotifier {
  bool _isAuthenticated = false;
  AppProfile? _appProfile;
  AppProfile? _activeProfile;
  String? _errorMessage;

  bool get isAuthenticated => _isAuthenticated;
  AppProfile? get appProfile => _appProfile;
  AppProfile? get activeProfile => _activeProfile;
  String? get errorMessage => _errorMessage;

  bool get isClient => _activeProfile == AppProfile.client;
  bool get isDelivery => _activeProfile == AppProfile.delivery;
  User? get currentUser => AuthService.instance.currentUser;

  Future<void> login({
    required BuildContext context,
    required String email,
    required String password,
  }) async {
    _errorMessage = null;

    try {
      final profileFromFirestore = await AuthService.instance.login(
        email: email,
        password: password,
      );

      _isAuthenticated = true;
      _appProfile = AppProfile.fromString(profileFromFirestore);
      notifyListeners();

      if (context.mounted) {
        await context.read<UserProvider>().loadUser(
          AuthService.instance.currentUser!.uid,
        );
      }

      if (context.mounted) {
        context.read<PaymentProvider>().init();
      }

      OrderStatusNotificationWatcher.instance.start(
        userId: AuthService.instance.currentUser!.uid,
        navigatorKey: NotificationService.instance.navigatorKey!,
      );

      if (!context.mounted) return;
      _redirectAfterLogin(context);
    } on FirebaseAuthException catch (e) {
      _errorMessage = _mapAuthError(e.code);
      notifyListeners();

      if (context.mounted) {
        CustomDialog.showError(
          context: context,
          title: 'Erro ao entrar',
          message: _errorMessage!,
        );
      }
    } catch (e) {
      _errorMessage = 'Erro inesperado. Tente novamente.';
      notifyListeners();

      if (context.mounted) {
        CustomDialog.showError(
          context: context,
          title: 'Erro ao entrar',
          message: _errorMessage!,
        );
      }
    }
  }

  Future<bool> registerClient({
    required BuildContext context,
    required String name,
    required String email,
    required String password,
    required String cpf,
    required String phone,
  }) async {
    _errorMessage = null;

    try {
      await AuthService.instance.registerClient(
        name: name,
        email: email,
        password: password,
        cpf: cpf,
        phone: phone,
      );

      if (context.mounted) {
        CustomDialog.showSuccess(
          context: context,
          title: 'Cadastro realizado!',
          message: 'Faça login para continuar.',
          onDismiss: () =>
              Navigator.of(context).pushReplacementNamed(AppRoutes.login),
        );
      }
      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = _mapAuthError(e.code);
      notifyListeners();

      if (context.mounted) {
        CustomDialog.showError(
          context: context,
          title: 'Erro no cadastro',
          message: _errorMessage!,
        );
      }
      return false;
    } catch (e) {
      _errorMessage = e is ApiException
          ? e.message
          : ApiException.fromFirestore(e);
      notifyListeners();

      if (context.mounted) {
        CustomDialog.showError(
          context: context,
          title: 'Erro no cadastro',
          message: _errorMessage!,
        );
      }
      return false;
    }
  }

  Future<bool> registerDelivery({
    required BuildContext context,
    required String name,
    required String email,
    required String password,
    required String cpf,
    required String phone,
    required String vehicleType,
    required Map<String, dynamic> vehicleData,
  }) async {
    _errorMessage = null;

    try {
      await AuthService.instance.registerDelivery(
        name: name,
        email: email,
        password: password,
        cpf: cpf,
        phone: phone,
        vehicleType: vehicleType,
        vehicleData: vehicleData,
      );

      if (context.mounted) {
        CustomDialog.showSuccess(
          context: context,
          title: 'Cadastro realizado!',
          message: 'Faça login para continuar.',
          onDismiss: () =>
              Navigator.of(context).pushReplacementNamed(AppRoutes.login),
        );
      }
      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = _mapAuthError(e.code);
      notifyListeners();

      if (context.mounted) {
        CustomDialog.showError(
          context: context,
          title: 'Erro no cadastro',
          message: _errorMessage!,
        );
      }
      return false;
    } catch (e) {
      _errorMessage = e is ApiException
          ? e.message
          : ApiException.fromFirestore(e);
      notifyListeners();

      if (context.mounted) {
        CustomDialog.showError(
          context: context,
          title: 'Erro no cadastro',
          message: _errorMessage!,
        );
      }
      return false;
    }
  }

  Future<bool> registerBoth({
    required BuildContext context,
    required String name,
    required String email,
    required String password,
    required String cpf,
    required String phone,
    required String vehicleType,
    required Map<String, dynamic> vehicleData,
  }) async {
    _errorMessage = null;

    try {
      await AuthService.instance.registerBoth(
        name: name,
        email: email,
        password: password,
        cpf: cpf,
        phone: phone,
        vehicleType: vehicleType,
        vehicleData: vehicleData,
      );

      if (context.mounted) {
        CustomDialog.showSuccess(
          context: context,
          title: 'Cadastro realizado!',
          message: 'Faça login para continuar.',
          onDismiss: () =>
              Navigator.of(context).pushReplacementNamed(AppRoutes.login),
        );
      }
      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = _mapAuthError(e.code);
      notifyListeners();

      if (context.mounted) {
        CustomDialog.showError(
          context: context,
          title: 'Erro no cadastro',
          message: _errorMessage!,
        );
      }
      return false;
    } catch (e) {
      _errorMessage = e is ApiException
          ? e.message
          : ApiException.fromFirestore(e);
      notifyListeners();

      if (context.mounted) {
        CustomDialog.showError(
          context: context,
          title: 'Erro no cadastro',
          message: _errorMessage!,
        );
      }
      return false;
    }
  }

  void selectActiveProfile({
    required BuildContext context,
    required AppProfile profile,
  }) {
    assert(
      profile != AppProfile.both,
      'O perfil ativo não pode ser BOTH — deve ser CLIENT ou DELIVERY.',
    );
    _activeProfile = profile;
    notifyListeners();

    final route = profile == AppProfile.delivery
        ? AppRoutes.deliveryShell
        : AppRoutes.shell;

    Navigator.of(context).pushReplacementNamed(route);
  }

  Future<void> logout(BuildContext context) async {
    OrderStatusNotificationWatcher.instance.stop();

    final uid = AuthService.instance.currentUser?.uid;
    if (uid != null) {
      await NotificationService.instance.clearTokenForUser(uid);
    }

    await AuthService.instance.logout();

    _isAuthenticated = false;
    _appProfile = null;
    _activeProfile = null;
    _errorMessage = null;
    notifyListeners();

    if (context.mounted) {
      context.read<UserProvider>().clear();
      Navigator.of(
        context,
      ).pushNamedAndRemoveUntil(AppRoutes.login, (route) => false);
    }
  }

  Future<void> restoreSession(BuildContext context, User firebaseUser) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(firebaseUser.uid)
          .get();

      final profileString = doc.data()?['app_profile'] as String? ?? 'CLIENT';

      _isAuthenticated = true;
      _appProfile = AppProfile.fromString(profileString);
      notifyListeners();

      if (context.mounted) {
        await context.read<UserProvider>().loadUser(firebaseUser.uid);
      }

      if (context.mounted) {
        context.read<PaymentProvider>().init();
      }

      await NotificationService.instance.saveTokenForUser(firebaseUser.uid);

      OrderStatusNotificationWatcher.instance.start(
        userId: firebaseUser.uid,
        navigatorKey: NotificationService.instance.navigatorKey!,
      );

      if (!context.mounted) return;
      _redirectAfterLogin(context);
    } catch (_) {
      _isAuthenticated = false;
      notifyListeners();
      if (context.mounted) {
        Navigator.of(context).pushReplacementNamed(AppRoutes.login);
      }
    }
  }

  void switchToDeliveryMode(BuildContext context) {
    _activeProfile = AppProfile.delivery;
    notifyListeners();

    Navigator.of(context).pushNamedAndRemoveUntil(
      AppRoutes.modeSwitch,
      (route) => false,
      arguments: AppRoutes.deliveryShell,
    );
  }

  Future<void> deleteAccount({
    required BuildContext context,
    required String password,
  }) async {
    try {
      await AuthService.instance.deleteAccount(password: password);

      _isAuthenticated = false;
      _appProfile = null;
      _activeProfile = null;
      _errorMessage = null;
      notifyListeners();

      if (context.mounted) {
        context.read<UserProvider>().clear();
        context.read<PaymentProvider>().clear();
        Navigator.of(
          context,
        ).pushNamedAndRemoveUntil(AppRoutes.login, (route) => false);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Sua conta foi excluída com sucesso.'),
            backgroundColor: Color(0xFFC0392B),
            duration: Duration(seconds: 10),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      final message = switch (e.code) {
        'wrong-password' => 'Senha incorreta. Tente novamente.',
        'invalid-credential' => 'Senha incorreta. Tente novamente.',
        'too-many-requests' => 'Muitas tentativas. Tente mais tarde.',
        'requires-recent-login' =>
          'Sessão expirada. Faça login novamente antes de excluir.',
        _ => 'Erro ao excluir conta. Tente novamente.',
      };

      if (context.mounted) {
        CustomDialog.showError(
          context: context,
          title: 'Não foi possível excluir',
          message: message,
        );
      }
    } catch (e) {
      if (context.mounted) {
        CustomDialog.showError(
          context: context,
          title: 'Erro inesperado',
          message: 'Não foi possível excluir sua conta. Tente novamente.',
        );
      }
    }
  }

  void _redirectAfterLogin(BuildContext context) {
    switch (_appProfile) {
      case AppProfile.client:
        _activeProfile = AppProfile.client;
        Navigator.of(context).pushReplacementNamed(AppRoutes.shell);
      case AppProfile.delivery:
        _activeProfile = AppProfile.delivery;
        Navigator.of(context).pushReplacementNamed(AppRoutes.deliveryShell);
      case AppProfile.both:
        Navigator.of(context).pushReplacementNamed(AppRoutes.modeSelection);
      case null:
        Navigator.of(context).pushReplacementNamed(AppRoutes.login);
    }
  }

  String _mapAuthError(String code) {
    return switch (code) {
      'user-not-found' => 'Usuário não encontrado.',
      'wrong-password' => 'Senha incorreta.',
      'invalid-email' => 'E-mail inválido.',
      'user-disabled' => 'Conta desativada.',
      'email-already-in-use' => 'Este e-mail já está cadastrado.',
      'weak-password' => 'Senha muito fraca.',
      'invalid-credential' => 'E-mail ou senha incorretos.',
      'too-many-requests' => 'Muitas tentativas. Tente novamente mais tarde.',
      'network-request-failed' => 'Sem conexão com a internet.',
      _ => 'Erro ao autenticar. Tente novamente.',
    };
  }
}
