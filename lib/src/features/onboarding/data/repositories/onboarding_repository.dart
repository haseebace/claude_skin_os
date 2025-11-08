
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'onboarding_repository.g.dart';

class OnboardingRepository {
  OnboardingRepository(this._prefs);

  final SharedPreferences _prefs;

  static const _hasSeenOnboardingKey = 'has_seen_onboarding';

  Future<bool> hasSeenOnboarding() async {
    return _prefs.getBool(_hasSeenOnboardingKey) ?? false;
  }

  Future<void> setHasSeenOnboarding() async {
    await _prefs.setBool(_hasSeenOnboardingKey, true);
  }
}

@Riverpod(keepAlive: true)
Future<OnboardingRepository> onboardingRepository(OnboardingRepositoryRef ref) async {
  final prefs = await SharedPreferences.getInstance();
  return OnboardingRepository(prefs);
}
