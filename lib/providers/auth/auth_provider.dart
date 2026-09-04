import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:meatshop_mobile/core/enums/app_profile.dart';
import 'package:meatshop_mobile/core/exceptions/api_exception.dart';
import 'package:meatshop_mobile/core/exceptions/login_blocked_exception.dart';
import 'package:meatshop_mobile/core/exceptions/social_account_link_required_exception.dart';
import 'package:meatshop_mobile/core/utils/custom_snackbar.dart';
import 'package:meatshop_mobile/models/address_model.dart';
import 'package:meatshop_mobile/providers/payment_provider.dart';
import 'package:meatshop_mobile/routes/app_routes.dart';
import 'package:meatshop_mobile/services/firebase_identity_service.dart';
import 'package:meatshop_mobile/services/notification_service.dart';
import 'package:meatshop_mobile/ui/dialogs/custom_dialog.dart';
import 'package:meatshop_mobile/ui/dialogs/link_social_account_dialog.dart';
import 'package:meatshop_mobile/providers/user/user_provider.dart';
import 'package:provider/provider.dart';
import 'package:meatshop_mobile/providers/user_preferences_provider.dart';
import 'package:meatshop_mobile/providers/user/address_provider.dart';
import 'package:meatshop_mobile/core/network/api_failure.dart';
import 'package:meatshop_mobile/data/repositories/federated_auth_repository.dart';
import 'package:meatshop_mobile/data/repositories/delivery_repository.dart';

class AuthProvider extends ChangeNotifier {
  AuthProvider({
    required FederatedAuthRepository federatedAuth,
    required DeliveryRepository delivery,
  }) : _federatedAuth = federatedAuth,
       _delivery = delivery;

  final FederatedAuthRepository _federatedAuth;
  final DeliveryRepository _delivery;
  bool _isAuthenticated = false;
  AppProfile? _appProfile;
  AppProfile? _activeProfile;
  String? _errorMessage;
  int? _backendUserId;

  bool get isAuthenticated => _isAuthenticated;
  AppProfile? get appProfile => _appProfile;
  AppProfile? get activeProfile => _activeProfile;
  String? get errorMessage => _errorMessage;
  int? get backendUserId => _backendUserId;

  bool get isClient => _activeProfile == AppProfile.client;
  bool get isDelivery => _activeProfile == AppProfile.delivery;
  User? get currentUser => AuthService.instance.currentUser;

  bool _needsProfileCompletion = false;
  bool get needsProfileCompletion => _needsProfileCompletion;

  Future<void> login({
    required BuildContext context,
    required String email,
    required String password,
  }) async {
    _errorMessage = null;

    try {
      await AuthService.instance.login(
        email: email,
        password: password,
        loadFirestoreProfile: false,
      );

      if (!context.mounted) return;
      await _finishBackendLogin(context);
    } on LoginBlockedException catch (e) {
      if (context.mounted) {
        Navigator.of(
          context,
        ).pushNamed(AppRoutes.accountBlocked, arguments: e.blockedUntil);
      }
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

  Future<void> loginWithGoogle(BuildContext context) async {
    _errorMessage = null;
    try {
      await AuthService.instance.loginWithGoogle(useBackendProfile: true);
      if (!context.mounted) return;
      await _finishBackendLogin(context);
    } on SocialAccountLinkRequiredException catch (e) {
      if (!context.mounted) return;
      await _linkExistingSocialAccount(context, e);
    } on ApiException catch (e) {
      _errorMessage = e.message;
      notifyListeners();
      if (context.mounted) {
        CustomDialog.showError(
          context: context,
          title: 'Erro ao entrar',
          message: e.message,
        );
      }
    } catch (e) {
      debugPrint('GOOGLE LOGIN ERROR: $e');
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

  Future<void> loginWithApple(BuildContext context) async {
    _errorMessage = null;
    try {
      await AuthService.instance.loginWithApple(useBackendProfile: true);
      if (!context.mounted) return;
      await _finishBackendLogin(context);
    } on SocialAccountLinkRequiredException catch (e) {
      if (!context.mounted) return;
      await _linkExistingSocialAccount(context, e);
    } on ApiException catch (e) {
      _errorMessage = e.message;
      notifyListeners();
      if (context.mounted) {
        CustomDialog.showError(
          context: context,
          title: 'Erro ao entrar',
          message: e.message,
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

  Future<void> completeProfileWithType({
    required BuildContext context,
    required String name,
    required String cpf,
    required String phone,
    required AppProfile profile,
    String? vehicleType,
    Map<String, dynamic>? vehicleData,
    AddressModel? addressData,
  }) async {
    try {
      final uid = AuthService.instance.currentUser!.uid;

      final user = await _requireFederatedAuth().completeProfile(
        name: name,
        cpf: cpf,
        phone: phone,
        appProfile: profile,
      );
      _appProfile = user.appProfile;
      _needsProfileCompletion = !user.profileComplete;

      if ((profile == AppProfile.delivery || profile == AppProfile.both) &&
          vehicleType != null &&
          vehicleData != null) {
        await _registerBackendVehicle(vehicleType, vehicleData);
      }

      if ((profile == AppProfile.client || profile == AppProfile.both) &&
          addressData != null &&
          context.mounted) {
        await context.read<AddressProvider>().add(
          uid,
          addressData.copyWith(isDefault: true),
        );
      }

      _needsProfileCompletion = false;
      _appProfile = profile;
      notifyListeners();

      if (context.mounted) {
        _redirectAfterLogin(context);
      }
    } catch (e) {
      if (context.mounted) {
        CustomDialog.showError(
          context: context,
          title: 'Erro ao salvar dados',
          message: e is ApiException
              ? e.message
              : 'Não foi possível salvar seus dados. Tente novamente.',
        );
      }
    }
  }

  Future<void> _linkExistingSocialAccount(
    BuildContext context,
    SocialAccountLinkRequiredException linkRequest,
  ) async {
    if (!context.mounted) return;

    final password = await LinkSocialAccountDialog.show(
      context,
      email: linkRequest.email,
    );
    if (password == null || !context.mounted) return;

    try {
      await AuthService.instance.linkSocialAccount(
        email: linkRequest.email,
        password: password,
        pendingCredential: linkRequest.pendingCredential,
        useBackendProfile: true,
      );
      if (context.mounted) {
        await _finishBackendLogin(context, accountPassword: password);
      }
    } on LoginBlockedException catch (error) {
      if (context.mounted) {
        Navigator.of(
          context,
        ).pushNamed(AppRoutes.accountBlocked, arguments: error.blockedUntil);
      }
    } on FirebaseAuthException catch (error) {
      _errorMessage = _mapAuthError(error.code);
      notifyListeners();
      if (context.mounted) {
        await CustomDialog.showError(
          context: context,
          title: 'Não foi possível vincular',
          message: _errorMessage!,
        );
      }
    } on ApiException catch (error) {
      _errorMessage = error.message;
      notifyListeners();
      if (context.mounted) {
        await CustomDialog.showError(
          context: context,
          title: 'Não foi possível vincular',
          message: error.message,
        );
      }
    }
  }

  Future<void> completeSocialProfile({
    required BuildContext context,
    required String name,
    required String cpf,
    required String phone,
  }) async {
    try {
      final user = await _requireFederatedAuth().completeProfile(
        name: name,
        cpf: cpf,
        phone: phone,
        appProfile: _appProfile ?? AppProfile.client,
      );
      _appProfile = user.appProfile;
      _needsProfileCompletion = !user.profileComplete;
      notifyListeners();

      if (context.mounted) {
        _redirectAfterLogin(context);
      }
    } catch (e) {
      if (context.mounted) {
        CustomDialog.showError(
          context: context,
          title: 'Erro ao salvar dados',
          message: e is ApiException
              ? e.message
              : 'Não foi possível salvar seus dados. Tente novamente.',
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
    VoidCallback? onEmailExists,
  }) async {
    _errorMessage = null;

    try {
      return await _registerWithBackend(
        context: context,
        name: name,
        email: email,
        password: password,
        cpf: cpf,
        phone: phone,
        profile: AppProfile.client,
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        onEmailExists?.call();
        return false;
      }
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
    VoidCallback? onEmailExists,
  }) async {
    _errorMessage = null;

    try {
      return await _registerWithBackend(
        context: context,
        name: name,
        email: email,
        password: password,
        cpf: cpf,
        phone: phone,
        profile: AppProfile.delivery,
        vehicleType: vehicleType,
        vehicleData: vehicleData,
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        onEmailExists?.call();
        return false;
      }
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
    VoidCallback? onEmailExists,
  }) async {
    _errorMessage = null;

    try {
      return await _registerWithBackend(
        context: context,
        name: name,
        email: email,
        password: password,
        cpf: cpf,
        phone: phone,
        profile: AppProfile.both,
        vehicleType: vehicleType,
        vehicleData: vehicleData,
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        onEmailExists?.call();
        return false;
      }
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

  Future<bool> completePendingProfile({
    required BuildContext context,
    required String name,
    required String cpf,
    required String phone,
    AddressModel? addressData,
    String? vehicleType,
    Map<String, dynamic>? vehicleData,
  }) async {
    try {
      final uid = AuthService.instance.currentUser!.uid;

      final user = await _requireFederatedAuth().completeProfile(
        name: name,
        cpf: cpf,
        phone: phone,
        appProfile: _appProfile ?? AppProfile.client,
      );
      _appProfile = user.appProfile;

      if (addressData != null && context.mounted) {
        await context.read<AddressProvider>().add(
          uid,
          addressData.copyWith(isDefault: true),
        );
      }

      if (vehicleType != null && vehicleData != null) {
        await _registerBackendVehicle(vehicleType, vehicleData);
      }

      if (context.mounted) {
        await context.read<UserProvider>().loadUser(uid);
      }
      return true;
    } catch (e) {
      if (context.mounted) {
        CustomDialog.showError(
          context: context,
          title: 'Erro ao salvar dados',
          message: e is ApiException
              ? e.message
              : 'Não foi possível salvar seus dados. Tente novamente.',
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
    final uid = AuthService.instance.currentUser?.uid;
    if (uid != null) {
      await NotificationService.instance.clearTokenForUser(uid);
    }

    try {
      await _requireFederatedAuth().logout();
    } catch (_) {
      // Logout local e Firebase deve prosseguir mesmo se a API estiver indisponível.
    }
    await AuthService.instance.logout();

    _isAuthenticated = false;
    _appProfile = null;
    _activeProfile = null;
    _errorMessage = null;
    _backendUserId = null;
    notifyListeners();

    if (context.mounted) {
      context.read<UserProvider>().clear();
      context.read<UserPreferencesProvider>().clear();
      Navigator.of(
        context,
      ).pushNamedAndRemoveUntil(AppRoutes.login, (route) => false);
    }
  }

  Future<void> restoreSession(BuildContext context, User firebaseUser) async {
    try {
      final idToken = await firebaseUser.getIdToken(true);
      if (idToken == null) throw StateError('Firebase ID token unavailable');
      final user = await _requireFederatedAuth().restore(idToken);
      if (!context.mounted) return;
      await _applyBackendUser(context, user);
    } catch (_) {
      _isAuthenticated = false;
      notifyListeners();
      if (context.mounted) {
        Navigator.of(context).pushReplacementNamed(AppRoutes.login);
      }
    }
  }

  FederatedAuthRepository _requireFederatedAuth() {
    return _federatedAuth;
  }

  Future<bool> _registerWithBackend({
    required BuildContext context,
    required String name,
    required String email,
    required String password,
    required String cpf,
    required String phone,
    required AppProfile profile,
    String? vehicleType,
    Map<String, dynamic>? vehicleData,
  }) async {
    final firebaseUser = await AuthService.instance.registerFirebaseIdentity(
      name: name,
      email: email,
      password: password,
    );
    final idToken = await firebaseUser.getIdToken(true);
    if (idToken == null) throw StateError('Firebase ID token unavailable');

    final repository = _requireFederatedAuth();
    try {
      await repository.exchangeFirebaseToken(idToken);
      await repository.completeProfile(
        name: name,
        cpf: cpf,
        phone: phone,
        appProfile: profile,
      );

      if ((profile == AppProfile.delivery || profile == AppProfile.both) &&
          vehicleType != null &&
          vehicleData != null) {
        await _registerBackendVehicle(vehicleType, vehicleData);
      }
    } catch (_) {
      try {
        await repository.logout();
      } catch (_) {
        // Preserve the registration failure; local Firebase logout still runs.
      }
      await AuthService.instance.logout();
      rethrow;
    }

    await repository.logout();
    await AuthService.instance.logout();
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
  }

  String _backendVehicleType(String value) {
    final normalized = value.toUpperCase();
    if (normalized.contains('BIKE') || normalized.contains('BICI')) {
      return 'BIKE';
    }
    if (normalized.contains('CAR')) return 'CAR';
    if (normalized.contains('SCOOTER')) return 'SCOOTER';
    return 'MOTORCYCLE';
  }

  Future<void> _registerBackendVehicle(
    String vehicleType,
    Map<String, dynamic> vehicleData,
  ) async {
    final delivery = _delivery;
    final type = _backendVehicleType(vehicleType);
    await delivery.register(type == 'SCOOTER' ? 'MOTORCYCLE' : type);
    await delivery.createVehicle({
      'type': type,
      'model': '${vehicleData['model'] ?? ''}',
      'plate': '${vehicleData['plate'] ?? ''}'
          .replaceAll(RegExp(r'[^A-Za-z0-9]'), '')
          .toUpperCase(),
      'color': '${vehicleData['color'] ?? ''}',
      'year':
          int.tryParse('${vehicleData['year'] ?? ''}') ?? DateTime.now().year,
    });
  }

  Future<void> _finishBackendLogin(
    BuildContext context, {
    String? accountPassword,
  }) async {
    final firebaseUser = AuthService.instance.currentUser!;
    final idToken = await firebaseUser.getIdToken(true);
    if (idToken == null) throw StateError('Firebase ID token unavailable');

    try {
      final user = await _requireFederatedAuth().exchangeFirebaseToken(
        idToken,
        accountPassword: accountPassword,
      );
      if (context.mounted) await _applyBackendUser(context, user);
    } on ApiFailure catch (failure) {
      if (failure.code != 'ACCOUNT_LINK_REQUIRED' || !context.mounted) rethrow;
      final password = await LinkSocialAccountDialog.show(
        context,
        email: firebaseUser.email ?? '',
      );
      if (password == null || !context.mounted) return;
      final user = await _requireFederatedAuth().exchangeFirebaseToken(
        idToken,
        accountPassword: password,
      );
      if (context.mounted) await _applyBackendUser(context, user);
    }
  }

  Future<void> _applyBackendUser(
    BuildContext context,
    BackendAuthUser user,
  ) async {
    _isAuthenticated = true;
    _backendUserId = user.id;
    _appProfile = user.appProfile;
    _needsProfileCompletion = !user.profileComplete;
    notifyListeners();

    final uid = AuthService.instance.currentUser!.uid;
    await NotificationService.instance.saveTokenForUser(uid);
    if (!context.mounted) return;
    await context.read<UserPreferencesProvider>().loadForUser(uid);
    if (!context.mounted) return;
    context.read<PaymentProvider>().init();
    if (_needsProfileCompletion) {
      Navigator.of(context).pushReplacementNamed(
        AppRoutes.completeProfile,
        arguments: const CompleteProfileArgs(),
      );
    } else {
      _redirectAfterLogin(context);
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
      await AuthService.instance.reauthenticate(password: password);
      await _federatedAuth.deleteAccount();
      await AuthService.instance.deleteCurrentIdentity();

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

        CustomSnackBar.success(
          'Sua conta foi excluída com sucesso.',
          context: context,
          duration: const Duration(seconds: 10),
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
      'credential-already-in-use' =>
        'Este login social já está vinculado a outra conta.',
      'invalid-credential' => 'E-mail ou senha incorretos.',
      'too-many-requests' => 'Muitas tentativas. Tente novamente mais tarde.',
      'network-request-failed' => 'Sem conexão com a internet.',
      _ => 'Erro ao autenticar. Tente novamente.',
    };
  }
}
