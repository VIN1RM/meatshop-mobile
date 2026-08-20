import 'package:firebase_auth/firebase_auth.dart';

class SocialAccountLinkRequiredException implements Exception {
  const SocialAccountLinkRequiredException({
    required this.email,
    required this.pendingCredential,
  });

  final String email;
  final AuthCredential pendingCredential;
}
