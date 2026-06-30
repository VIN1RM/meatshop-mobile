import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:meatshop_mobile/core/enums/app_profile.dart';
import 'package:meatshop_mobile/core/exceptions/api_exception.dart';
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
  }) async {
    await LoginAttemptsService.instance.guardLogin(email);

    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      await LoginAttemptsService.instance.clearAttempts(email);

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

  Future<String> loginWithGoogle() async {
    final googleUser = await GoogleSignIn().signIn();
    if (googleUser == null) {
      throw ApiException('Login com Google cancelado.');
    }

    final googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final userCredential = await _auth.signInWithCredential(credential);
    return _handleSocialUser(
      userCredential.user!,
      fallbackName: googleUser.displayName,
    );
  }

  Future<String> loginWithApple() async {
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

    final userCredential = await _auth.signInWithCredential(oauthCredential);

    final fallbackName = [
      appleCredential.givenName,
      appleCredential.familyName,
    ].where((s) => s != null && s.isNotEmpty).join(' ');

    return _handleSocialUser(
      userCredential.user!,
      fallbackName: fallbackName.isEmpty ? null : fallbackName,
    );
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

  Future<void> completeSocialProfile({
    required String uid,
    required String cpf,
    required String phone,
  }) async {
    await _checkUniqueFields(cpf: cpf.trim(), phone: phone.trim());

    await _db.collection(FirestoreCollections.users).doc(uid).update({
      'cpf': cpf.trim(),
      'phone': phone.trim(),
      'profile_complete': true,
    });

    await _registerUniqueFields(uid: uid, cpf: cpf.trim(), phone: phone.trim());
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
    );

    return 'CLIENT';
  }

  Future<void> completeSocialProfileWithVehicle({
    required String uid,
    required String cpf,
    required String phone,
    required AppProfile appProfile,
    required String vehicleType,
    required Map<String, dynamic> vehicleData,
  }) async {
    await _checkUniqueFields(cpf: cpf.trim(), phone: phone.trim());

    await _db.collection(FirestoreCollections.users).doc(uid).update({
      'cpf': cpf.trim(),
      'phone': phone.trim(),
      'profile_complete': true,
      'app_profile': appProfile == AppProfile.both ? 'BOTH' : 'DELIVERY',
    });

    await _registerUniqueFields(uid: uid, cpf: cpf.trim(), phone: phone.trim());

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

    await _registerUniqueFields(uid: uid, cpf: cpf.trim(), phone: phone.trim());

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

    await _registerUniqueFields(uid: uid, cpf: cpf.trim(), phone: phone.trim());

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
  }) async {
    final batch = _db.batch();
    batch.set(_db.collection('unique_cpfs').doc(cpf), {'user_id': uid});
    batch.set(_db.collection('unique_phones').doc(phone), {'user_id': uid});
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
}
