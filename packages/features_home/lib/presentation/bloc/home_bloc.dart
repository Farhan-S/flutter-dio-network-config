import 'package:flutter_bloc/flutter_bloc.dart';

import 'home_event.dart';
import 'home_state.dart';

/// BLoC for managing home page state
class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc() : super(const HomeInitial()) {
    on<LoadHomeDataEvent>(_onLoadHomeData);
    on<RefreshHomeDataEvent>(_onRefreshHomeData);
  }

  Future<void> _onLoadHomeData(
    LoadHomeDataEvent event,
    Emitter<HomeState> emit,
  ) async {
    emit(const HomeLoading());

    try {
      // Simulate loading data
      await Future.delayed(const Duration(milliseconds: 500));

      emit(HomeLoaded(lastUpdated: DateTime.now()));
    } catch (e) {
      emit(HomeError('Failed to load home data: ${e.toString()}'));
    }
  }

  Future<void> _onRefreshHomeData(
    RefreshHomeDataEvent event,
    Emitter<HomeState> emit,
  ) async {
    // Keep current state while refreshing
    try {
      await Future.delayed(const Duration(milliseconds: 300));

      emit(HomeLoaded(lastUpdated: DateTime.now()));
    } catch (e) {
      emit(HomeError('Failed to refresh home data: ${e.toString()}'));
    }
  }
}
