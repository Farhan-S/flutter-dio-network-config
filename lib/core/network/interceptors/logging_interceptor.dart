import 'dart:developer' as developer;

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// Interceptor for logging HTTP requests and responses in debug mode
class LoggingInterceptor extends Interceptor {
  final bool logRequest;
  final bool logResponse;
  final bool logError;

  LoggingInterceptor({
    this.logRequest = true,
    this.logResponse = true,
    this.logError = true,
  });

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (kDebugMode && logRequest) {
      developer.log(
        '┌──────────────────────────────────────────────────────────',
        name: 'HTTP',
      );
      developer.log(
        '│ REQUEST ║ ${options.method} ${options.uri}',
        name: 'HTTP',
      );
      developer.log(
        '│ Headers: ${_formatHeaders(options.headers)}',
        name: 'HTTP',
      );

      if (options.queryParameters.isNotEmpty) {
        developer.log(
          '│ Query Parameters: ${options.queryParameters}',
          name: 'HTTP',
        );
      }

      if (options.data != null) {
        developer.log('│ Body: ${_formatBody(options.data)}', name: 'HTTP');
      }

      developer.log(
        '└──────────────────────────────────────────────────────────',
        name: 'HTTP',
      );
    }

    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (kDebugMode && logResponse) {
      developer.log(
        '┌──────────────────────────────────────────────────────────',
        name: 'HTTP',
      );
      developer.log(
        '│ RESPONSE ║ ${response.statusCode} ${response.requestOptions.method} ${response.requestOptions.uri}',
        name: 'HTTP',
      );
      developer.log(
        '│ Headers: ${_formatHeaders(response.headers.map)}',
        name: 'HTTP',
      );
      developer.log('│ Body: ${_formatBody(response.data)}', name: 'HTTP');
      developer.log(
        '└──────────────────────────────────────────────────────────',
        name: 'HTTP',
      );
    }

    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (kDebugMode && logError) {
      developer.log(
        '┌──────────────────────────────────────────────────────────',
        name: 'HTTP',
      );
      developer.log(
        '│ ERROR ║ ${err.requestOptions.method} ${err.requestOptions.uri}',
        name: 'HTTP',
      );
      developer.log('│ Type: ${err.type}', name: 'HTTP');
      developer.log('│ Message: ${err.message}', name: 'HTTP');

      if (err.response != null) {
        developer.log('│ Status: ${err.response?.statusCode}', name: 'HTTP');
        developer.log(
          '│ Response: ${_formatBody(err.response?.data)}',
          name: 'HTTP',
        );
      }

      developer.log(
        '└──────────────────────────────────────────────────────────',
        name: 'HTTP',
      );
    }

    handler.next(err);
  }

  /// Format headers for logging
  String _formatHeaders(Map<String, dynamic> headers) {
    final sanitized = Map<String, dynamic>.from(headers);

    // Hide sensitive headers
    if (sanitized.containsKey('Authorization')) {
      sanitized['Authorization'] = '***';
    }
    if (sanitized.containsKey('Cookie')) {
      sanitized['Cookie'] = '***';
    }

    return sanitized.toString();
  }

  /// Format body for logging (truncate if too long)
  String _formatBody(dynamic body) {
    if (body == null) return 'empty';

    final bodyStr = body.toString();
    const maxLength = 500;

    if (bodyStr.length > maxLength) {
      return '${bodyStr.substring(0, maxLength)}... (truncated)';
    }

    return bodyStr;
  }
}
