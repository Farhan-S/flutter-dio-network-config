import 'dart:io';

import 'package:dio/dio.dart';

import 'api_exceptions.dart';
import 'interceptors/auth_interceptor.dart';
import 'interceptors/error_interceptor.dart';
import 'interceptors/logging_interceptor.dart';
import 'interceptors/refresh_token_interceptor.dart';
import 'interceptors/retry_interceptor.dart';
import 'network_config.dart';
import 'utils/multipart_helper.dart';

/// Main Dio client for making HTTP requests
/// Singleton pattern ensures single instance across the app
class DioClient {
  static final DioClient _instance = DioClient._internal();
  late final Dio dio;

  factory DioClient() => _instance;

  DioClient._internal() {
    // Configure Dio with base options
    final options = BaseOptions(
      baseUrl: NetworkConfig.baseUrl,
      connectTimeout: Duration(seconds: NetworkConfig.connectTimeoutSeconds),
      receiveTimeout: Duration(seconds: NetworkConfig.receiveTimeoutSeconds),
      sendTimeout: Duration(seconds: NetworkConfig.sendTimeoutSeconds),
      headers: NetworkConfig.defaultHeaders,
      validateStatus: (status) => status != null && status < 500,
    );

    dio = Dio(options);

    // Add interceptors in order (ORDER MATTERS!)
    _setupInterceptors();
  }

  /// Setup interceptors in correct order
  void _setupInterceptors() {
    dio.interceptors.addAll([
      LoggingInterceptor(), // Log requests/responses (debug only)
      AuthInterceptor(), // Add authentication token
      // Note: RefreshTokenInterceptor requires a callback, add it manually when needed
      RetryInterceptor(dio), // Retry failed requests
      ErrorInterceptor(), // Convert errors to ApiExceptions
    ]);
  }

  /// Add refresh token interceptor with custom refresh logic
  /// Call this once during app initialization
  void addRefreshTokenInterceptor({
    required Future<Map<String, dynamic>> Function(String refreshToken)
    onRefresh,
  }) {
    // Remove existing refresh interceptor if any
    dio.interceptors.removeWhere(
      (interceptor) => interceptor is RefreshTokenInterceptor,
    );

    // Add new refresh interceptor after auth interceptor
    final authInterceptorIndex = dio.interceptors.indexWhere(
      (interceptor) => interceptor is AuthInterceptor,
    );

    if (authInterceptorIndex != -1) {
      dio.interceptors.insert(
        authInterceptorIndex + 1,
        RefreshTokenInterceptor(dio: dio, refreshTokenCallback: onRefresh),
      );
    } else {
      dio.interceptors.add(
        RefreshTokenInterceptor(dio: dio, refreshTokenCallback: onRefresh),
      );
    }
  }

  // ==================== GET REQUEST ====================

  /// Make GET request
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      return await dio.get<T>(
        path,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onReceiveProgress: onReceiveProgress,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ==================== POST REQUEST ====================

  /// Make POST request
  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      return await dio.post<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ==================== PUT REQUEST ====================

  /// Make PUT request
  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      return await dio.put<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ==================== PATCH REQUEST ====================

  /// Make PATCH request
  Future<Response<T>> patch<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) async {
    try {
      return await dio.patch<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
        onReceiveProgress: onReceiveProgress,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ==================== DELETE REQUEST ====================

  /// Make DELETE request
  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    try {
      return await dio.delete<T>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
        cancelToken: cancelToken,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ==================== MULTIPART/FILE UPLOAD ====================

  /// Upload single file
  Future<Response<T>> uploadFile<T>(
    String path, {
    required File file,
    String fieldName = 'file',
    Map<String, dynamic>? additionalFields,
    String? customFileName,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
  }) async {
    try {
      final formData = await MultipartHelper.createSingleFileFormData(
        file: file,
        fieldName: fieldName,
        additionalFields: additionalFields,
        customFileName: customFileName,
      );

      return await dio.post<T>(
        path,
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Upload multiple files
  Future<Response<T>> uploadFiles<T>(
    String path, {
    required List<File> files,
    String fieldName = 'files',
    Map<String, dynamic>? additionalFields,
    List<String>? customFileNames,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
  }) async {
    try {
      final formData = await MultipartHelper.createMultipleFilesFormData(
        files: files,
        fieldName: fieldName,
        additionalFields: additionalFields,
        customFileNames: customFileNames,
      );

      return await dio.post<T>(
        path,
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// Upload with custom FormData
  Future<Response<T>> uploadFormData<T>(
    String path, {
    required FormData formData,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
  }) async {
    try {
      return await dio.post<T>(
        path,
        data: formData,
        options: Options(contentType: 'multipart/form-data'),
        cancelToken: cancelToken,
        onSendProgress: onSendProgress,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ==================== DOWNLOAD ====================

  /// Download file
  Future<Response> downloadFile(
    String urlPath,
    String savePath, {
    ProgressCallback? onReceiveProgress,
    CancelToken? cancelToken,
    Options? options,
  }) async {
    try {
      return await dio.download(
        urlPath,
        savePath,
        onReceiveProgress: onReceiveProgress,
        cancelToken: cancelToken,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ==================== HELPER METHODS ====================

  /// Handle Dio errors and extract ApiException
  ApiException _handleError(DioException error) {
    // ErrorInterceptor should have converted it to ApiException
    if (error.error is ApiException) {
      return error.error as ApiException;
    }
    // Fallback
    return UnknownException(
      error.message ?? 'An unexpected error occurred',
      error,
      error.stackTrace,
    );
  }

  /// Update base URL (useful for switching environments)
  void updateBaseUrl(String newBaseUrl) {
    dio.options.baseUrl = newBaseUrl;
  }

  /// Update headers
  void updateHeaders(Map<String, dynamic> headers) {
    dio.options.headers.addAll(headers);
  }

  /// Clear all interceptors
  void clearInterceptors() {
    dio.interceptors.clear();
  }

  /// Reset to default interceptors
  void resetInterceptors() {
    clearInterceptors();
    _setupInterceptors();
  }
}
