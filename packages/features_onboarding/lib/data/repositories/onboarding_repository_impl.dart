import 'package:core/core.dart';
import 'package:dartz/dartz.dart';

import '../../domain/entities/onboarding_page_entity.dart';
import '../../domain/repositories/onboarding_repository.dart';
import '../datasources/onboarding_local_datasource.dart';

/// Implementation of onboarding repository
class OnboardingRepositoryImpl implements OnboardingRepository {
  final OnboardingLocalDataSource localDataSource;

  OnboardingRepositoryImpl(this.localDataSource);

  @override
  Future<Either<ApiException, List<OnboardingPageEntity>>>
  getOnboardingPages() async {
    try {
      final pages = await localDataSource.getOnboardingPages();
      return Right(pages);
    } catch (e) {
      return Left(
        ApiException('Failed to load onboarding pages: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<ApiException, bool>> completeOnboarding() async {
    try {
      final result = await localDataSource.completeOnboarding();
      return Right(result);
    } catch (e) {
      return Left(
        ApiException('Failed to complete onboarding: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<ApiException, bool>> hasCompletedOnboarding() async {
    try {
      final hasCompleted = await localDataSource.hasCompletedOnboarding();
      return Right(hasCompleted);
    } catch (e) {
      return Left(
        ApiException('Failed to check onboarding status: ${e.toString()}'),
      );
    }
  }
}
