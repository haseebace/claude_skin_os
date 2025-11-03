import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:claude_skin_os/src/core/routing/app_router.dart';

void main() {
  testWidgets('AuthScreen shows Sign in with Google button', (tester) async {
    final router = createAppRouter();
    await tester.pumpWidget(ProviderScope(
      child: MaterialApp.router(routerConfig: router),
    ));
    expect(find.text('Sign in with Google'), findsOneWidget);
  });
}

