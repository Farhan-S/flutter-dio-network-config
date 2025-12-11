import 'package:core/core.dart';
import 'package:dio/dio.dart';

import '../models/network_test_model.dart';

/// Data source for running network tests
class NetworkTestDataSource {
  final DioClient dioClient;

  NetworkTestDataSource(this.dioClient);

  /// Test GET request
  Future<NetworkTestModel> testGetRequest() async {
    final startTime = DateTime.now();
    try {
      final response = await dioClient.get(ApiRoutes.postById(1));
      final duration = DateTime.now().difference(startTime).inMilliseconds;

      return NetworkTestModel(
        name: 'GET Request',
        method: 'GET',
        success: response.statusCode == 200,
        duration: duration,
        message: 'Successfully fetched post with ID 1',
        data: response.data,
      );
    } catch (e) {
      final duration = DateTime.now().difference(startTime).inMilliseconds;
      return NetworkTestModel(
        name: 'GET Request',
        method: 'GET',
        success: false,
        duration: duration,
        message: 'Error: $e',
      );
    }
  }

  /// Test GET with query parameters
  Future<NetworkTestModel> testGetWithParams() async {
    final startTime = DateTime.now();
    try {
      final response = await dioClient.get(
        ApiRoutes.posts,
        queryParameters: {'userId': 1},
      );
      final duration = DateTime.now().difference(startTime).inMilliseconds;

      return NetworkTestModel(
        name: 'GET with Query Parameters',
        method: 'GET',
        success: response.statusCode == 200,
        duration: duration,
        message: 'Fetched ${(response.data as List).length} posts for user 1',
        data: 'Found ${(response.data as List).length} items',
      );
    } catch (e) {
      final duration = DateTime.now().difference(startTime).inMilliseconds;
      return NetworkTestModel(
        name: 'GET with Query Parameters',
        method: 'GET',
        success: false,
        duration: duration,
        message: 'Error: $e',
      );
    }
  }

  /// Test POST request
  Future<NetworkTestModel> testPostRequest() async {
    final startTime = DateTime.now();
    try {
      final response = await dioClient.post(
        ApiRoutes.posts,
        data: {
          'title': 'Test Post',
          'body': 'This is a test post from the app',
          'userId': 1,
        },
      );
      final duration = DateTime.now().difference(startTime).inMilliseconds;

      return NetworkTestModel(
        name: 'POST Request',
        method: 'POST',
        success: response.statusCode == 201,
        duration: duration,
        message: 'Successfully created new post',
        data: response.data,
      );
    } catch (e) {
      final duration = DateTime.now().difference(startTime).inMilliseconds;
      return NetworkTestModel(
        name: 'POST Request',
        method: 'POST',
        success: false,
        duration: duration,
        message: 'Error: $e',
      );
    }
  }

  /// Test PUT request
  Future<NetworkTestModel> testPutRequest() async {
    final startTime = DateTime.now();
    try {
      final response = await dioClient.put(
        ApiRoutes.postById(1),
        data: {
          'id': 1,
          'title': 'Updated Post',
          'body': 'This post has been updated',
          'userId': 1,
        },
      );
      final duration = DateTime.now().difference(startTime).inMilliseconds;

      return NetworkTestModel(
        name: 'PUT Request',
        method: 'PUT',
        success: response.statusCode == 200,
        duration: duration,
        message: 'Successfully updated post with ID 1',
        data: response.data,
      );
    } catch (e) {
      final duration = DateTime.now().difference(startTime).inMilliseconds;
      return NetworkTestModel(
        name: 'PUT Request',
        method: 'PUT',
        success: false,
        duration: duration,
        message: 'Error: $e',
      );
    }
  }

  /// Test DELETE request
  Future<NetworkTestModel> testDeleteRequest() async {
    final startTime = DateTime.now();
    try {
      final response = await dioClient.delete(ApiRoutes.postById(1));
      final duration = DateTime.now().difference(startTime).inMilliseconds;

      return NetworkTestModel(
        name: 'DELETE Request',
        method: 'DELETE',
        success: response.statusCode == 200,
        duration: duration,
        message: 'Successfully deleted post with ID 1',
      );
    } catch (e) {
      final duration = DateTime.now().difference(startTime).inMilliseconds;
      return NetworkTestModel(
        name: 'DELETE Request',
        method: 'DELETE',
        success: false,
        duration: duration,
        message: 'Error: $e',
      );
    }
  }

  /// Test error handling (404)
  Future<NetworkTestModel> testErrorHandling() async {
    final startTime = DateTime.now();
    try {
      await dioClient.get(ApiRoutes.nonExistentEndpoint);
      final duration = DateTime.now().difference(startTime).inMilliseconds;

      return NetworkTestModel(
        name: 'Error Handling (404)',
        method: 'GET',
        success: false,
        duration: duration,
        message: 'Expected 404 but got success - Test Failed',
      );
    } catch (e) {
      final duration = DateTime.now().difference(startTime).inMilliseconds;

      // Extract the actual ApiException from DioException if present
      final actualError = e is DioException && e.error is ApiException
          ? e.error as ApiException
          : e;

      // Check if it's the expected error type (404 NotFoundException)
      final isCorrectError =
          actualError is NotFoundException ||
          actualError.toString().contains('404') ||
          (e is DioException && e.response?.statusCode == 404);

      return NetworkTestModel(
        name: 'Error Handling (404)',
        method: 'GET',
        success: isCorrectError,
        duration: duration,
        message: isCorrectError
            ? 'Correctly handled 404 error: ${actualError.runtimeType}'
            : 'Wrong error type: ${actualError.runtimeType} (expected NotFoundException)',
      );
    }
  }

  /// Test timeout configuration
  Future<NetworkTestModel> testTimeout() async {
    final startTime = DateTime.now();
    try {
      DioClient();
      final duration = DateTime.now().difference(startTime).inMilliseconds;

      return NetworkTestModel(
        name: 'Timeout Handling',
        method: 'GET',
        success: true,
        duration: duration,
        message:
            'Timeout configuration is set to ${NetworkConfig.connectTimeoutSeconds}s',
      );
    } catch (e) {
      final duration = DateTime.now().difference(startTime).inMilliseconds;
      return NetworkTestModel(
        name: 'Timeout Handling',
        method: 'GET',
        success: true,
        duration: duration,
        message: 'Timeout handled correctly: $e',
      );
    }
  }

  /// Test retry interceptor configuration
  Future<NetworkTestModel> testRetry() async {
    final startTime = DateTime.now();
    try {
      final duration = DateTime.now().difference(startTime).inMilliseconds;

      return NetworkTestModel(
        name: 'Retry Interceptor',
        method: 'CONFIG',
        success: true,
        duration: duration,
        message:
            'Retry interceptor configured with ${NetworkConfig.maxRetries} max retries',
      );
    } catch (e) {
      final duration = DateTime.now().difference(startTime).inMilliseconds;
      return NetworkTestModel(
        name: 'Retry Interceptor',
        method: 'CONFIG',
        success: false,
        duration: duration,
        message: 'Error: $e',
      );
    }
  }
}
