import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/run_network_tests_usecase.dart';
import 'network_test_event.dart';
import 'network_test_state.dart';

/// BLoC for managing network test execution
class NetworkTestBloc extends Bloc<NetworkTestEvent, NetworkTestState> {
  final RunNetworkTestsUseCase runNetworkTestsUseCase;

  NetworkTestBloc({required this.runNetworkTestsUseCase})
    : super(const NetworkTestInitial()) {
    on<RunAllNetworkTestsEvent>(_onRunAllNetworkTests);
    on<ClearNetworkTestsEvent>(_onClearNetworkTests);
  }

  Future<void> _onRunAllNetworkTests(
    RunAllNetworkTestsEvent event,
    Emitter<NetworkTestState> emit,
  ) async {
    const totalTests = 8;
    final completedResults = <dynamic>[];

    // Emit initial running state
    emit(
      const NetworkTestRunning(
        currentResults: [],
        completedCount: 0,
        totalCount: totalTests,
      ),
    );

    try {
      // Execute use case with progress callback
      final result = await runNetworkTestsUseCase(
        onTestComplete: (testResult) {
          // Add to completed results
          completedResults.add(testResult);

          // Emit progress state immediately after each test
          emit(
            NetworkTestRunning(
              currentResults: List.from(completedResults),
              completedCount: completedResults.length,
              totalCount: totalTests,
            ),
          );
        },
      );

      // Handle final result
      result.fold(
        (failure) {
          emit(NetworkTestError(failure.message));
        },
        (testSuite) {
          // Emit final complete state with all results
          emit(NetworkTestComplete(testSuite));
        },
      );
    } catch (e) {
      emit(NetworkTestError('Unexpected error: ${e.toString()}'));
    }
  }

  void _onClearNetworkTests(
    ClearNetworkTestsEvent event,
    Emitter<NetworkTestState> emit,
  ) {
    emit(const NetworkTestInitial());
  }
}
