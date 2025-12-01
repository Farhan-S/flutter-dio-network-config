import 'dart:async';

import 'package:dio/dio.dart';

import '../../storage/token_storage.dart';
import '../api_exceptions.dart';
import '../api_routes.dart';

/// Interceptor that handles token refresh when 401 is received
/// Queues requests while refreshing to avoid multiple refresh calls
class RefreshTokenInterceptor extends Interceptor {
  final Dio _dio;
  final TokenStorage _tokenStorage;
  final Future<Map<String, dynamic>> Function(String refreshToken)
  _refreshTokenCallback;

  bool _isRefreshing = false;
  final List<_QueuedRequest> _requestQueue = [];

  RefreshTokenInterceptor({
    required Dio dio,
    TokenStorage? tokenStorage,
    required Future<Map<String, dynamic>> Function(String refreshToken)
    refreshTokenCallback,
  }) : _dio = dio,
       _tokenStorage = tokenStorage ?? TokenStorage(),
       _refreshTokenCallback = refreshTokenCallback;

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final statusCode = err.response?.statusCode;
    final requestOptions = err.requestOptions;

    // Only handle 401 errors (unauthorized)
    if (statusCode != 401) {
      return handler.next(err);
    }

    // Skip refresh for refresh token endpoint itself
    if (requestOptions.path.contains(ApiRoutes.refreshToken)) {
      return handler.next(err);
    }

    // If not already refreshing, start refresh process
    if (!_isRefreshing) {
      _isRefreshing = true;

      try {
        // Get refresh token from storage
        final refreshToken = await _tokenStorage.getRefreshToken();

        if (refreshToken == null || refreshToken.isEmpty) {
          throw UnauthorizedException('No refresh token available');
        }

        // Call the refresh token callback (implemented by app)
        final tokens = await _refreshTokenCallback(refreshToken);

        // Save new tokens
        await _tokenStorage.saveAccessToken(tokens['accessToken'] as String);
        if (tokens['refreshToken'] != null) {
          await _tokenStorage.saveRefreshToken(
            tokens['refreshToken'] as String,
          );
        }

        _isRefreshing = false;

        // Retry the original request with new token
        final response = await _retryRequest(requestOptions);
        handler.resolve(response);

        // Process queued requests
        await _processQueue();
      } catch (e) {
        _isRefreshing = false;

        // Clear tokens on refresh failure
        await _tokenStorage.clearTokens();

        // Reject all queued requests
        _rejectQueue(
          UnauthorizedException('Session expired. Please login again.'),
        );

        // Continue with error
        handler.next(err);
      }
    } else {
      // Queue this request while refreshing
      _queueRequest(requestOptions, handler);
    }
  }

  /// Retry a failed request with updated tokens
  Future<Response> _retryRequest(RequestOptions requestOptions) async {
    final token = await _tokenStorage.getAccessToken();

    final options = Options(
      method: requestOptions.method,
      headers: {...requestOptions.headers, 'Authorization': 'Bearer $token'},
    );

    return _dio.request(
      requestOptions.path,
      data: requestOptions.data,
      queryParameters: requestOptions.queryParameters,
      options: options,
      cancelToken: requestOptions.cancelToken,
      onReceiveProgress: requestOptions.onReceiveProgress,
      onSendProgress: requestOptions.onSendProgress,
    );
  }

  /// Add request to queue
  void _queueRequest(RequestOptions request, ErrorInterceptorHandler handler) {
    final completer = Completer<Response>();
    _requestQueue.add(_QueuedRequest(request, completer, handler));

    completer.future.then(
      (response) => handler.resolve(response),
      onError: (error) => handler.reject(
        error is DioException
            ? error
            : DioException(requestOptions: request, error: error),
      ),
    );
  }

  /// Process all queued requests
  Future<void> _processQueue() async {
    final queue = List<_QueuedRequest>.from(_requestQueue);
    _requestQueue.clear();

    for (final item in queue) {
      try {
        final response = await _retryRequest(item.request);
        item.completer.complete(response);
      } catch (e) {
        item.completer.completeError(e);
      }
    }
  }

  /// Reject all queued requests with an error
  void _rejectQueue(ApiException error) {
    final queue = List<_QueuedRequest>.from(_requestQueue);
    _requestQueue.clear();

    for (final item in queue) {
      item.completer.completeError(error);
    }
  }
}

/// Internal class to hold queued requests
class _QueuedRequest {
  final RequestOptions request;
  final Completer<Response> completer;
  final ErrorInterceptorHandler handler;

  _QueuedRequest(this.request, this.completer, this.handler);
}
