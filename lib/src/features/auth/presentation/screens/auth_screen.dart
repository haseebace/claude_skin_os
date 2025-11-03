import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../../application/auth_controller.dart';

class AuthScreen extends ConsumerWidget {
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sign In')),
      body: Center(
        child: PrimaryButton(
          label: 'Sign in with Google',
          onPressed: () => ref.read(authControllerProvider).signInWithGoogle(),
        ),
      ),
    );
  }
}
