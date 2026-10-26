import '../../ui/dialogs/delete_account_dialog.dart';
import '../../data/repositories/legal_repository.dart';
import '../../ui/screens/account/legal_screen.dart';
import 'package:meatshop_mobile/services/vehicle_registration_service.dart';
import 'package:meatshop_mobile/services/registration_draft_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../delivery/delivery_provider.dart';
import '../../data/repositories/realtime_repository.dart';
import 'package:meatshop_mobile/core/enums/app_profile.dart';
import 'package:meatshop_mobile/core/exceptions/api_exception.dart';
import 'package:meatshop_mobile/core/exceptions/login_blocked_exception.dart';
import 'package:meatshop_mobile/core/exceptions/social_account_link_required_exception.dart';
import 'package:meatshop_mobile/core/utils/custom_snackbar.dart';
import 'package:meatshop_mobile/models/address_model.dart';
import 'package:meatshop_mobile/providers/cart_provider.dart';
import 'package:meatshop_mobile/providers/order_provider.dart';
import 'package:meatshop_mobile/providers/search_provider.dart';
import 'package:meatshop_mobile/providers/review_provider.dart';
import 'package:meatshop_mobile/providers/product_review_provider.dart';
import 'package:meatshop_mobile/providers/delivery/vehicle_provider.dart';
import 'package:meatshop_mobile/providers/delivery_earnings_provider.dart';
import 'package:meatshop_mobile/providers/unit/unit_provider.dart';
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
      if (e.code == 'too-many-requests') {
        if (context.mounted) {
          Navigator.of(context).pushNamed(AppRoutes.accountBlocked);
        }
        return;
      }
      _errorMessage = _mapAuthError(e.code);
      notifyListeners();

      if (context.mounted) {
        CustomDialog.showError(
          context: context,
          title: 'Erro ao entrar',
          message: _errorMessage!,
        );
      }
    } on ApiFailure catch (e) {
      _errorMessage = e.message;
      notifyListeners();

      if (context.mounted) {
        CustomDialog.showError(
          context: context,
          title: 'Erro ao entrar',
          message: _errorMessage!,
        );
      }
    } catch (e, stackTrace) {
      debugPrint('EMAIL LOGIN FAILURE: $e');
      debugPrintStack(stackTrace: stackTrace);
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
    List<int>? legalDocumentIds,
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
      if (context.mounted) {
        await context.read<UserProvider>().loadUser(uid);
      }
      notifyListeners();

      if (context.mounted) {
        _redirectAfterLogin(context);
      }
    } catch (e) {
      if (context.mounted) {
        CustomDialog.showError(
          context: context,
          title: 'Erro ao salvar dados',
          message: _completionErrorMessage(e),
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
      final uid = AuthService.instance.currentUser?.uid;
      if (uid != null && context.mounted) {
        await context.read<UserProvider>().loadUser(uid);
      }
      notifyListeners();

      if (context.mounted) {
        _redirectAfterLogin(context);
      }
    } catch (e) {
      if (context.mounted) {
        CustomDialog.showError(
          context: context,
          title: 'Erro ao salvar dados',
          message: _completionErrorMessage(e),
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
    List<int>? legalDocumentIds,
    VoidCallback? onEmailExists,
  }) async {
    _errorMessage = null;

    try {
      return await _registerWithBackend(
        legalDocumentIds: legalDocumentIds,
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
    List<int>? legalDocumentIds,
    VoidCallback? onEmailExists,
  }) async {
    _errorMessage = null;

    try {
      return await _registerWithBackend(
        legalDocumentIds: legalDocumentIds,
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
    List<int>? legalDocumentIds,
    VoidCallback? onEmailExists,
  }) async {
    _errorMessage = null;

    try {
      return await _registerWithBackend(
        legalDocumentIds: legalDocumentIds,
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
      _needsProfileCompletion = false;
      notifyListeners();
      return true;
    } catch (e) {
      if (context.mounted) {
        CustomDialog.showError(
          context: context,
          title: 'Erro ao salvar dados',
          message: _completionErrorMessage(e),
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
    final deliveryProvider = context.read<DeliveryProvider>();
    await deliveryProvider.clearSession();
    if (context.mounted) {
      context.read<BackendRealtimeAccess>().realtime?.disconnect();
    }
    final uid = AuthService.instance.currentUser?.uid;
    if (uid != null) {
      try {
        await NotificationService.instance.clearTokenForUser(uid);
      } catch (error) {
        debugPrint('[AuthProvider] notification cleanup failed: $error');
      }
    }

    try {
      await _requireFederatedAuth().logout();
    } catch (error) {
      debugPrint('[AuthProvider] backend logout failed: $error');
    }
    try {
      await AuthService.instance.logout();
    } catch (error) {
      debugPrint('[AuthProvider] Firebase logout failed: $error');
    }

    _resetAuthenticationState();

    if (context.mounted) {
      await _clearUserScopedState(context, deliveryAlreadyCleared: true);
      if (!context.mounted) return;
      Navigator.of(
        context,
      ).pushNamedAndRemoveUntil(AppRoutes.login, (route) => false);
    }
  }

  Future<void> expireSession(BuildContext context) async {
    if (!_isAuthenticated) return;
    _resetAuthenticationState();
    await _clearUserScopedState(context);
    try {
      await AuthService.instance.logout();
    } catch (_) {}
    if (context.mounted) {
      context.read<BackendRealtimeAccess>().realtime?.disconnect();
      Navigator.of(
        context,
      ).pushNamedAndRemoveUntil(AppRoutes.login, (_) => false);
    }
  }

  Future<void> restoreSession(BuildContext context, User firebaseUser) async {
    try {
      final idToken = await firebaseUser.getIdToken(true);
      if (idToken == null) throw StateError('Firebase ID token unavailable');
      final user = await _requireFederatedAuth().restore(idToken);
      if (!context.mounted) return;
      await _applyBackendUser(context, user);
    } catch (error) {
      final definitive =
          error is ApiFailure &&
              {
                ApiFailureKind.unauthorized,
                ApiFailureKind.forbidden,
              }.contains(error.kind) ||
          error is FirebaseAuthException &&
              {
                'user-disabled',
                'user-token-expired',
                'invalid-user-token',
              }.contains(error.code);
      if (!definitive) rethrow;
      try {
        await _requireFederatedAuth().logout();
      } catch (_) {}
      try {
        await AuthService.instance.logout();
      } catch (_) {}
      _resetAuthenticationState();
      if (context.mounted) {
        await _clearUserScopedState(context);
        if (!context.mounted) return;
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
    List<int>? legalDocumentIds,
    String? vehicleType,
    Map<String, dynamic>? vehicleData,
  }) async {
    final firebaseUser = await AuthService.instance.registerFirebaseIdentity(
      name: name,
      email: email,
      password: password,
    );

    await RegistrationDraftService.save(firebaseUser.uid, {
      'name': name,
      'cpf': cpf,
      'phone': phone,
      'profile': profile.name,
      'legalDocumentIds': legalDocumentIds,
      'vehicleType': vehicleType,
      'vehicle': vehicleData,
    });
    if (!firebaseUser.emailVerified) {
      await AuthService.instance.logout();
      if (context.mounted) {
        CustomDialog.showSuccess(
          context: context,
          title: 'Verifique seu e-mail',
          message:
              'Enviamos um link de verificação. Confirme seu e-mail e faça login para concluir o cadastro.',
          onDismiss: () =>
              Navigator.of(context).pushReplacementNamed(AppRoutes.login),
        );
      }
      return true;
    }

    final idToken = await firebaseUser.getIdToken(true);
    if (idToken == null) throw StateError('Firebase ID token unavailable');

    final repository = _requireFederatedAuth();
    try {
      await repository.exchangeFirebaseToken(idToken);
      if (!context.mounted || !await _ensureLegalAcceptance(context)) {
        await _discardFailedAuthentication();
        return false;
      }
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
      } catch (_) {}
      await AuthService.instance.logout();
      rethrow;
    }

    await RegistrationDraftService.clear(firebaseUser.uid);
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

  Future<void> _registerBackendVehicle(
    String vehicleType,
    Map<String, dynamic> vehicleData,
  ) => VehicleRegistrationService(_delivery).register(vehicleType, vehicleData);

  Future<BackendAuthUser> _restoreDraft(
    String uid,
    BackendAuthUser user,
  ) async {
    final draft = await RegistrationDraftService.read(uid);
    if (draft == null) return user;
    final restored = await _requireFederatedAuth().completeProfile(
      name: '${draft['name']}',
      cpf: '${draft['cpf']}',
      phone: '${draft['phone']}',
      appProfile: AppProfile.fromString('${draft['profile']}'),
    );
    if (draft['vehicle'] is Map && draft['vehicleType'] != null) {
      await VehicleRegistrationService(_delivery).register(
        '${draft['vehicleType']}',
        Map<String, dynamic>.from(draft['vehicle'] as Map),
        photos: List<String>.from(draft['photos'] as List? ?? const []),
      );
    }
    await RegistrationDraftService.clear(uid);
    return restored;
  }

  String _completionErrorMessage(Object error) {
    if (error is ApiFailure) return error.message;
    if (error is ApiException) return error.message;
    return 'Não foi possível salvar seus dados. Tente novamente.';
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
      if (failure.code != 'ACCOUNT_LINK_REQUIRED' || !context.mounted) {
        await _discardFailedAuthentication();
        rethrow;
      }
      final password = await LinkSocialAccountDialog.show(
        context,
        email: firebaseUser.email ?? '',
      );
      if (password == null || !context.mounted) {
        await _discardFailedAuthentication();
        return;
      }
      try {
        final user = await _requireFederatedAuth().exchangeFirebaseToken(
          idToken,
          accountPassword: password,
        );
        if (context.mounted) await _applyBackendUser(context, user);
      } catch (_) {
        await _discardFailedAuthentication();
        rethrow;
      }
    } catch (_) {
      await _discardFailedAuthentication();
      rethrow;
    }
  }

  Future<void> _discardFailedAuthentication() async {
    try {
      await _requireFederatedAuth().logout();
    } catch (_) {}
    try {
      await AuthService.instance.logout();
    } catch (_) {}
    _resetAuthenticationState();
  }

  Future<void> reviewLegalRequirements(BuildContext context) async {
    if (!_isAuthenticated) return;
    try {
      if (!await _ensureLegalAcceptance(context) && context.mounted) {
        await logout(context);
      }
    } catch (_) {
      if (context.mounted) {
        CustomDialog.showError(
          context: context,
          title: 'Termos e privacidade',
          message: 'Não foi possível verificar os documentos. Tente novamente.',
        );
      }
    }
  }

  Future<void> _deletePendingAccount(BuildContext context) async {
    final password = await DeleteAccountDialog.show(context);
    if (password != null && context.mounted) {
      await deleteAccount(context: context, password: password);
    }
  }

  Future<bool> _ensureLegalAcceptance(BuildContext context) async {
    final repository = context.read<LegalRepository>();
    final pending = await repository.pending();
    if (!pending.enforced || pending.documents.isEmpty) return true;
    final uid = AuthService.instance.currentUser!.uid;
    final draft = await RegistrationDraftService.read(uid);
    final ids = (draft?['legalDocumentIds'] as List?)?.cast<int>();
    if (ids != null) {
      try {
        await repository.accept(ids);
        return true;
      } on ApiFailure catch (failure) {
        if (failure.code != 'LEGAL_DOCUMENTS_CHANGED') rethrow;
      }
    }
    if (!context.mounted) return false;
    final accepted = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => LegalScreen(
          requiredAcceptance: true,
          onDeleteAccount: () => _deletePendingAccount(context),
        ),
      ),
    );
    return accepted == true;
  }

  Future<void> _applyBackendUser(
    BuildContext context,
    BackendAuthUser user,
  ) async {
    if (!await _ensureLegalAcceptance(context)) {
      await _discardFailedAuthentication();
      if (context.mounted) {
        Navigator.of(context).pushReplacementNamed(AppRoutes.login);
      }
      return;
    }
    if (!context.mounted) return;
    await _clearUserScopedState(context);
    if (!context.mounted) return;
    _isAuthenticated = true;
    _backendUserId = user.id;
    _appProfile = user.appProfile;

    final uid = AuthService.instance.currentUser!.uid;
    final userProvider = context.read<UserProvider>();
    var backendUser = user;
    try {
      backendUser = await _restoreDraft(uid, user);
    } on ApiFailure catch (failure) {
      if (!{
        ApiFailureKind.validation,
        ApiFailureKind.conflict,
      }.contains(failure.kind)) {
        rethrow;
      }
      await RegistrationDraftService.clear(uid);
      _needsProfileCompletion = true;
      notifyListeners();
      if (context.mounted) {
        Navigator.of(context).pushReplacementNamed(AppRoutes.completeProfile);
      }
      return;
    }
    _appProfile = backendUser.appProfile;
    if (!context.mounted) return;
    await userProvider.loadUser(uid);
    if (!context.mounted) return;
    final profile = userProvider.user;
    if (!backendUser.profileComplete &&
        backendUser.appProfile != null &&
        profile != null &&
        profile.name.trim().isNotEmpty &&
        profile.cpf.trim().isNotEmpty &&
        profile.phone.trim().isNotEmpty) {
      backendUser = await _requireFederatedAuth().completeProfile(
        name: profile.name,
        cpf: profile.cpf,
        phone: profile.phone,
        appProfile: backendUser.appProfile!,
      );
      _appProfile = backendUser.appProfile;
    }
    if (!context.mounted) return;

    _needsProfileCompletion = !backendUser.profileComplete;
    notifyListeners();

    if (_needsProfileCompletion) {
      Navigator.of(context).pushReplacementNamed(
        AppRoutes.completeProfile,
        arguments: const CompleteProfileArgs(),
      );
      return;
    }

    try {
      await NotificationService.instance.saveTokenForUser(uid);
    } catch (_) {}
    if (!context.mounted) return;
    await context.read<UserPreferencesProvider>().loadForUser(uid);
    if (!context.mounted) return;
    // Card entry and saved cards are managed inside Mercado Pago Checkout Pro.
    _redirectAfterLogin(context);
  }

  void _resetAuthenticationState() {
    _isAuthenticated = false;
    _appProfile = null;
    _activeProfile = null;
    _needsProfileCompletion = false;
    _errorMessage = null;
    _backendUserId = null;
    notifyListeners();
  }

  Future<void> _clearUserScopedState(
    BuildContext context, {
    bool deliveryAlreadyCleared = false,
  }) async {
    context.read<UserProvider>().clear();
    context.read<UserPreferencesProvider>().clear();
    context.read<AddressProvider>().clear();
    context.read<VehicleProvider>().clear();
    context.read<CartProvider>().clearLocal();
    context.read<OrderProvider>().clear();
    context.read<DeliveryEarningsProvider>().clear();
    context.read<SearchProvider>().clear();
    context.read<ReviewProvider>().reset();
    context.read<ProductReviewProvider>().reset();
    context.read<UnitProvider>().clearSession();
    if (!deliveryAlreadyCleared) {
      await context.read<DeliveryProvider>().clearSession();
    }
  }

  void setClientMode() {
    _activeProfile = AppProfile.client;
    notifyListeners();
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
      final identity = await AuthService.instance.reauthenticate(
        password: password,
      );
      final identityToken = await identity.getIdToken(true);
      if (identityToken == null) throw StateError('Identity unavailable');
      final uid = AuthService.instance.currentUser?.uid;
      if (!context.mounted) return;
      await context.read<DeliveryProvider>().clearSession();
      if (!context.mounted) return;
      context.read<BackendRealtimeAccess>().realtime?.disconnect();
      if (uid != null) {
        try {
          await NotificationService.instance.clearTokenForUser(uid);
        } catch (error) {
          debugPrint('[AuthProvider] notification cleanup failed: $error');
        }
      }
      await _federatedAuth.deleteAccount(firebaseIdToken: identityToken);
      if (uid != null) await RegistrationDraftService.clear(uid);
      await AuthService.instance.logout();

      _resetAuthenticationState();

      if (context.mounted) {
        await _clearUserScopedState(context, deliveryAlreadyCleared: true);
        if (!context.mounted) return;
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
        notifyListeners();
        Navigator.of(context).pushReplacementNamed(AppRoutes.shell);
      case AppProfile.delivery:
        _activeProfile = AppProfile.delivery;
        notifyListeners();
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
