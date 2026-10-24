import '../infra/http/api_client.dart';
import '../core/network/api_failure.dart';
import 'package:meatshop_mobile/core/auth/password_policy.dart';
import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:meatshop_mobile/core/exceptions/api_exception.dart';
import 'package:meatshop_mobile/core/exceptions/social_account_link_required_exception.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class AuthService {
  AuthService._();
  static final AuthService instance = AuthService._();

  ApiClient? _backend;
  void configure(ApiClient client) => _backend = client;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? get currentUser => _auth.currentUser;

  Future<String> login({
    required String email,
    required String password,
    bool loadFirestoreProfile = false,
  }) async {
    final backend = _backend;
    if (backend == null) throw StateError('Authentication backend unavailable');
    try {
      await backend.post(
        '/auth/mobile/password',
        authenticated: false,
        body: {'email': email.trim(), 'password': password},
        decode: (_) => true,
      );
    } on ApiFailure catch (error) {
      if (error.statusCode == 429) {
        throw FirebaseAuthException(code: 'too-many-requests');
      }
      if (error.statusCode == 401) {
        throw FirebaseAuthException(code: 'invalid-credential');
      }
      rethrow;
    }
    await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    return 'CLIENT';
  }

  Future<String> loginWithGoogle({bool useBackendProfile = true}) async {
    final googleUser = await GoogleSignIn().signIn();
    if (googleUser == null) throw ApiException('Login com Google cancelado.');
    final googleAuth = await googleUser.authentication;
    return _signInSocial(
      GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      ),
      googleUser.email,
    );
  }

  Future<String> loginWithApple({bool useBackendProfile = true}) async {
    final rawNonce = _generateNonce();
    final appleCredential = await SignInWithApple.getAppleIDCredential(
      scopes: const [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
      nonce: _sha256(rawNonce),
    );
    return _signInSocial(
      OAuthProvider(
        'apple.com',
      ).credential(idToken: appleCredential.identityToken, rawNonce: rawNonce),
      appleCredential.email,
    );
  }

  Future<String> _signInSocial(
    AuthCredential credential,
    String? fallbackEmail,
  ) async {
    try {
      await _auth.signInWithCredential(credential);
      return 'CLIENT';
    } on FirebaseAuthException catch (error) {
      if (error.code == 'account-exists-with-different-credential') {
        final email = error.email ?? fallbackEmail;
        if (email != null && email.isNotEmpty) {
          throw SocialAccountLinkRequiredException(
            email: email,
            pendingCredential: error.credential ?? credential,
          );
        }
      }
      rethrow;
    }
  }

  Future<String> linkSocialAccount({
    required String email,
    required String password,
    required AuthCredential pendingCredential,
    bool useBackendProfile = true,
  }) async {
    final user = (await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    )).user!;
    try {
      await user.linkWithCredential(pendingCredential);
    } on FirebaseAuthException catch (error) {
      if (error.code != 'provider-already-linked') rethrow;
    }
    return 'CLIENT';
  }

  Future<User> registerFirebaseIdentity({
    required String name,
    required String email,
    required String password,
  }) async {
    PasswordPolicy.validate(password);
    final user = (await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    )).user!;
    await user.updateDisplayName(name.trim());
    await user.sendEmailVerification();
    return user;
  }

  Future<void> logout() => _auth.signOut();

  Future<void> deleteCurrentUser() async {
    final user = _auth.currentUser;
    if (user == null) throw StateError('Usuário não autenticado.');
    await user.delete();
  }

  Future<void> sendPasswordResetEmail(String email) =>
      _auth.sendPasswordResetEmail(email: email.trim());

  Future<User> reauthenticate({required String password}) async {
    final user = _auth.currentUser;
    if (user == null || user.email == null) {
      throw StateError('Usuário não autenticado.');
    }
    final providers = user.providerData
        .map((value) => value.providerId)
        .toSet();
    if (providers.contains('password')) {
      await user.reauthenticateWithCredential(
        EmailAuthProvider.credential(email: user.email!, password: password),
      );
    } else if (providers.contains('google.com')) {
      final account = await GoogleSignIn().signIn();
      if (account == null) throw ApiException('Confirmação cancelada.');
      final tokens = await account.authentication;
      await user.reauthenticateWithCredential(
        GoogleAuthProvider.credential(
          accessToken: tokens.accessToken,
          idToken: tokens.idToken,
        ),
      );
    } else if (providers.contains('apple.com')) {
      final nonce = _generateNonce();
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: const [AppleIDAuthorizationScopes.email],
        nonce: _sha256(nonce),
      );
      await user.reauthenticateWithCredential(
        OAuthProvider(
          'apple.com',
        ).credential(idToken: credential.identityToken, rawNonce: nonce),
      );
    } else {
      throw ApiException('Entre novamente para confirmar sua identidade.');
    }
    return user;
  }

  bool get requiresPassword =>
      currentUser?.providerData.any((p) => p.providerId == 'password') ?? false;

  Future<void> requestEmailChange(
    String email, {
    required String password,
  }) async {
    final user = await reauthenticate(password: password);
    await user.verifyBeforeUpdateEmail(email.trim());
  }

  Future<void> changePassword({
    required String email,
    required String currentPassword,
    required String newPassword,
  }) async {
    PasswordPolicy.validate(newPassword);
    final user = _auth.currentUser;
    if (user == null) throw StateError('Usuário não autenticado.');
    await user.reauthenticateWithCredential(
      EmailAuthProvider.credential(
        email: email.trim(),
        password: currentPassword,
      ),
    );
    await user.updatePassword(newPassword);
  }

  String _generateNonce([int length = 32]) {
    const chars =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(
      length,
      (_) => chars[random.nextInt(chars.length)],
    ).join();
  }

  String _sha256(String value) => sha256.convert(utf8.encode(value)).toString();
}
