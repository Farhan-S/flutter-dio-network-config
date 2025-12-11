import 'package:core/core.dart';
import 'package:dartz/dartz.dart';

import '../../domain/entities/network_test_entity.dart';
import '../../domain/repositories/network_test_repository.dart';
import '../datasources/network_test_datasource.dart';

/// Implementation of NetworkTestRepository
class NetworkTestRepositoryImpl implements NetworkTestRepository {
  final NetworkTestDataSource dataSource;

  NetworkTestRepositoryImpl(this.dataSource);

  @override
  Future<Either<ApiException, NetworkTestSuiteEntity>> runAllTests({
    void Function(NetworkTestEntity)? onTestComplete,
  }) async {
    try {
      final results = <NetworkTestEntity>[];

      // Helper to run test and notify
      Future<void> runTest(Future<NetworkTestEntity> Function() test) async {
        final result = await test();
        results.add(result);
        onTestComplete?.call(result);
      }

      // Run all tests sequentially with progress callbacks
      await runTest(() async => (await dataSource.testGetRequest()).toEntity());
      await runTest(
        () async => (await dataSource.testGetWithParams()).toEntity(),
      );
      await runTest(
        () async => (await dataSource.testPostRequest()).toEntity(),
      );
      await runTest(() async => (await dataSource.testPutRequest()).toEntity());
      await runTest(
        () async => (await dataSource.testDeleteRequest()).toEntity(),
      );
      await runTest(
        () async => (await dataSource.testErrorHandling()).toEntity(),
      );
      await runTest(() async => (await dataSource.testTimeout()).toEntity());
      await runTest(() async => (await dataSource.testRetry()).toEntity());

      // Calculate statistics
      final passedTests = results.where((r) => r.success).length;
      final failedTests = results.length - passedTests;

      final testSuite = NetworkTestSuiteEntity(
        results: results,
        totalTests: results.length,
        passedTests: passedTests,
        failedTests: failedTests,
        isComplete: true,
      );

      return Right(testSuite);
    } catch (e) {
      if (e is ApiException) {
        return Left(e);
      }
      return Left(
        UnknownException('Failed to run tests: ${e.toString()}', e, null),
      );
    }
  }

  @override
  Future<Either<ApiException, NetworkTestEntity>> runTest(
    String testName,
  ) async {
    try {
      NetworkTestEntity result;

      switch (testName) {
        case 'GET Request':
          result = (await dataSource.testGetRequest()).toEntity();
          break;
        case 'GET with Query Parameters':
          result = (await dataSource.testGetWithParams()).toEntity();
          break;
        case 'POST Request':
          result = (await dataSource.testPostRequest()).toEntity();
          break;
        case 'PUT Request':
          result = (await dataSource.testPutRequest()).toEntity();
          break;
        case 'DELETE Request':
          result = (await dataSource.testDeleteRequest()).toEntity();
          break;
        case 'Error Handling (404)':
          result = (await dataSource.testErrorHandling()).toEntity();
          break;
        case 'Timeout Handling':
          result = (await dataSource.testTimeout()).toEntity();
          break;
        case 'Retry Interceptor':
          result = (await dataSource.testRetry()).toEntity();
          break;
        default:
          return Left(
            ValidationException(
              'Unknown test name: $testName',
              null,
              null,
              null,
            ),
          );
      }

      return Right(result);
    } catch (e) {
      if (e is ApiException) {
        return Left(e);
      }
      return Left(
        UnknownException('Failed to run test: ${e.toString()}', e, null),
      );
    }
  }
}
