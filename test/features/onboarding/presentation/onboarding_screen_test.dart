
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:claude_skin_os/src/features/onboarding/data/repositories/onboarding_repository.dart';
import 'package:claude_skin_os/src/features/onboarding/presentation/screens/onboarding_screen.dart';
import 'onboarding_screen_test.mocks.dart';

@GenerateMocks([OnboardingRepository])
void main() {
  testWidgets('OnboardingScreen shows pages and navigates on skip', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final mockOnboardingRepository = MockOnboardingRepository();
    when(mockOnboardingRepository.setHasSeenOnboarding()).thenAnswer((_) async {});

    final router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const OnboardingScreen(),
        ),
        GoRoute(
          path: '/home',
          builder: (context, state) => const Scaffold(body: Text('Home')),
        ),
      ],
    );

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          onboardingRepositoryProvider.overrideWith((_) => Future.value(mockOnboardingRepository)),
        ],
        child: MaterialApp.router(
          routerConfig: router,
        ),
      ),
    );

    expect(find.text('Intake'), findsOneWidget);

    await tester.tap(find.text('Skip'));
    await tester.pumpAndSettle();

    verify(mockOnboardingRepository.setHasSeenOnboarding()).called(1);
    expect(find.text('Home'), findsOneWidget);
  });
}
