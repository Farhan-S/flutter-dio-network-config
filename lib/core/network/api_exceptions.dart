/// Base API exception class
class ApiException implements Exception {
  final String message;
  final int? code;
  final dynamic originalError;
  final StackTrace? stackTrace;

  ApiException(this.message, [this.code, this.originalError, this.stackTrace]);

  @override
  String toString() => 'ApiException($code): $message';
}

/// Network connectivity exception
class NetworkException extends ApiException {
  NetworkException(
    String message, [
    dynamic originalError,
    StackTrace? stackTrace,
  ]) : super(message, null, originalError, stackTrace);
}

/// Server-side error exception (5xx)
class ServerException extends ApiException {
  ServerException(
    String message, [
    int? code,
    dynamic originalError,
    StackTrace? stackTrace,
  ]) : super(message, code, originalError, stackTrace);
}

/// Unauthorized exception (401)
class UnauthorizedException extends ApiException {
  UnauthorizedException(
    String message, [
    dynamic originalError,
    StackTrace? stackTrace,
  ]) : super(message, 401, originalError, stackTrace);
}

/// Forbidden exception (403)
class ForbiddenException extends ApiException {
  ForbiddenException(
    String message, [
    dynamic originalError,
    StackTrace? stackTrace,
  ]) : super(message, 403, originalError, stackTrace);
}

/// Resource not found exception (404)
class NotFoundException extends ApiException {
  NotFoundException(
    String message, [
    dynamic originalError,
    StackTrace? stackTrace,
  ]) : super(message, 404, originalError, stackTrace);
}

/// Validation error exception (400, 422)
class ValidationException extends ApiException {
  final Map<String, dynamic>? errors;

  ValidationException(
    String message, [
    this.errors,
    dynamic originalError,
    StackTrace? stackTrace,
  ]) : super(message, 400, originalError, stackTrace);

  @override
  String toString() {
    if (errors != null && errors!.isNotEmpty) {
      return 'ValidationException: $message\nErrors: $errors';
    }
    return 'ValidationException: $message';
  }
}

/// Request timeout exception
class TimeoutException extends ApiException {
  TimeoutException(
    String message, [
    dynamic originalError,
    StackTrace? stackTrace,
  ]) : super(message, 408, originalError, stackTrace);
}

/// Request cancelled exception
class CancelException extends ApiException {
  CancelException(
    String message, [
    dynamic originalError,
    StackTrace? stackTrace,
  ]) : super(message, null, originalError, stackTrace);
}

/// Too many requests exception (429)
class TooManyRequestsException extends ApiException {
  final int? retryAfterSeconds;

  TooManyRequestsException(
    String message, [
    this.retryAfterSeconds,
    dynamic originalError,
    StackTrace? stackTrace,
  ]) : super(message, 429, originalError, stackTrace);
}

/// Unknown/unexpected exception
class UnknownException extends ApiException {
  UnknownException(
    String message, [
    dynamic originalError,
    StackTrace? stackTrace,
  ]) : super(message, null, originalError, stackTrace);
}
