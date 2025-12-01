import 'dart:async';
import 'dart:math';

import 'package:dio/dio.dart';

import '../network_config.dart';

/// Interceptor that retries failed requests with exponential backoff
class RetryInterceptor extends Interceptor {
  final Dio _dio;
  final int maxRetries;
  final Duration baseDelay;

  RetryInterceptor(this._dio, {int? maxRetries, Duration? baseDelay})
    : maxRetries = maxRetries ?? NetworkConfig.maxRetries,
      baseDelay =
          baseDelay ??
          Duration(milliseconds: NetworkConfig.retryDelayMilliseconds);

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final requestOptions = err.requestOptions;

    // Get current retry count from extra data
    final currentRetries = requestOptions.extra['retries'] as int? ?? 0;

    // Check if we should retry this request
    if (!_shouldRetry(err) || currentRetries >= maxRetries) {
      return handler.next(err);
    }

    // Calculate delay with exponential backoff and jitter
    final nextRetry = currentRetries + 1;
    final delay = _calculateDelay(nextRetry);

    // Wait before retrying
    await Future.delayed(delay);

    // Update retry count
    requestOptions.extra['retries'] = nextRetry;

    try {
      // Retry the request
      final response = await _dio.request(
        requestOptions.path,
        data: requestOptions.data,
        queryParameters: requestOptions.queryParameters,
        cancelToken: requestOptions.cancelToken,
        options: Options(
          method: requestOptions.method,
          headers: requestOptions.headers,
          extra: requestOptions.extra,
          responseType: requestOptions.responseType,
          contentType: requestOptions.contentType,
          validateStatus: requestOptions.validateStatus,
          receiveDataWhenStatusError: requestOptions.receiveDataWhenStatusError,
          followRedirects: requestOptions.followRedirects,
          maxRedirects: requestOptions.maxRedirects,
          persistentConnection: requestOptions.persistentConnection,
          requestEncoder: requestOptions.requestEncoder,
          responseDecoder: requestOptions.responseDecoder,
          listFormat: requestOptions.listFormat,
        ),
        onSendProgress: requestOptions.onSendProgress,
        onReceiveProgress: requestOptions.onReceiveProgress,
      );

      // Resolve with successful response
      handler.resolve(response);
    } catch (e) {
      // If retry also fails, pass the error to next interceptor
      handler.next(err);
    }
  }

  /// Determine if the request should be retried
  bool _shouldRetry(DioException error) {
    // Retry on connection errors
    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.sendTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.connectionError) {
      return true;
    }

    // Retry on specific HTTP status codes
    final statusCode = error.response?.statusCode;
    if (statusCode != null) {
      // Retry on server errors (5xx) and some client errors
      return statusCode >= 500 ||
          statusCode == 408 || // Request Timeout
          statusCode == 429; // Too Many Requests
    }

    return false;
  }

  /// Calculate delay with exponential backoff and jitter
  Duration _calculateDelay(int retryCount) {
    // Exponential backoff: baseDelay * 2^(retryCount - 1)
    final exponentialDelay = baseDelay.inMilliseconds * pow(2, retryCount - 1);

    // Add random jitter (0-100ms) to prevent thundering herd
    final jitter = Random().nextInt(100);

    final totalDelayMs = exponentialDelay.toInt() + jitter;

    // Cap maximum delay at 30 seconds
    return Duration(milliseconds: min(totalDelayMs, 30000));
  }
}
