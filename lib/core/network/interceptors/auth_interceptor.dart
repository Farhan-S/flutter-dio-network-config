import 'package:dio/dio.dart';

import '../../storage/token_storage.dart';

/// Interceptor that adds authentication token to requests
class AuthInterceptor extends Interceptor {
  final TokenStorage _tokenStorage;

  AuthInterceptor([TokenStorage? tokenStorage])
    : _tokenStorage = tokenStorage ?? TokenStorage();

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    try {
      // Get access token from storage
      final token = await _tokenStorage.getAccessToken();

      if (token != null && token.isNotEmpty) {
        // Add Bearer token to Authorization header
        options.headers['Authorization'] = 'Bearer $token';
      }

      // Continue with the request
      handler.next(options);
    } catch (e) {
      // If token retrieval fails, continue without token
      handler.next(options);
    }
  }
}
