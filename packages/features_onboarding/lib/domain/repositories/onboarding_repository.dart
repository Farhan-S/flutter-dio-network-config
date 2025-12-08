import 'package:core/core.dart';
import 'package:dartz/dartz.dart';

import '../entities/onboarding_page_entity.dart';

/// Repository interface for onboarding
abstract class OnboardingRepository {
  /// Get all onboarding pages
  Future<Either<ApiException, List<OnboardingPageEntity>>> getOnboardingPages();

  /// Mark onboarding as completed
  Future<Either<ApiException, bool>> completeOnboarding();

  /// Check if onboarding has been completed
  Future<Either<ApiException, bool>> hasCompletedOnboarding();
}
