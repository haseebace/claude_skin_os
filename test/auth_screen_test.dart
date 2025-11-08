import 'package:flutter/material.dart';
import 'dart:io' as io;
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:claude_skin_os/src/features/auth/presentation/screens/auth_screen.dart';
import 'package:claude_skin_os/src/features/auth/presentation/providers/auth_providers.dart';

void main() {
  testWidgets('AuthScreen shows Sign in with Google button', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authStateProvider.overrideWith((ref) => const Stream.empty()),
        ],
        child: MaterialApp(home: AuthScreen()),
      ),
    );
    await tester.pumpAndSettle();
    debugDumpApp();
    expect(
      find.widgetWithText(FilledButton, 'Sign in with Google'),
      findsOneWidget,
    );
  });

  testWidgets('Apple button visible on iOS only', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authStateProvider.overrideWith((ref) => const Stream.empty()),
        ],
        child: MaterialApp(home: AuthScreen()),
      ),
    );

    if (io.Platform.isIOS) {
      expect(find.text('Sign in with Apple'), findsOneWidget);
    } else {
      expect(find.text('Sign in with Apple'), findsNothing);
    }
  });
}
