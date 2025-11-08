
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:claude_skin_os/src/features/auth/presentation/providers/auth_providers.dart';

class AuthNotifier extends ChangeNotifier {
  AuthNotifier(this._ref) {
    _ref.listen<AsyncValue<dynamic>>(authStateProvider, (_, __) => notifyListeners());
  }

  final Ref _ref;
}

final authNotifierProvider = Provider<AuthNotifier>((ref) {
  return AuthNotifier(ref);
});
