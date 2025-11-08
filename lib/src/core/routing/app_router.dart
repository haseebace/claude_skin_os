import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/screens/auth_screen.dart';
import '../../features/auth/presentation/providers/auth_providers.dart';
import '../../features/onboarding/presentation/screens/onboarding_screen.dart';
import '../../features/auth/presentation/providers/auth_notifier.dart';
import '../../features/home/presentation/screens/home_screen.dart';

final goRouterProvider = Provider<GoRouter>((ref) {
  final authNotifier = ref.watch(authNotifierProvider);

  return GoRouter(
    initialLocation: '/',
    refreshListenable: authNotifier,
    redirect: (context, state) {
      final container = ProviderScope.containerOf(context, listen: false);
      final auth = container.read(authStateProvider);
      final isLoggedIn = auth.asData?.value != null;
      final isOnAuth = state.uri.toString() == '/';

      // If not logged in, only allow auth screen
      if (!isLoggedIn && !isOnAuth) {
        return '/';
      }

      // If logged in and on auth screen, redirect to onboarding or home
      if (isLoggedIn && isOnAuth) {
        return '/onboarding';
      }

      // Don't redirect from onboarding - let the onboarding screen handle it

      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const AuthScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const HomeScreen(),
      ),
    ],
  );
});
