import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:http/http.dart' as http;
import '../../../core/constants/app_config.dart';

final authControllerProvider = Provider<AuthController>((ref) {
  return AuthController(ref);
});

class AuthController {
  final Ref ref;
  AuthController(this.ref);

  final _googleSignIn = GoogleSignIn(scopes: ['email', 'profile']);

  Future<void> signInWithGoogle() async {
    final googleUser = await _googleSignIn.signIn();
    if (googleUser == null) return; // user canceled
    final googleAuth = await googleUser.authentication;
    final credential = fb.GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    final cred = await fb.FirebaseAuth.instance.signInWithCredential(credential);

    // Call backend to create user profile on first sign-in
    final idToken = await cred.user?.getIdToken();
    if (idToken != null) {
      final url = Uri.parse('${AppConfig.apiBaseUrl}/usersApi/users');
      await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $idToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'email': cred.user?.email,
          'displayName': cred.user?.displayName,
          'photoURL': cred.user?.photoURL,
        }),
      );
    }
  }
}

