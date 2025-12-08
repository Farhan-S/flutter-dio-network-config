import 'package:core/core.dart';
import 'package:dartz/dartz.dart';

import '../repositories/onboarding_repository.dart';

/// Use case for checking onboarding status
class CheckOnboardingStatusUseCase {
  final OnboardingRepository repository;

  CheckOnboardingStatusUseCase(this.repository);

  /// Execute onboarding status check
  ///
  /// Returns [Right] with bool (true if completed) on success
  /// Returns [Left] with [ApiException] on failure
  Future<Either<ApiException, bool>> call() async {
    return await repository.hasCompletedOnboarding();
  }
}
