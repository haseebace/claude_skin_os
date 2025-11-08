
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:claude_skin_os/src/features/onboarding/data/repositories/onboarding_repository.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  late final PageController controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    controller = PageController();
    _checkOnboardingStatus();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Future<void> _checkOnboardingStatus() async {
    final repository = await ref.read(onboardingRepositoryProvider.future);
    final hasSeenOnboarding = await repository.hasSeenOnboarding();

    if (mounted) {
      if (hasSeenOnboarding) {
        context.go('/home');
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFFF7F4F0),
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final pages = [
      _buildOnboardingPage(
        context,
        title: 'Intake',
        text: 'Answer a few questions so we can understand your unique skin.',
      ),
      _buildOnboardingPage(
        context,
        title: 'Routine',
        text:
            'Receive a personalized daily and weekly routine generated just for you.',
      ),
      _buildOnboardingPage(
        context,
        title: 'Tracking',
        text: 'Track your progress with photos and see the results over time.',
      ),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF7F4F0),
      body: Stack(
        children: [
          PageView(controller: controller, children: pages),
          Positioned(
            bottom: 50,
            left: 20,
            right: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () {
                    ref
                        .read(onboardingRepositoryProvider.future)
                        .then((repo) => repo.setHasSeenOnboarding());
                    context.go('/home');
                  },
                  child: const Text('Skip'),
                ),
                TextButton(
                  onPressed: () {
                    if (controller.page!.toInt() == pages.length - 1) {
                      ref
                          .read(onboardingRepositoryProvider.future)
                          .then((repo) => repo.setHasSeenOnboarding());
                      context.go('/home');
                    } else {
                      controller.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    }
                  },
                  child: const Text('Next'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOnboardingPage(BuildContext context, {required String title, required String text}) {
    return Padding(
      padding: const EdgeInsets.all(40.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 20),
          Text(
            text,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}
