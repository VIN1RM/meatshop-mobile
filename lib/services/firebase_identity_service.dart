import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:meatshop_mobile/core/exceptions/api_exception.dart';
import 'package:meatshop_mobile/core/exceptions/social_account_link_required_exception.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

/// Firebase adapter restricted to primary identity operations.
class AuthService {
  AuthService._();
  static final AuthService instance = AuthService._();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? get currentUser => _auth.currentUser;

  Future<String> login({
    required String email,
    required String password,
    bool loadFirestoreProfile = false,
  }) async {
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
    final user = (await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    )).user!;
    await user.updateDisplayName(name.trim());
    return user;
  }

  Future<void> logout() => _auth.signOut();

  Future<void> sendPasswordResetEmail(String email) =>
      _auth.sendPasswordResetEmail(email: email.trim());

  Future<User> reauthenticate({required String password}) async {
    final user = _auth.currentUser;
    if (user == null || user.email == null) {
      throw StateError('Usuário não autenticado.');
    }
    await user.reauthenticateWithCredential(
      EmailAuthProvider.credential(email: user.email!, password: password),
    );
    return user;
  }

  Future<void> deleteCurrentIdentity() async => _auth.currentUser?.delete();

  Future<void> changePassword({
    required String email,
    required String currentPassword,
    required String newPassword,
  }) async {
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
