import 'package:equatable/equatable.dart';

import '../../domain/entities/onboarding_page_entity.dart';

/// Base class for onboarding states
abstract class OnboardingState extends Equatable {
  const OnboardingState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class OnboardingInitial extends OnboardingState {
  const OnboardingInitial();
}

/// Loading onboarding pages
class OnboardingLoading extends OnboardingState {
  const OnboardingLoading();
}

/// Onboarding pages loaded
class OnboardingLoaded extends OnboardingState {
  final List<OnboardingPageEntity> pages;
  final int currentPage;

  const OnboardingLoaded({required this.pages, this.currentPage = 0});

  bool get isFirstPage => currentPage == 0;
  bool get isLastPage => currentPage == pages.length - 1;

  @override
  List<Object?> get props => [pages, currentPage];

  OnboardingLoaded copyWith({
    List<OnboardingPageEntity>? pages,
    int? currentPage,
  }) {
    return OnboardingLoaded(
      pages: pages ?? this.pages,
      currentPage: currentPage ?? this.currentPage,
    );
  }
}

/// Onboarding completed - navigate away
class OnboardingCompleted extends OnboardingState {
  const OnboardingCompleted();
}

/// Onboarding skipped - navigate away
class OnboardingSkipped extends OnboardingState {
  const OnboardingSkipped();
}

/// Error loading onboarding
class OnboardingError extends OnboardingState {
  final String message;

  const OnboardingError(this.message);

  @override
  List<Object?> get props => [message];
}
