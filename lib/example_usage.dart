import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import 'core/network/api_exceptions.dart';
import 'core/network/api_response.dart';
import 'core/network/api_routes.dart';
import 'core/network/dio_client.dart';
import 'core/services/auth_service.dart';
import 'core/services/user_service.dart';
import 'core/storage/token_storage.dart';

/// Example usage of the network layer
/// This file demonstrates all major features

void main() {
  // Initialize app with network configuration
  initializeNetwork();

  runApp(const MyApp());
}

/// Initialize network layer with refresh token support
void initializeNetwork() {
  final dioClient = DioClient();

  // Configure token refresh interceptor
  dioClient.addRefreshTokenInterceptor(
    onRefresh: (refreshToken) async {
      // This is called when a 401 is received
      final authService = AuthService();
      final result = await authService.refreshToken(refreshToken);

      return result.when(
        success: (data) {
          // Return new tokens
          return {
            'accessToken': data['access_token'] as String,
            'refreshToken': data['refresh_token'] as String,
          };
        },
        failure: (error) {
          // If refresh fails, throw to logout user
          throw error;
        },
      );
    },
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dio Network Layer Demo',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const NetworkExamplesPage(),
    );
  }
}

class NetworkExamplesPage extends StatefulWidget {
  const NetworkExamplesPage({super.key});

  @override
  State<NetworkExamplesPage> createState() => _NetworkExamplesPageState();
}

class _NetworkExamplesPageState extends State<NetworkExamplesPage> {
  final _authService = AuthService();
  final _userService = UserService();
  final _dioClient = DioClient();

  String _output = 'Ready to test network features...';
  bool _loading = false;
  CancelToken? _cancelToken;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Network Layer Examples')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Output display
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _output,
                style: const TextStyle(fontFamily: 'monospace'),
              ),
            ),
            const SizedBox(height: 16),

            if (_loading) const LinearProgressIndicator(),
            const SizedBox(height: 16),

            // Example buttons
            _buildSection('Authentication Examples', [
              _buildButton('Login Example', _loginExample),
              _buildButton('Refresh Token Example', _refreshTokenExample),
              _buildButton('Logout Example', _logoutExample),
            ]),

            _buildSection('User Operations', [
              _buildButton('Get Current User', _getCurrentUserExample),
              _buildButton('Update User', _updateUserExample),
              _buildButton('Upload Avatar', _uploadAvatarExample),
            ]),

            _buildSection('Error Handling', [
              _buildButton('Handle 404 Error', _notFoundExample),
              _buildButton('Handle Validation Error', _validationErrorExample),
              _buildButton('Handle Network Error', _networkErrorExample),
              _buildButton('Handle Timeout', _timeoutExample),
            ]),

            _buildSection('Advanced Features', [
              _buildButton('Upload Multiple Files', _uploadMultipleExample),
              _buildButton('Download File', _downloadFileExample),
              _buildButton('Request with Progress', _progressExample),
              _buildButton('Cancellable Request', _cancellableRequestExample),
            ]),

            _buildSection('Result Pattern', [
              _buildButton('Using Result.when()', _resultWhenExample),
              _buildButton('Using Result.map()', _resultMapExample),
              _buildButton('Chain Results', _chainResultsExample),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        ...children,
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildButton(String label, VoidCallback onPressed) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: ElevatedButton(
        onPressed: _loading ? null : onPressed,
        child: Text(label),
      ),
    );
  }

  void _setOutput(String text) {
    setState(() => _output = text);
  }

  void _setLoading(bool loading) {
    setState(() => _loading = loading);
  }

  // ==================== Authentication Examples ====================

  Future<void> _loginExample() async {
    _setLoading(true);
    _setOutput('Attempting login...');

    final result = await _authService.login('user@example.com', 'password123');

    result.when(
      success: (data) {
        _setOutput('✅ Login successful!\n\nResponse:\n${_prettyJson(data)}');
        // Save tokens
        TokenStorage().saveAccessToken(data['access_token'] as String);
        if (data['refresh_token'] != null) {
          TokenStorage().saveRefreshToken(data['refresh_token'] as String);
        }
      },
      failure: (error) {
        var output = '❌ Login failed!\n\nError: ${error.message}';
        if (error is ValidationException && error.errors != null) {
          output += '\n\nValidation errors:\n${error.errors}';
        }
        _setOutput(output);
      },
    );

    _setLoading(false);
  }

  Future<void> _refreshTokenExample() async {
    _setLoading(true);
    _setOutput('Refreshing token...');

    final currentRefreshToken = await TokenStorage().getRefreshToken();
    if (currentRefreshToken == null) {
      _setOutput('❌ No refresh token found');
      _setLoading(false);
      return;
    }

    final result = await _authService.refreshToken(currentRefreshToken);

    result.when(
      success: (data) {
        _setOutput('✅ Token refreshed!\n\nNew token: ${data['access_token']}');
      },
      failure: (error) {
        _setOutput('❌ Refresh failed: ${error.message}');
      },
    );

    _setLoading(false);
  }

  Future<void> _logoutExample() async {
    _setLoading(true);
    _setOutput('Logging out...');

    final result = await _authService.logout();

    result.when(
      success: (_) {
        _setOutput('✅ Logged out successfully!');
        TokenStorage().clearTokens();
      },
      failure: (error) {
        _setOutput('❌ Logout failed: ${error.message}');
      },
    );

    _setLoading(false);
  }

  // ==================== User Examples ====================

  Future<void> _getCurrentUserExample() async {
    _setLoading(true);
    _setOutput('Fetching user data...');

    final result = await _userService.getCurrentUser();

    result.when(
      success: (user) {
        _setOutput('✅ User data:\n\n${_prettyJson(user)}');
      },
      failure: (error) {
        _setOutput('❌ Error: ${error.message}');
      },
    );

    _setLoading(false);
  }

  Future<void> _updateUserExample() async {
    _setLoading(true);
    _setOutput('Updating user...');

    final result = await _userService.updateUser({
      'name': 'John Doe',
      'email': 'john@example.com',
    });

    result.when(
      success: (user) {
        _setOutput('✅ User updated:\n\n${_prettyJson(user)}');
      },
      failure: (error) {
        _setOutput('❌ Update failed: ${error.message}');
      },
    );

    _setLoading(false);
  }

  Future<void> _uploadAvatarExample() async {
    _setLoading(true);
    _setOutput('Uploading avatar...');

    // In real app, pick file from gallery/camera
    // For demo, using a mock file path
    final file = File('/path/to/avatar.jpg');

    final result = await _userService.uploadAvatar(
      file,
      onProgress: (sent, total) {
        final progress = (sent / total * 100).toStringAsFixed(1);
        _setOutput('Uploading... $progress%');
      },
    );

    result.when(
      success: (data) {
        _setOutput('✅ Avatar uploaded:\n\n${_prettyJson(data)}');
      },
      failure: (error) {
        _setOutput('❌ Upload failed: ${error.message}');
      },
    );

    _setLoading(false);
  }

  // ==================== Error Handling Examples ====================

  Future<void> _notFoundExample() async {
    _setLoading(true);
    _setOutput('Requesting non-existent resource...');

    try {
      await _dioClient.get(ApiRoutes.userById('non-existent-id'));
      _setOutput('Request completed (unexpectedly)');
    } on NotFoundException catch (e) {
      _setOutput(
        '✅ Caught NotFoundException:\n\n${e.message}\nCode: ${e.code}',
      );
    } catch (e) {
      _setOutput('❌ Unexpected error: $e');
    }

    _setLoading(false);
  }

  Future<void> _validationErrorExample() async {
    _setLoading(true);
    _setOutput('Sending invalid data...');

    try {
      await _dioClient.post(
        ApiRoutes.register,
        data: {'email': 'invalid-email'}, // Missing required fields
      );
      _setOutput('Request completed (unexpectedly)');
    } on ValidationException catch (e) {
      var output = '✅ Caught ValidationException:\n\n${e.message}';
      if (e.errors != null) {
        output += '\n\nField errors:';
        e.errors!.forEach((field, errors) {
          output += '\n- $field: $errors';
        });
      }
      _setOutput(output);
    } catch (e) {
      _setOutput('❌ Unexpected error: $e');
    }

    _setLoading(false);
  }

  Future<void> _networkErrorExample() async {
    _setLoading(true);
    _setOutput('Simulating network error...');

    // Temporarily change base URL to invalid
    final originalUrl = _dioClient.dio.options.baseUrl;
    _dioClient.updateBaseUrl('https://invalid-domain-12345.com');

    try {
      await _dioClient.get('/test');
      _setOutput('Request completed (unexpectedly)');
    } on NetworkException catch (e) {
      _setOutput('✅ Caught NetworkException:\n\n${e.message}');
    } catch (e) {
      _setOutput('❌ Error: $e');
    } finally {
      _dioClient.updateBaseUrl(originalUrl);
    }

    _setLoading(false);
  }

  Future<void> _timeoutExample() async {
    _setLoading(true);
    _setOutput('Simulating timeout...');

    try {
      // Request with very short timeout
      await _dioClient.get(
        ApiRoutes.getUser,
        options: Options(
          sendTimeout: const Duration(milliseconds: 1),
          receiveTimeout: const Duration(milliseconds: 1),
        ),
      );
      _setOutput('Request completed (unexpectedly)');
    } on TimeoutException catch (e) {
      _setOutput('✅ Caught TimeoutException:\n\n${e.message}');
    } catch (e) {
      _setOutput('❌ Error: $e');
    }

    _setLoading(false);
  }

  // ==================== Advanced Examples ====================

  Future<void> _uploadMultipleExample() async {
    _setLoading(true);
    _setOutput('Uploading multiple files...');

    final files = [File('/path/to/file1.jpg'), File('/path/to/file2.png')];

    try {
      final response = await _dioClient.uploadFiles(
        ApiRoutes.uploadMultiple,
        files: files,
        additionalFields: {'category': 'photos'},
        onSendProgress: (sent, total) {
          final progress = (sent / total * 100).toStringAsFixed(1);
          _setOutput('Uploading... $progress%');
        },
      );
      _setOutput('✅ Files uploaded:\n\n${_prettyJson(response.data)}');
    } catch (e) {
      _setOutput('❌ Upload failed: $e');
    }

    _setLoading(false);
  }

  Future<void> _downloadFileExample() async {
    _setLoading(true);
    _setOutput('Downloading file...');

    try {
      await _dioClient.downloadFile(
        ApiRoutes.downloadFile('file-123'),
        '/tmp/downloaded_file.pdf',
        onReceiveProgress: (received, total) {
          if (total != -1) {
            final progress = (received / total * 100).toStringAsFixed(1);
            _setOutput('Downloading... $progress%');
          }
        },
      );
      _setOutput('✅ File downloaded to /tmp/downloaded_file.pdf');
    } catch (e) {
      _setOutput('❌ Download failed: $e');
    }

    _setLoading(false);
  }

  Future<void> _progressExample() async {
    _setLoading(true);
    _setOutput('Starting request with progress...');

    try {
      await _dioClient.get(
        ApiRoutes.getUser,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            final progress = (received / total * 100).toStringAsFixed(1);
            _setOutput(
              'Receiving data... $progress%\n$received / $total bytes',
            );
          }
        },
      );
      _setOutput('✅ Request completed!');
    } catch (e) {
      _setOutput('❌ Error: $e');
    }

    _setLoading(false);
  }

  Future<void> _cancellableRequestExample() async {
    _setLoading(true);
    _setOutput('Starting cancellable request...\n\nTap again to cancel!');

    _cancelToken = CancelToken();

    try {
      await Future.delayed(const Duration(seconds: 1)); // Delay to allow cancel

      final response = await _dioClient.get(
        ApiRoutes.getUser,
        cancelToken: _cancelToken,
      );
      _setOutput('✅ Request completed:\n\n${_prettyJson(response.data)}');
    } on CancelException {
      _setOutput('✅ Request cancelled successfully!');
    } on DioException catch (e) {
      if (CancelToken.isCancel(e)) {
        _setOutput('✅ Request cancelled!');
      } else {
        _setOutput('❌ Error: $e');
      }
    } catch (e) {
      _setOutput('❌ Error: $e');
    } finally {
      _cancelToken = null;
    }

    _setLoading(false);
  }

  // ==================== Result Pattern Examples ====================

  Future<void> _resultWhenExample() async {
    _setLoading(true);
    _setOutput('Demonstrating Result.when() pattern...');

    final result = await _userService.getCurrentUser();

    // Using when() for pattern matching
    final message = result.when(
      success: (user) => '✅ Success! User: ${user['name']}',
      failure: (error) => '❌ Failed! Error: ${error.message}',
    );

    _setOutput(message);
    _setLoading(false);
  }

  Future<void> _resultMapExample() async {
    _setLoading(true);
    _setOutput('Demonstrating Result.map() pattern...');

    final userResult = await _userService.getCurrentUser();

    // Transform the result data
    final nameResult = userResult.map((user) => user['name'] as String);

    nameResult.when(
      success: (name) => _setOutput('✅ User name: $name'),
      failure: (error) => _setOutput('❌ Error: ${error.message}'),
    );

    _setLoading(false);
  }

  Future<void> _chainResultsExample() async {
    _setLoading(true);
    _setOutput('Chaining multiple operations...');

    // Login -> Get User -> Update User
    final loginResult = await _authService.login('user@test.com', 'pass');

    if (loginResult.isFailure) {
      _setOutput('❌ Login failed: ${loginResult.errorOrNull?.message}');
      _setLoading(false);
      return;
    }

    final userResult = await _userService.getCurrentUser();

    if (userResult.isFailure) {
      _setOutput('❌ Get user failed: ${userResult.errorOrNull?.message}');
      _setLoading(false);
      return;
    }

    final updateResult = await _userService.updateUser({
      'name': 'Updated Name',
    });

    updateResult.when(
      success: (user) {
        _setOutput(
          '✅ All operations successful!\n\nFinal user:\n${_prettyJson(user)}',
        );
      },
      failure: (error) {
        _setOutput('❌ Update failed: ${error.message}');
      },
    );

    _setLoading(false);
  }

  // ==================== Utilities ====================

  String _prettyJson(dynamic json) {
    return json
        .toString()
        .replaceAll(', ', ',\n  ')
        .replaceAll('{', '{\n  ')
        .replaceAll('}', '\n}');
  }

  @override
  void dispose() {
    _cancelToken?.cancel();
    super.dispose();
  }
}
