import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;

final authStateProvider = StreamProvider<fb.User?>((ref) {
  try {
    return fb.FirebaseAuth.instance.authStateChanges();
  } catch (_) {
    // If Firebase isn't configured yet, expose an empty stream so UI still renders
    return const Stream<fb.User?>.empty();
  }
});
