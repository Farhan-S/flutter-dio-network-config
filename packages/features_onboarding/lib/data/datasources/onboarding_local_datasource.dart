import 'package:shared_preferences/shared_preferences.dart';

import '../models/onboarding_page_model.dart';

/// Local data source for onboarding
class OnboardingLocalDataSource {
  static const String _onboardingCompletedKey = 'onboarding_completed';

  final SharedPreferences sharedPreferences;

  OnboardingLocalDataSource(this.sharedPreferences);

  /// Get onboarding pages
  /// In a real app, this might come from a remote API or local JSON
  Future<List<OnboardingPageModel>> getOnboardingPages() async {
    // Simulate slight delay
    await Future.delayed(const Duration(milliseconds: 300));

    return const [
      OnboardingPageModel(
        title: 'Welcome to Clean Architecture',
        description:
            'Build scalable and maintainable Flutter apps with proper architecture patterns and separation of concerns.',
        image: '🏗️',
        index: 0,
      ),
      OnboardingPageModel(
        title: 'Modular Package Structure',
        description:
            'Each feature is isolated in its own package with domain, data, and presentation layers using Melos.',
        image: '📦',
        index: 1,
      ),
      OnboardingPageModel(
        title: 'BLoC State Management',
        description:
            'Manage your app state reactively with BLoC pattern, ensuring predictable and testable code.',
        image: '🎯',
        index: 2,
      ),
      OnboardingPageModel(
        title: 'Robust Network Layer',
        description:
            'Built-in error handling, retry logic, token refresh, and interceptors for seamless API communication.',
        image: '🌐',
        index: 3,
      ),
    ];
  }

  /// Mark onboarding as completed
  Future<bool> completeOnboarding() async {
    return await sharedPreferences.setBool(_onboardingCompletedKey, true);
  }

  /// Check if onboarding has been completed
  Future<bool> hasCompletedOnboarding() async {
    return sharedPreferences.getBool(_onboardingCompletedKey) ?? false;
  }
}
