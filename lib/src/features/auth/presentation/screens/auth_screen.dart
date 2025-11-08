import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../../application/auth_controller.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  bool _isLoading = false;

  Future<void> _handleSignIn() async {
    // Prevent multiple simultaneous sign-in attempts
    if (_isLoading) {
      print('[AuthScreen] Sign-in already in progress, ignoring button press');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    print('[AuthScreen] ========================================');
    print('[AuthScreen] Sign-in button pressed');
    print('[AuthScreen] Timestamp: ${DateTime.now().toIso8601String()}');
    print('[AuthScreen] ========================================');

    try {
      final controller = ref.read(authControllerProvider);
      final success = await controller.signInWithGoogle(context);
      
      print('[AuthScreen] Sign-in result: $success');
      
      if (!success && mounted) {
        // Error is already handled in controller, but log here too
        print('[AuthScreen] Sign-in failed - check logs above for details');
      }
    } catch (e, stack) {
      // Catch any errors that might escape the controller
      print('[AuthScreen] ========================================');
      print('[AuthScreen] CRITICAL ERROR: Uncaught exception in button handler');
      print('[AuthScreen] Error: $e');
      print('[AuthScreen] Stack: $stack');
      print('[AuthScreen] ========================================');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Unexpected error: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sign In')),
      body: Center(
        child: _isLoading
            ? const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Signing in...'),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  PrimaryButton(
                    label: 'Sign in with Google',
                    onPressed: _handleSignIn,
                  ),
                  const SizedBox(height: 12),
                  if (Platform.isIOS)
                    PrimaryButton(
                      label: 'Sign in with Apple',
                      onPressed: () async {
                        // Prevent multiple simultaneous sign-in attempts
                        if (_isLoading) return;
                        setState(() => _isLoading = true);
                        try {
                          final controller = ref.read(authControllerProvider);
                          final success = await controller.signInWithApple(context);
                          print('[AuthScreen] Apple sign-in result: $success');
                          if (!success && mounted) {
                            print('[AuthScreen] Apple sign-in failed');
                          }
                        } finally {
                          if (mounted) setState(() => _isLoading = false);
                        }
                      },
                    ),
                ],
              ),
      ),
    );
  }
}
