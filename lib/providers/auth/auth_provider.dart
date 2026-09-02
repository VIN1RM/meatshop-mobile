import 'package:cloud_firestore/cloud_firestore.dart';
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
import 'package:meatshop_mobile/services/auth_service.dart';
import 'package:meatshop_mobile/services/notification_service.dart';
import 'package:meatshop_mobile/ui/dialogs/custom_dialog.dart';
import 'package:meatshop_mobile/ui/dialogs/link_social_account_dialog.dart';
import 'package:meatshop_mobile/providers/user/user_provider.dart';
import 'package:provider/provider.dart';
import 'package:meatshop_mobile/services/order_status_notification_service.dart';
import 'package:meatshop_mobile/providers/user_preferences_provider.dart';
import 'package:meatshop_mobile/providers/user/address_provider.dart';
import 'package:meatshop_mobile/providers/delivery/vehicle_provider.dart';
import 'package:meatshop_mobile/core/config/feature_flags.dart';
import 'package:meatshop_mobile/core/network/api_failure.dart';
import 'package:meatshop_mobile/data/repositories/federated_auth_repository.dart';

class AuthProvider extends ChangeNotifier {
  AuthProvider({
    FederatedAuthRepository? federatedAuth,
    FeatureFlags flags = const FeatureFlags(
      backendAuth: false,
      backendMarketplace: false,
    ),
  }) : _federatedAuth = federatedAuth,
       _flags = flags;

  final FederatedAuthRepository? _federatedAuth;
  final FeatureFlags _flags;
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

  bool _needsProfileCompletion = false;
  bool get needsProfileCompletion => _needsProfileCompletion;

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
        loadFirestoreProfile: !_flags.backendAuth,
      );

      if (_flags.backendAuth) {
        if (!context.mounted) return;
        await _finishBackendLogin(context);
        return;
      }

      _isAuthenticated = true;
      _appProfile = AppProfile.fromString(profileFromFirestore);
      notifyListeners();

      if (context.mounted) {
        await context.read<UserProvider>().loadUser(
          AuthService.instance.currentUser!.uid,
        );
      }

      if (context.mounted) {
        await context.read<UserPreferencesProvider>().loadForUser(
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
      final profile = await AuthService.instance.loginWithGoogle(
        useBackendProfile: _flags.backendAuth,
      );
      if (!context.mounted) return;
      if (_flags.backendAuth) {
        await _finishBackendLogin(context);
        return;
      }
      await _afterSocialLogin(context, profile);
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
      final profile = await AuthService.instance.loginWithApple(
        useBackendProfile: _flags.backendAuth,
      );
      if (!context.mounted) return;
      if (_flags.backendAuth) {
        await _finishBackendLogin(context);
        return;
      }
      await _afterSocialLogin(context, profile);
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

      if (_flags.backendAuth) {
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
          await AuthService.instance.addVehicleForDeliveryPerson(
            uid: uid,
            vehicleType: vehicleType,
            vehicleData: vehicleData,
          );
        }
      } else if (profile == AppProfile.delivery || profile == AppProfile.both) {
        await AuthService.instance.completeSocialProfileWithVehicle(
          uid: uid,
          name: name,
          cpf: cpf,
          phone: phone,
          appProfile: profile,
          vehicleType: vehicleType!,
          vehicleData: vehicleData!,
        );
      } else {
        await AuthService.instance.completeSocialProfile(
          uid: uid,
          name: name,
          cpf: cpf,
          phone: phone,
        );

        if (profile == AppProfile.client) {
          await FirebaseFirestore.instance.collection('users').doc(uid).update({
            'app_profile': 'CLIENT',
          });
        }
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

  Future<void> _afterSocialLogin(BuildContext context, String profile) async {
    final uid = AuthService.instance.currentUser!.uid;

    _isAuthenticated = true;
    _appProfile = AppProfile.fromString(profile);
    notifyListeners();

    final isComplete = await AuthService.instance.isSocialProfileComplete(uid);
    _needsProfileCompletion = !isComplete;

    if (context.mounted) {
      await context.read<UserProvider>().loadUser(uid);
    }
    if (context.mounted) {
      await context.read<UserPreferencesProvider>().loadForUser(uid);
    }
    if (context.mounted) {
      context.read<PaymentProvider>().init();
    }

    OrderStatusNotificationWatcher.instance.start(
      userId: uid,
      navigatorKey: NotificationService.instance.navigatorKey!,
    );

    if (!context.mounted) return;

    if (_needsProfileCompletion) {
      final hasChosenProfile = await AuthService.instance.hasChosenProfile(uid);
      if (!context.mounted) return;

      AddressModel? existingAddress;
      Map<String, dynamic>? existingVehicle;

      if (hasChosenProfile &&
          (_appProfile == AppProfile.client ||
              _appProfile == AppProfile.both)) {
        final addressProvider = context.read<AddressProvider>();
        await addressProvider.load(uid);
        if (!context.mounted) return;
        final addresses = addressProvider.addresses;
        if (addresses.isNotEmpty) {
          existingAddress = addresses.firstWhere(
            (address) => address.isDefault,
            orElse: () => addresses.first,
          );
        }
      }

      if (hasChosenProfile &&
          (_appProfile == AppProfile.delivery ||
              _appProfile == AppProfile.both)) {
        final vehicleProvider = context.read<VehicleProvider>();
        await vehicleProvider.loadVehicle(uid);
        if (!context.mounted) return;
        if (vehicleProvider.vehicles.isNotEmpty) {
          existingVehicle = Map<String, dynamic>.from(
            vehicleProvider.vehicleInfo,
          );
        }
      }

      Navigator.of(context).pushReplacementNamed(
        AppRoutes.completeProfile,
        arguments: CompleteProfileArgs(
          lockedProfile: hasChosenProfile ? _appProfile : null,
          existingUser: context.read<UserProvider>().user,
          existingAddress: existingAddress,
          existingVehicle: existingVehicle,
        ),
      );
    } else {
      _redirectAfterLogin(context);
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
      final profile = await AuthService.instance.linkSocialAccount(
        email: linkRequest.email,
        password: password,
        pendingCredential: linkRequest.pendingCredential,
        useBackendProfile: _flags.backendAuth,
      );
      if (context.mounted) {
        if (_flags.backendAuth) {
          await _finishBackendLogin(context, accountPassword: password);
        } else {
          await _afterSocialLogin(context, profile);
        }
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
      final uid = AuthService.instance.currentUser!.uid;
      await AuthService.instance.completeSocialProfile(
        uid: uid,
        name: name,
        cpf: cpf,
        phone: phone,
      );
      _needsProfileCompletion = false;
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
      if (_flags.backendAuth) {
        return await _registerWithBackend(
          context: context,
          name: name,
          email: email,
          password: password,
          cpf: cpf,
          phone: phone,
          profile: AppProfile.client,
        );
      }
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
      if (_flags.backendAuth) {
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
      }
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
      if (_flags.backendAuth) {
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
      }
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

      await AuthService.instance.completePendingUserData(
        uid: uid,
        name: name,
        cpf: cpf,
        phone: phone,
      );

      if (addressData != null && context.mounted) {
        await context.read<AddressProvider>().add(
          uid,
          addressData.copyWith(isDefault: true),
        );
      }

      if (vehicleType != null && vehicleData != null) {
        await AuthService.instance.addVehicleForDeliveryPerson(
          uid: uid,
          vehicleType: vehicleType,
          vehicleData: vehicleData,
        );
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
    OrderStatusNotificationWatcher.instance.stop();

    final uid = AuthService.instance.currentUser?.uid;
    if (uid != null) {
      await NotificationService.instance.clearTokenForUser(uid);
    }

    if (_flags.backendAuth) {
      try {
        await _requireFederatedAuth().logout();
      } catch (_) {
        // Logout local e Firebase deve prosseguir mesmo se a API estiver indisponível.
      }
    }
    await AuthService.instance.logout();

    _isAuthenticated = false;
    _appProfile = null;
    _activeProfile = null;
    _errorMessage = null;
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
      if (_flags.backendAuth) {
        final idToken = await firebaseUser.getIdToken(true);
        if (idToken == null) throw StateError('Firebase ID token unavailable');
        final user = await _requireFederatedAuth().restore(idToken);
        if (!context.mounted) return;
        await _applyBackendUser(context, user);
        return;
      }
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
        await context.read<UserPreferencesProvider>().loadForUser(
          firebaseUser.uid,
        );
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

  FederatedAuthRepository _requireFederatedAuth() {
    final repository = _federatedAuth;
    if (repository == null) {
      throw StateError(
        'Backend authentication is enabled without a repository.',
      );
    }
    return repository;
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
        await AuthService.instance.addVehicleForDeliveryPerson(
          uid: firebaseUser.uid,
          vehicleType: vehicleType,
          vehicleData: vehicleData,
        );
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
    _appProfile = user.appProfile;
    _needsProfileCompletion = !user.profileComplete;
    notifyListeners();

    final uid = AuthService.instance.currentUser!.uid;
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
