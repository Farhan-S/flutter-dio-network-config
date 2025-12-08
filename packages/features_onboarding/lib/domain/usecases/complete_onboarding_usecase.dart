import 'package:core/core.dart';
import 'package:dartz/dartz.dart';

import '../repositories/onboarding_repository.dart';

/// Use case for completing onboarding
class CompleteOnboardingUseCase {
  final OnboardingRepository repository;

  CompleteOnboardingUseCase(this.repository);

  /// Execute onboarding completion
  ///
  /// Returns [Right] with bool (true if successful) on success
  /// Returns [Left] with [ApiException] on failure
  Future<Either<ApiException, bool>> call() async {
    return await repository.completeOnboarding();
  }
}
