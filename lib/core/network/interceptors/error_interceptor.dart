import 'package:dio/dio.dart';

import '../api_exceptions.dart';

/// Interceptor that converts Dio errors to domain-specific ApiExceptions
class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final apiException = _mapDioErrorToApiException(err);

    // Wrap the ApiException in DioException's error field
    handler.reject(
      DioException(
        requestOptions: err.requestOptions,
        response: err.response,
        type: err.type,
        error: apiException,
      ),
    );
  }

  /// Map DioException to specific ApiException types
  ApiException _mapDioErrorToApiException(DioException error) {
    // Handle timeout errors
    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.sendTimeout ||
        error.type == DioExceptionType.receiveTimeout) {
      return TimeoutException(
        'Request timed out. Please check your connection and try again.',
        error,
        error.stackTrace,
      );
    }

    // Handle cancel errors
    if (error.type == DioExceptionType.cancel) {
      return CancelException('Request was cancelled', error, error.stackTrace);
    }

    // Handle connection errors
    if (error.type == DioExceptionType.connectionError) {
      return NetworkException(
        'Unable to connect to the server. Please check your internet connection.',
        error,
        error.stackTrace,
      );
    }

    // Handle response errors based on status code
    if (error.type == DioExceptionType.badResponse) {
      final statusCode = error.response?.statusCode ?? 0;
      final message = _parseErrorMessage(error.response);

      switch (statusCode) {
        case 400:
          return ValidationException(
            message,
            _parseValidationErrors(error.response),
            error,
            error.stackTrace,
          );

        case 401:
          return UnauthorizedException(
            message.isEmpty ? 'Unauthorized. Please login again.' : message,
            error,
            error.stackTrace,
          );

        case 403:
          return ForbiddenException(
            message.isEmpty ? 'Access forbidden' : message,
            error,
            error.stackTrace,
          );

        case 404:
          return NotFoundException(
            message.isEmpty ? 'Resource not found' : message,
            error,
            error.stackTrace,
          );

        case 408:
          return TimeoutException(
            message.isEmpty ? 'Request timeout' : message,
            error,
            error.stackTrace,
          );

        case 422:
          return ValidationException(
            message,
            _parseValidationErrors(error.response),
            error,
            error.stackTrace,
          );

        case 429:
          final retryAfter = _parseRetryAfter(error.response);
          return TooManyRequestsException(
            message.isEmpty
                ? 'Too many requests. Please try again later.'
                : message,
            retryAfter,
            error,
            error.stackTrace,
          );

        case 500:
        case 502:
        case 503:
        case 504:
          return ServerException(
            message.isEmpty ? 'Server error. Please try again later.' : message,
            statusCode,
            error,
            error.stackTrace,
          );

        default:
          if (statusCode >= 500) {
            return ServerException(
              message.isEmpty ? 'Server error occurred' : message,
              statusCode,
              error,
              error.stackTrace,
            );
          }
          return UnknownException(
            message.isEmpty ? 'An unexpected error occurred' : message,
            error,
            error.stackTrace,
          );
      }
    }

    // Handle other errors
    return UnknownException(
      error.message ?? 'An unexpected error occurred',
      error,
      error.stackTrace,
    );
  }

  /// Parse error message from response
  String _parseErrorMessage(Response? response) {
    try {
      if (response?.data == null) return '';

      final data = response!.data;

      // Try common error message fields
      if (data is Map<String, dynamic>) {
        if (data['message'] != null) {
          return data['message'].toString();
        }
        if (data['error'] != null) {
          if (data['error'] is String) {
            return data['error'] as String;
          }
          if (data['error'] is Map && data['error']['message'] != null) {
            return data['error']['message'].toString();
          }
        }
        if (data['errors'] != null && data['errors'] is List) {
          final errors = data['errors'] as List;
          if (errors.isNotEmpty) {
            return errors.first.toString();
          }
        }
      }

      // If data is a string, return it
      if (data is String) {
        return data;
      }
    } catch (_) {
      // Ignore parsing errors
    }

    return '';
  }

  /// Parse validation errors from response
  Map<String, dynamic>? _parseValidationErrors(Response? response) {
    try {
      if (response?.data == null) return null;

      final data = response!.data;

      if (data is Map<String, dynamic>) {
        // Check for 'errors' field (common in Laravel/Rails)
        if (data['errors'] != null && data['errors'] is Map) {
          return data['errors'] as Map<String, dynamic>;
        }

        // Check for 'validationErrors' field
        if (data['validationErrors'] != null &&
            data['validationErrors'] is Map) {
          return data['validationErrors'] as Map<String, dynamic>;
        }

        // Check for 'fields' field
        if (data['fields'] != null && data['fields'] is Map) {
          return data['fields'] as Map<String, dynamic>;
        }
      }
    } catch (_) {
      // Ignore parsing errors
    }

    return null;
  }

  /// Parse Retry-After header for 429 responses
  int? _parseRetryAfter(Response? response) {
    try {
      final retryAfter = response?.headers.value('retry-after');
      if (retryAfter != null) {
        return int.tryParse(retryAfter);
      }
    } catch (_) {
      // Ignore parsing errors
    }
    return null;
  }
}
