import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:meatshop_mobile/core/enums/app_profile.dart';
import 'package:meatshop_mobile/core/exceptions/api_exception.dart';
import 'package:meatshop_mobile/core/exceptions/social_account_link_required_exception.dart';
import 'package:meatshop_mobile/core/firebase/firestore_collections.dart';
import 'package:meatshop_mobile/services/login_attempts_service.dart';
import 'dart:io';
import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class AuthService {
  AuthService._();
  static final AuthService instance = AuthService._();

  final _auth = FirebaseAuth.instance;
  final _db = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;

  Future<String> login({
    required String email,
    required String password,
    bool loadFirestoreProfile = true,
  }) async {
    await LoginAttemptsService.instance.guardLogin(email);

    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      await LoginAttemptsService.instance.clearAttempts(email);

      if (!loadFirestoreProfile) return 'CLIENT';

      final doc = await _db
          .collection(FirestoreCollections.users)
          .doc(credential.user!.uid)
          .get();

      return doc.data()?['app_profile'] as String? ?? 'CLIENT';
    } on FirebaseAuthException catch (e) {
      if (_isInvalidCredentialError(e.code)) {
        await LoginAttemptsService.instance.registerFailedAttempt(email);
      }
      rethrow;
    }
  }

  Future<String> loginWithGoogle({bool useBackendProfile = false}) async {
    final googleUser = await GoogleSignIn().signIn();
    if (googleUser == null) {
      throw ApiException('Login com Google cancelado.');
    }

    final googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    return _signInWithSocialCredential(
      credential,
      fallbackEmail: googleUser.email,
      fallbackName: googleUser.displayName,
      useBackendProfile: useBackendProfile,
    );
  }

  Future<String> loginWithApple({bool useBackendProfile = false}) async {
    final rawNonce = _generateNonce();
    final nonce = _sha256ofString(rawNonce);

    final appleCredential = await SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
      nonce: nonce,
    );

    final oauthCredential = OAuthProvider(
      'apple.com',
    ).credential(idToken: appleCredential.identityToken, rawNonce: rawNonce);

    final fallbackName = [
      appleCredential.givenName,
      appleCredential.familyName,
    ].where((s) => s != null && s.isNotEmpty).join(' ');

    return _signInWithSocialCredential(
      oauthCredential,
      fallbackEmail: appleCredential.email,
      fallbackName: fallbackName.isEmpty ? null : fallbackName,
      useBackendProfile: useBackendProfile,
    );
  }

  Future<String> _signInWithSocialCredential(
    AuthCredential credential, {
    String? fallbackEmail,
    String? fallbackName,
    bool useBackendProfile = false,
  }) async {
    if (!useBackendProfile &&
        fallbackEmail != null &&
        await _requiresAccountLinkBeforeSignIn(
          email: fallbackEmail,
          providerId: credential.providerId,
        )) {
      throw SocialAccountLinkRequiredException(
        email: fallbackEmail,
        pendingCredential: credential,
      );
    }

    try {
      final userCredential = await _auth.signInWithCredential(credential);
      final user = userCredential.user!;

      if (useBackendProfile) return 'CLIENT';

      await _preventDuplicateSocialAccount(
        user: user,
        pendingCredential: credential,
        fallbackEmail: fallbackEmail,
      );

      return _handleSocialUser(user, fallbackName: fallbackName);
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

  Future<bool> _requiresAccountLinkBeforeSignIn({
    required String email,
    required String providerId,
  }) async {
    final existingUid = await _findExistingUidForEmail(
      email: email,
      currentUid: '',
    );
    if (existingUid == null) return false;

    // O SDK ainda oferece este método para resolver o primeiro vínculo.
    // ignore: deprecated_member_use
    final signInMethods = await _auth.fetchSignInMethodsForEmail(email.trim());
    return signInMethods.contains('password') &&
        !signInMethods.contains(providerId);
  }

  Future<void> _preventDuplicateSocialAccount({
    required User user,
    required AuthCredential pendingCredential,
    String? fallbackEmail,
  }) async {
    final email = user.email ?? fallbackEmail;
    if (email == null || email.isEmpty) return;

    final existingUid = await _findExistingUidForEmail(
      email: email,
      currentUid: user.uid,
    );
    if (existingUid == null) return;

    final duplicateRef = _db
        .collection(FirestoreCollections.users)
        .doc(user.uid);
    final duplicateDoc = await duplicateRef.get();
    final duplicateData = duplicateDoc.data();

    if (duplicateData != null && !_isIncompleteSocialProfile(duplicateData)) {
      await _auth.signOut();
      throw ApiException(
        'Encontramos duas contas em uso com este e-mail. Entre com e-mail e '
        'senha e fale com o suporte para unificar os dados.',
      );
    }

    try {
      if (duplicateDoc.exists) {
        await duplicateRef.delete();
      }
      await user.delete();
    } catch (_) {
      await _auth.signOut();
      throw ApiException(
        'Não foi possível vincular esta conta automaticamente. Entre com '
        'e-mail e senha e tente novamente.',
      );
    }

    throw SocialAccountLinkRequiredException(
      email: email,
      pendingCredential: pendingCredential,
    );
  }

  Future<String?> _findExistingUidForEmail({
    required String email,
    required String currentUid,
  }) async {
    final normalizedEmail = email.trim().toLowerCase();
    final candidates = <String>{email.trim(), normalizedEmail};

    for (final candidate in candidates) {
      final uniqueEmail = await _db
          .collection('unique_emails')
          .doc(candidate)
          .get();
      final uid = uniqueEmail.data()?['user_id'] as String?;
      if (uid != null && uid.isNotEmpty && uid != currentUid) return uid;
    }

    return null;
  }

  bool _isIncompleteSocialProfile(Map<String, dynamic> data) {
    return data['profile_complete'] != true &&
        (data['cpf'] as String? ?? '').isEmpty &&
        (data['phone'] as String? ?? '').isEmpty;
  }

  Future<String> linkSocialAccount({
    required String email,
    required String password,
    required AuthCredential pendingCredential,
    bool useBackendProfile = false,
  }) async {
    try {
      await LoginAttemptsService.instance.guardLogin(email);
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final user = userCredential.user!;

      await user.linkWithCredential(pendingCredential);
      await LoginAttemptsService.instance.clearAttempts(email);
      if (useBackendProfile) return 'CLIENT';
      return _handleSocialUser(user);
    } on FirebaseAuthException catch (error) {
      if (error.code == 'provider-already-linked') {
        final user = _auth.currentUser!;
        await LoginAttemptsService.instance.clearAttempts(email);
        if (useBackendProfile) return 'CLIENT';
        return _handleSocialUser(user);
      }
      if (_isInvalidCredentialError(error.code)) {
        await LoginAttemptsService.instance.registerFailedAttempt(email);
      }
      rethrow;
    }
  }

  Future<String> _handleSocialUser(User user, {String? fallbackName}) async {
    final docRef = _db.collection(FirestoreCollections.users).doc(user.uid);
    final doc = await docRef.get();

    if (!doc.exists) {
      await docRef.set({
        'name': fallbackName ?? user.displayName ?? '',
        'email': user.email ?? '',
        'cpf': '',
        'phone': user.phoneNumber ?? '',
        'global_role': 'USER',
        'app_profile': 'CLIENT',
        'profile_complete': false,
        'created_at': FieldValue.serverTimestamp(),
      });
      return 'CLIENT';
    }

    return doc.data()?['app_profile'] as String? ?? 'CLIENT';
  }

  Future<bool> isSocialProfileComplete(String uid) async {
    final doc = await _db.collection(FirestoreCollections.users).doc(uid).get();
    final data = doc.data();
    if (data == null) return false;
    return data['profile_complete'] == true ||
        (data['cpf'] as String?)?.isNotEmpty == true;
  }

  Future<bool> hasChosenProfile(String uid) async {
    final doc = await _db.collection(FirestoreCollections.users).doc(uid).get();
    final data = doc.data();
    return data != null &&
        data['app_profile'] != null &&
        data['profile_complete'] != false;
  }

  Future<void> completeSocialProfile({
    required String uid,
    required String name,
    required String cpf,
    required String phone,
  }) async {
    await _checkUniqueFields(cpf: cpf.trim(), phone: phone.trim());

    await _db.collection(FirestoreCollections.users).doc(uid).update({
      'name': name.trim(),
      'cpf': cpf.trim(),
      'phone': phone.trim(),
      'profile_complete': true,
    });

    await _registerUniqueFields(
      uid: uid,
      cpf: cpf.trim(),
      phone: phone.trim(),
      email: _auth.currentUser?.email ?? '',
    );
  }

  String _generateNonce([int length = 32]) {
    const charset =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(
      length,
      (_) => charset[random.nextInt(charset.length)],
    ).join();
  }

  String _sha256ofString(String input) {
    final bytes = utf8.encode(input);
    return sha256.convert(bytes).toString();
  }

  bool _isInvalidCredentialError(String code) {
    return code == 'wrong-password' ||
        code == 'user-not-found' ||
        code == 'invalid-credential';
  }

  Future<User> registerFirebaseIdentity({
    required String name,
    required String email,
    required String password,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    final user = credential.user!;
    await user.updateDisplayName(name.trim());
    return user;
  }

  Future<String> registerClient({
    required String name,
    required String email,
    required String password,
    required String cpf,
    required String phone,
  }) async {
    await _checkUniqueFields(cpf: cpf.trim(), phone: phone.trim());

    final credential = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    await _db
        .collection(FirestoreCollections.users)
        .doc(credential.user!.uid)
        .set({
          'name': name.trim(),
          'email': email.trim(),
          'cpf': cpf.trim(),
          'phone': phone.trim(),
          'global_role': 'USER',
          'app_profile': 'CLIENT',
          'created_at': FieldValue.serverTimestamp(),
        });

    await _registerUniqueFields(
      uid: credential.user!.uid,
      cpf: cpf.trim(),
      phone: phone.trim(),
      email: email.trim(),
    );

    return 'CLIENT';
  }

  Future<void> completeSocialProfileWithVehicle({
    required String uid,
    required String name,
    required String cpf,
    required String phone,
    required AppProfile appProfile,
    required String vehicleType,
    required Map<String, dynamic> vehicleData,
  }) async {
    await _checkUniqueFields(cpf: cpf.trim(), phone: phone.trim());

    await _db.collection(FirestoreCollections.users).doc(uid).update({
      'name': name.trim(),
      'cpf': cpf.trim(),
      'phone': phone.trim(),
      'profile_complete': true,
      'app_profile': appProfile == AppProfile.both ? 'BOTH' : 'DELIVERY',
    });

    await _registerUniqueFields(
      uid: uid,
      cpf: cpf.trim(),
      phone: phone.trim(),
      email: _auth.currentUser?.email ?? '',
    );

    await _db.collection(FirestoreCollections.deliveryPersons).doc(uid).set({
      'user_id': uid,
      'status': 'PENDING',
      'average_rating': 0.0,
      'created_at': FieldValue.serverTimestamp(),
    });

    final photoUrls = await _uploadVehicleImages(
      uid,
      List<File>.from(vehicleData['newImages'] ?? []),
    );

    await _db
        .collection(FirestoreCollections.deliveryPersons)
        .doc(uid)
        .collection(FirestoreCollections.vehicles)
        .add({
          'type': vehicleType,
          'model': vehicleData['model'] ?? '',
          'plate': vehicleData['plate'] ?? '',
          'color': vehicleData['color'] ?? '',
          'year': vehicleData['year'] ?? '',
          'photo_urls': photoUrls,
          'is_active': true,
          'created_at': FieldValue.serverTimestamp(),
        });
  }

  Future<String> registerDelivery({
    required String name,
    required String email,
    required String password,
    required String cpf,
    required String phone,
    required String vehicleType,
    required Map<String, dynamic> vehicleData,
  }) async {
    await _checkUniqueFields(cpf: cpf.trim(), phone: phone.trim());

    final credential = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    final uid = credential.user!.uid;

    await _db.collection(FirestoreCollections.users).doc(uid).set({
      'name': name.trim(),
      'email': email.trim(),
      'cpf': cpf.trim(),
      'phone': phone.trim(),
      'global_role': 'USER',
      'app_profile': 'DELIVERY',
      'created_at': FieldValue.serverTimestamp(),
    });

    await _registerUniqueFields(
      uid: uid,
      cpf: cpf.trim(),
      phone: phone.trim(),
      email: _auth.currentUser?.email ?? '',
    );

    await _db.collection(FirestoreCollections.deliveryPersons).doc(uid).set({
      'user_id': uid,
      'status': 'PENDING',
      'average_rating': 0.0,
      'created_at': FieldValue.serverTimestamp(),
    });

    final photoUrls = await _uploadVehicleImages(
      uid,
      List<File>.from(vehicleData['newImages'] ?? []),
    );

    await _db
        .collection(FirestoreCollections.deliveryPersons)
        .doc(uid)
        .collection(FirestoreCollections.vehicles)
        .add({
          'type': vehicleType,
          'model': vehicleData['model'] ?? '',
          'plate': vehicleData['plate'] ?? '',
          'color': vehicleData['color'] ?? '',
          'year': vehicleData['year'] ?? '',
          'photo_urls': photoUrls,
          'is_active': true,
          'created_at': FieldValue.serverTimestamp(),
        });

    return 'DELIVERY';
  }

  Future<void> logout() async {
    await _auth.signOut();
  }

  Future<void> sendPasswordResetEmail(String email) async {
    await _auth.sendPasswordResetEmail(email: email.trim());
  }

  Future<String> registerBoth({
    required String name,
    required String email,
    required String password,
    required String cpf,
    required String phone,
    required String vehicleType,
    required Map<String, dynamic> vehicleData,
  }) async {
    await _checkUniqueFields(cpf: cpf.trim(), phone: phone.trim());

    final credential = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    final uid = credential.user!.uid;

    await _db.collection(FirestoreCollections.users).doc(uid).set({
      'name': name.trim(),
      'email': email.trim(),
      'cpf': cpf.trim(),
      'phone': phone.trim(),
      'global_role': 'USER',
      'app_profile': 'BOTH',
      'created_at': FieldValue.serverTimestamp(),
    });

    await _registerUniqueFields(
      uid: uid,
      cpf: cpf.trim(),
      phone: phone.trim(),
      email: email.trim(),
    );

    await _db.collection(FirestoreCollections.deliveryPersons).doc(uid).set({
      'user_id': uid,
      'status': 'PENDING',
      'average_rating': 0.0,
      'created_at': FieldValue.serverTimestamp(),
    });

    final photoUrls = await _uploadVehicleImages(
      uid,
      List<File>.from(vehicleData['newImages'] ?? []),
    );

    await _db
        .collection(FirestoreCollections.deliveryPersons)
        .doc(uid)
        .collection(FirestoreCollections.vehicles)
        .add({
          'type': vehicleType,
          'model': vehicleData['model'] ?? '',
          'plate': vehicleData['plate'] ?? '',
          'color': vehicleData['color'] ?? '',
          'year': vehicleData['year'] ?? '',
          'photo_urls': photoUrls,
          'is_active': true,
          'created_at': FieldValue.serverTimestamp(),
        });

    return 'BOTH';
  }

  Future<void> completePendingUserData({
    required String uid,
    required String name,
    required String cpf,
    required String phone,
  }) async {
    final doc = await _db.collection(FirestoreCollections.users).doc(uid).get();
    final data = doc.data() ?? {};

    final currentCpf = (data['cpf'] as String? ?? '').trim();
    final currentPhone = (data['phone'] as String? ?? '').trim();

    if (currentCpf.isEmpty && cpf.trim().isNotEmpty) {
      final cpfDoc = await _db.collection('unique_cpfs').doc(cpf.trim()).get();
      if (cpfDoc.exists) {
        throw ApiException('Este CPF já está sendo utilizado por outra conta.');
      }
      await _db.collection('unique_cpfs').doc(cpf.trim()).set({'user_id': uid});
    }

    if (currentPhone.isEmpty && phone.trim().isNotEmpty) {
      final phoneDoc = await _db
          .collection('unique_phones')
          .doc(phone.trim())
          .get();
      if (phoneDoc.exists) {
        throw ApiException(
          'Este número de celular já está sendo utilizado por outra conta.',
        );
      }
      await _db.collection('unique_phones').doc(phone.trim()).set({
        'user_id': uid,
      });
    }

    await _db.collection(FirestoreCollections.users).doc(uid).update({
      'name': name.trim(),
      if (cpf.trim().isNotEmpty) 'cpf': cpf.trim(),
      if (phone.trim().isNotEmpty) 'phone': phone.trim(),
    });
  }

  Future<void> addVehicleForDeliveryPerson({
    required String uid,
    required String vehicleType,
    required Map<String, dynamic> vehicleData,
  }) async {
    final dpDoc = await _db
        .collection(FirestoreCollections.deliveryPersons)
        .doc(uid)
        .get();
    if (!dpDoc.exists) {
      await _db.collection(FirestoreCollections.deliveryPersons).doc(uid).set({
        'user_id': uid,
        'status': 'PENDING',
        'average_rating': 0.0,
        'created_at': FieldValue.serverTimestamp(),
      });
    }

    final photoUrls = await _uploadVehicleImages(
      uid,
      List<File>.from(vehicleData['newImages'] ?? []),
    );

    await _db
        .collection(FirestoreCollections.deliveryPersons)
        .doc(uid)
        .collection(FirestoreCollections.vehicles)
        .add({
          'type': vehicleType,
          'model': vehicleData['model'] ?? '',
          'plate': vehicleData['plate'] ?? '',
          'color': vehicleData['color'] ?? '',
          'year': vehicleData['year'] ?? '',
          'photo_urls': photoUrls,
          'is_active': true,
          'created_at': FieldValue.serverTimestamp(),
        });
  }

  Future<void> deleteAccount({required String password}) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Usuário não autenticado.');
    final credential = EmailAuthProvider.credential(
      email: user.email!,
      password: password,
    );
    await user.reauthenticateWithCredential(credential);
    await _db.collection(FirestoreCollections.users).doc(user.uid).delete();
    await user.delete();
  }

  Future<void> changePassword({
    required String email,
    required String currentPassword,
    required String newPassword,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Usuário não autenticado.');

    final credential = EmailAuthProvider.credential(
      email: email.trim(),
      password: currentPassword,
    );
    await user.reauthenticateWithCredential(credential);
    await user.updatePassword(newPassword);
  }

  Future<void> _checkUniqueFields({
    required String cpf,
    required String phone,
  }) async {
    final cpfDoc = await _db.collection('unique_cpfs').doc(cpf).get();
    if (cpfDoc.exists) {
      throw ApiException('Este CPF já está sendo utilizado por outra conta.');
    }

    final phoneDoc = await _db.collection('unique_phones').doc(phone).get();
    if (phoneDoc.exists) {
      throw ApiException(
        'Este número de celular já está sendo utilizado por outra conta.',
      );
    }
  }

  Future<void> _registerUniqueFields({
    required String uid,
    required String cpf,
    required String phone,
    required String email,
  }) async {
    final batch = _db.batch();
    batch.set(_db.collection('unique_cpfs').doc(cpf), {'user_id': uid});
    batch.set(_db.collection('unique_phones').doc(phone), {'user_id': uid});
    batch.set(_db.collection('unique_emails').doc(email), {'user_id': uid});
    await batch.commit();
  }

  Future<List<String>> _uploadVehicleImages(
    String uid,
    List<File> files,
  ) async {
    final urls = <String>[];
    for (final file in files) {
      final bytes = await file.readAsBytes();
      final base64Str = base64Encode(bytes);
      urls.add('data:image/jpeg;base64,$base64Str');
    }
    return urls;
  }

  Future<bool> isCpfAvailable(String cpf) async {
    final doc = await _db.collection('unique_cpfs').doc(cpf.trim()).get();
    return !doc.exists;
  }

  Future<bool> isPhoneAvailable(String phone) async {
    final doc = await _db.collection('unique_phones').doc(phone.trim()).get();
    return !doc.exists;
  }

  Future<bool> isEmailAvailable(String email) async {
    final doc = await _db.collection('unique_emails').doc(email.trim()).get();
    return !doc.exists;
  }

  Future<String?> findDuplicateField({
    required String cpf,
    required String email,
    required String phone,
  }) async {
    if (!await isCpfAvailable(cpf)) return 'cpf';
    if (!await isEmailAvailable(email)) return 'email';
    if (!await isPhoneAvailable(phone)) return 'phone';
    return null;
  }
}
