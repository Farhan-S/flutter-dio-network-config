import 'api_exceptions.dart';

/// Generic API response wrapper
class ApiResponse<T> {
  final T? data;
  final String? message;
  final int? statusCode;
  final Map<String, dynamic>? meta;

  ApiResponse({this.data, this.message, this.statusCode, this.meta});

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic json)? fromJsonT,
  ) {
    return ApiResponse<T>(
      data: json['data'] != null && fromJsonT != null
          ? fromJsonT(json['data'])
          : json['data'] as T?,
      message: json['message'] as String?,
      statusCode: json['statusCode'] as int? ?? json['status'] as int?,
      meta: json['meta'] as Map<String, dynamic>?,
    );
  }

  bool get isSuccess =>
      statusCode != null && statusCode! >= 200 && statusCode! < 300;
}

/// Result type for handling success and failure states
sealed class Result<T> {
  const Result();
}

/// Success result containing the value
class Success<T> extends Result<T> {
  final T value;
  const Success(this.value);
}

/// Failure result containing the error
class Failure<T> extends Result<T> {
  final ApiException error;
  const Failure(this.error);
}

/// Extension methods for Result type
extension ResultExtension<T> on Result<T> {
  /// Returns true if this is a Success result
  bool get isSuccess => this is Success<T>;

  /// Returns true if this is a Failure result
  bool get isFailure => this is Failure<T>;

  /// Gets the value if Success, otherwise null
  T? get valueOrNull => this is Success<T> ? (this as Success<T>).value : null;

  /// Gets the error if Failure, otherwise null
  ApiException? get errorOrNull =>
      this is Failure<T> ? (this as Failure<T>).error : null;

  /// Executes the appropriate callback based on the result type
  R when<R>({
    required R Function(T value) success,
    required R Function(ApiException error) failure,
  }) {
    if (this is Success<T>) {
      return success((this as Success<T>).value);
    } else {
      return failure((this as Failure<T>).error);
    }
  }

  /// Transforms the value if Success, otherwise returns the Failure
  Result<R> map<R>(R Function(T value) transform) {
    if (this is Success<T>) {
      return Success(transform((this as Success<T>).value));
    } else {
      return Failure((this as Failure<T>).error);
    }
  }
}
