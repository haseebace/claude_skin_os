import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:http/http.dart' as http;
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import '../../../core/constants/app_config.dart';

final authControllerProvider = Provider<AuthController>((ref) {
  return AuthController(ref);
});

class AuthController {
  final Ref ref;
  AuthController(this.ref);

  // For web, GoogleSignIn will read the client ID from the meta tag in index.html
  // For mobile platforms, no client ID is needed
  final _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
  );

  Future<bool> signInWithGoogle(BuildContext context) async {
    try {
      // Use print() for DevTools Logging tab visibility
      print('[Auth] ========================================');
      print('[Auth] Button clicked - Starting Google sign-in');
      print('[Auth] Timestamp: ${DateTime.now().toIso8601String()}');
      
      // Step 1: Initialize Google Sign-In
      print('[Auth] Step 1: Initializing Google Sign-In...');
      final googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) {
        print('[Auth] Step 1 Result: User cancelled sign-in');
        return false;
      }
      print('[Auth] Step 1 Result: User selected - ${googleUser.email}');
      
      // Step 2: Get authentication tokens
      print('[Auth] Step 2: Getting authentication tokens...');
      final googleAuth = await googleUser.authentication;
      print('[Auth] Step 2 Result: Tokens obtained (accessToken: ${googleAuth.accessToken != null ? "present" : "null"}, idToken: ${googleAuth.idToken != null ? "present" : "null"})');
      
      // Step 3: Create Firebase credential
      print('[Auth] Step 3: Creating Firebase credential...');
      final credential = fb.GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      print('[Auth] Step 3 Result: Credential created');
      
      // Step 4: Sign in to Firebase
      print('[Auth] Step 4: Signing in to Firebase...');
      final cred = await fb.FirebaseAuth.instance.signInWithCredential(credential);
      print('[Auth] Step 4 Result: Firebase sign-in success');
      print('[Auth] User UID: ${cred.user?.uid}');
      print('[Auth] User Email: ${cred.user?.email}');
      print('[Auth] User Display Name: ${cred.user?.displayName}');

      // Step 5: Call backend to create user profile on first sign-in
      print('[Auth] Step 5: Checking backend API configuration...');
      final idToken = await cred.user?.getIdToken();
      final base = AppConfig.apiBaseUrl;
      
      if (idToken != null && base.isNotEmpty && !base.contains('REGION-PROJECT')) {
        final url = Uri.parse('$base/usersApi/users');
        print('[Auth] Step 5: Calling backend API at $url');
        try {
          final resp = await http.post(
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
          print('[Auth] Step 5 Result: Backend response ${resp.statusCode}');
          print('[Auth] Backend response body: ${resp.body}');
        } catch (apiError, apiStack) {
          print('[Auth] Step 5 Error: Backend API call failed');
          print('[Auth] API Error: $apiError');
          print('[Auth] API Stack: $apiStack');
          // Don't fail the entire sign-in if backend call fails
        }
      } else {
        print('[Auth] Step 5: Skipping backend call');
        print('[Auth] Reason: base="$base", tokenPresent=${idToken != null}');
      }
      
      print('[Auth] ========================================');
      print('[Auth] Sign-in completed successfully');
      return true;
    } catch (e, st) {
      // Comprehensive error logging for DevTools
      print('[Auth] ========================================');
      print('[Auth] ERROR: Sign-in failed');
      print('[Auth] Error Type: ${e.runtimeType}');
      print('[Auth] Error Message: $e');
      print('[Auth] Stack Trace:');
      print(st);
      print('[Auth] ========================================');
      
      // Show user-friendly error message
      if (context.mounted) {
        try {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Sign-in failed: ${e.toString()}'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 5),
            ),
          );
        } catch (snackError) {
          print('[Auth] Failed to show snackbar: $snackError');
        }
      }
      return false;
    }
  }

  Future<bool> signInWithApple(BuildContext context) async {
    try {
      print('[Auth] ========================================');
      print('[Auth] Button clicked - Starting Apple sign-in');
      print('[Auth] Timestamp: ${DateTime.now().toIso8601String()}');

      // Step 1: Request Apple ID credential
      print('[Auth] Step 1: Requesting Apple ID credential...');
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );
      print('[Auth] Step 1 Result: Apple credential received');

      // Step 2: Convert to Firebase OAuth credential
      print('[Auth] Step 2: Creating Firebase OAuth credential...');
      final oauthProvider = fb.OAuthProvider('apple.com');
      final credential = oauthProvider.credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );
      print('[Auth] Step 2 Result: Credential created');

      // Step 3: Sign in to Firebase
      print('[Auth] Step 3: Signing in to Firebase...');
      final cred = await fb.FirebaseAuth.instance.signInWithCredential(credential);
      print('[Auth] Step 3 Result: Firebase sign-in success');
      print('[Auth] User UID: ${cred.user?.uid}');
      print('[Auth] User Email: ${cred.user?.email}');
      print('[Auth] User Display Name: ${cred.user?.displayName}');

      // Step 4: Backend user creation on first sign-in (same as Google flow)
      print('[Auth] Step 4: Checking backend API configuration...');
      final idToken = await cred.user?.getIdToken();
      final base = AppConfig.apiBaseUrl;
      if (idToken != null && base.isNotEmpty && !base.contains('REGION-PROJECT')) {
        final url = Uri.parse('$base/usersApi/users');
        print('[Auth] Step 4: Calling backend API at $url');
        try {
          final resp = await http.post(
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
          print('[Auth] Step 4 Result: Backend response ${resp.statusCode}');
          print('[Auth] Backend response body: ${resp.body}');
        } catch (apiError, apiStack) {
          print('[Auth] Step 4 Error: Backend API call failed');
          print('[Auth] API Error: $apiError');
          print('[Auth] API Stack: $apiStack');
        }
      } else {
        print('[Auth] Step 4: Skipping backend call');
        print('[Auth] Reason: base="$base", tokenPresent=${idToken != null}');
      }

      print('[Auth] ========================================');
      print('[Auth] Apple sign-in completed successfully');
      return true;
    } catch (e, st) {
      print('[Auth] ========================================');
      print('[Auth] ERROR: Apple sign-in failed');
      print('[Auth] Error Type: ${e.runtimeType}');
      print('[Auth] Error Message: $e');
      print('[Auth] Stack Trace:');
      print(st);
      print('[Auth] ========================================');
      if (context.mounted) {
        try {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Apple sign-in failed: ${e.toString()}'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 5),
            ),
          );
        } catch (_) {}
      }
      return false;
    }
  }
}
