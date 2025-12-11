import 'package:core/core.dart';
import 'package:dartz/dartz.dart';

import '../entities/network_test_entity.dart';
import '../repositories/network_test_repository.dart';

/// Use case for running all network tests
class RunNetworkTestsUseCase {
  final NetworkTestRepository repository;

  RunNetworkTestsUseCase(this.repository);

  Future<Either<ApiException, NetworkTestSuiteEntity>> call({
    void Function(NetworkTestEntity)? onTestComplete,
  }) async {
    return await repository.runAllTests(onTestComplete: onTestComplete);
  }
}
