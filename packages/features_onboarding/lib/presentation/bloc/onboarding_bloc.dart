import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/repositories/onboarding_repository.dart';
import '../../domain/usecases/complete_onboarding_usecase.dart';
import 'onboarding_event.dart';
import 'onboarding_state.dart';

/// BLoC for onboarding logic
class OnboardingBloc extends Bloc<OnboardingEvent, OnboardingState> {
  final OnboardingRepository repository;
  final CompleteOnboardingUseCase completeOnboardingUseCase;

  OnboardingBloc({
    required this.repository,
    required this.completeOnboardingUseCase,
  }) : super(const OnboardingInitial()) {
    on<LoadOnboardingPagesEvent>(_onLoadOnboardingPages);
    on<NextPageEvent>(_onNextPage);
    on<PreviousPageEvent>(_onPreviousPage);
    on<PageChangedEvent>(_onPageChanged);
    on<SkipOnboardingEvent>(_onSkipOnboarding);
    on<CompleteOnboardingEvent>(_onCompleteOnboarding);
  }

  /// Load onboarding pages
  Future<void> _onLoadOnboardingPages(
    LoadOnboardingPagesEvent event,
    Emitter<OnboardingState> emit,
  ) async {
    emit(const OnboardingLoading());

    final result = await repository.getOnboardingPages();

    result.fold(
      (failure) => emit(OnboardingError(failure.message)),
      (pages) => emit(OnboardingLoaded(pages: pages)),
    );
  }

  /// Go to next page
  void _onNextPage(NextPageEvent event, Emitter<OnboardingState> emit) {
    if (state is OnboardingLoaded) {
      final currentState = state as OnboardingLoaded;

      if (!currentState.isLastPage) {
        emit(currentState.copyWith(currentPage: currentState.currentPage + 1));
      } else {
        // Last page, complete onboarding
        add(const CompleteOnboardingEvent());
      }
    }
  }

  /// Go to previous page
  void _onPreviousPage(PreviousPageEvent event, Emitter<OnboardingState> emit) {
    if (state is OnboardingLoaded) {
      final currentState = state as OnboardingLoaded;

      if (!currentState.isFirstPage) {
        emit(currentState.copyWith(currentPage: currentState.currentPage - 1));
      }
    }
  }

  /// Page changed by user swipe
  void _onPageChanged(PageChangedEvent event, Emitter<OnboardingState> emit) {
    if (state is OnboardingLoaded) {
      final currentState = state as OnboardingLoaded;
      emit(currentState.copyWith(currentPage: event.pageIndex));
    }
  }

  /// Skip onboarding
  Future<void> _onSkipOnboarding(
    SkipOnboardingEvent event,
    Emitter<OnboardingState> emit,
  ) async {
    // Mark as completed
    await completeOnboardingUseCase();
    emit(const OnboardingSkipped());
  }

  /// Complete onboarding
  Future<void> _onCompleteOnboarding(
    CompleteOnboardingEvent event,
    Emitter<OnboardingState> emit,
  ) async {
    final result = await completeOnboardingUseCase();

    result.fold(
      (failure) => emit(OnboardingError(failure.message)),
      (_) => emit(const OnboardingCompleted()),
    );
  }
}
