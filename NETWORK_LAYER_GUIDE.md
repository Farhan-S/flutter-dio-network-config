# Network Layer Documentation

## Overview

This is a production-ready Dio network layer implementation following Clean Architecture principles for Flutter applications. It provides comprehensive HTTP client functionality with built-in error handling, retry logic, authentication, and multipart file uploads.

## Architecture

```
lib/core/
├── network/
│   ├── dio_client.dart              # Main HTTP client (singleton)
│   ├── network_config.dart          # Environment & configuration
│   ├── api_routes.dart              # Centralized API routes
│   ├── api_response.dart            # Response wrapper & Result type
│   ├── api_exceptions.dart          # Custom exception types
│   ├── interceptors/
│   │   ├── auth_interceptor.dart        # Add auth tokens
│   │   ├── refresh_token_interceptor.dart # Handle token refresh
│   │   ├── retry_interceptor.dart       # Retry with backoff
│   │   ├── error_interceptor.dart       # Map errors to exceptions
│   │   └── logging_interceptor.dart     # Debug logging
│   └── utils/
│       └── multipart_helper.dart    # File upload utilities
├── storage/
│   └── token_storage.dart           # Token management interface
└── services/
    ├── auth_service.dart            # Authentication operations
    └── user_service.dart            # User operations
```

## Features

### Core Features

- ✅ RESTful HTTP methods (GET, POST, PUT, PATCH, DELETE)
- ✅ Multipart/form-data file uploads (single & multiple)
- ✅ File downloads with progress tracking
- ✅ Request cancellation support
- ✅ Progress callbacks for uploads/downloads

### Error Handling

- ✅ Domain-friendly exception hierarchy
- ✅ Automatic DioError to ApiException conversion
- ✅ Validation error parsing
- ✅ Network connectivity errors
- ✅ Timeout handling

### Resilience

- ✅ Automatic retry with exponential backoff
- ✅ Configurable retry limits
- ✅ Jitter to prevent thundering herd

### Authentication

- ✅ Automatic token injection
- ✅ Token refresh with request queuing
- ✅ Prevents multiple simultaneous refreshes
- ✅ Secure token storage interface

### Development

- ✅ Debug logging (disabled in production)
- ✅ Environment configuration (dev/staging/prod)
- ✅ Easy to test & mock

---

## Setup

### 1. Initialize DioClient

The `DioClient` is a singleton and initializes automatically on first use:

```dart
final dioClient = DioClient();
```

### 2. Configure Token Refresh (Optional)

If your app uses refresh tokens, configure the refresh interceptor in your app initialization:

```dart
void main() {
  // Initialize DioClient
  final dioClient = DioClient();

  // Add refresh token logic
  dioClient.addRefreshTokenInterceptor(
    onRefresh: (refreshToken) async {
      // Call your refresh token endpoint
      final authService = AuthService();
      final result = await authService.refreshToken(refreshToken);

      return result.when(
        success: (data) => {
          'accessToken': data['access_token'],
          'refreshToken': data['refresh_token'],
        },
        failure: (error) => throw error,
      );
    },
  );

  runApp(MyApp());
}
```

### 3. Configure Token Storage

Replace the default in-memory token storage with secure storage:

```dart
// Install: flutter pub add flutter_secure_storage

// Uncomment and use SecureTokenStorage in token_storage.dart
// Then update the factory constructor:
factory TokenStorage() => SecureTokenStorage();
```

---

## Usage Examples

### Basic GET Request

```dart
final dioClient = DioClient();

try {
  final response = await dioClient.get(ApiRoutes.getUser);
  print('User data: ${response.data}');
} on ApiException catch (e) {
  print('Error: ${e.message}');
}
```

### POST Request with Data

```dart
try {
  final response = await dioClient.post(
    ApiRoutes.login,
    data: {
      'email': 'user@example.com',
      'password': 'password123',
    },
  );
  print('Login successful: ${response.data}');
} on ValidationException catch (e) {
  print('Validation errors: ${e.errors}');
} on UnauthorizedException catch (e) {
  print('Unauthorized: ${e.message}');
} on ApiException catch (e) {
  print('Error: ${e.message}');
}
```

### Using Services with Result Type

```dart
final authService = AuthService();

final result = await authService.login('user@example.com', 'password');

result.when(
  success: (data) {
    print('Login successful!');
    print('Access token: ${data['access_token']}');
  },
  failure: (error) {
    print('Login failed: ${error.message}');

    if (error is ValidationException) {
      print('Validation errors: ${error.errors}');
    }
  },
);
```

### Upload Single File

```dart
final file = File('/path/to/image.jpg');

try {
  final response = await dioClient.uploadFile(
    ApiRoutes.uploadFile,
    file: file,
    fieldName: 'avatar',
    additionalFields: {'user_id': '123'},
    onSendProgress: (sent, total) {
      final progress = (sent / total * 100).toStringAsFixed(0);
      print('Upload progress: $progress%');
    },
  );
  print('Upload complete: ${response.data}');
} on ApiException catch (e) {
  print('Upload failed: ${e.message}');
}
```

### Upload Multiple Files

```dart
final files = [
  File('/path/to/file1.jpg'),
  File('/path/to/file2.png'),
];

try {
  final response = await dioClient.uploadFiles(
    ApiRoutes.uploadMultiple,
    files: files,
    onSendProgress: (sent, total) {
      print('Uploaded: $sent / $total bytes');
    },
  );
} on ApiException catch (e) {
  print('Error: ${e.message}');
}
```

### Download File

```dart
try {
  await dioClient.downloadFile(
    ApiRoutes.downloadFile('file-id'),
    '/path/to/save/file.pdf',
    onReceiveProgress: (received, total) {
      if (total != -1) {
        final progress = (received / total * 100).toStringAsFixed(0);
        print('Download progress: $progress%');
      }
    },
  );
  print('Download complete!');
} on ApiException catch (e) {
  print('Download failed: ${e.message}');
}
```

### Request Cancellation

```dart
final cancelToken = CancelToken();

// Start request
dioClient.get(
  ApiRoutes.getUser,
  cancelToken: cancelToken,
).then((response) {
  print('Success: ${response.data}');
}).catchError((error) {
  if (CancelToken.isCancel(error)) {
    print('Request cancelled');
  }
});

// Cancel request (e.g., when user leaves screen)
cancelToken.cancel('User cancelled');
```

### Pattern Matching with Result

```dart
final userService = UserService();
final result = await userService.getCurrentUser();

// Using when method
final message = result.when(
  success: (user) => 'Welcome, ${user['name']}!',
  failure: (error) => 'Error: ${error.message}',
);

// Using isSuccess/isFailure
if (result.isSuccess) {
  final user = result.valueOrNull;
  print('User: $user');
} else {
  final error = result.errorOrNull;
  print('Error: ${error?.message}');
}

// Using map
final userName = result.map((user) => user['name'] as String);
```

---

## Exception Handling

### Exception Hierarchy

```dart
ApiException (base)
├── NetworkException         // No connection
├── TimeoutException         // Request timeout
├── CancelException          // Request cancelled
├── UnauthorizedException    // 401
├── ForbiddenException       // 403
├── NotFoundException        // 404
├── ValidationException      // 400, 422 (with error details)
├── TooManyRequestsException // 429 (with retry-after)
├── ServerException          // 5xx
└── UnknownException         // Unexpected errors
```

### Handling Specific Exceptions

```dart
try {
  final response = await dioClient.post(ApiRoutes.login, data: {...});
} on ValidationException catch (e) {
  // Handle validation errors
  print('Validation failed: ${e.message}');
  print('Field errors: ${e.errors}');

  // Display field-specific errors
  e.errors?.forEach((field, messages) {
    print('$field: $messages');
  });
} on UnauthorizedException catch (e) {
  // Redirect to login
  navigateToLogin();
} on NetworkException catch (e) {
  // Show offline message
  showSnackbar('No internet connection');
} on TimeoutException catch (e) {
  // Show timeout message
  showSnackbar('Request timed out. Please try again.');
} on ServerException catch (e) {
  // Show server error
  showSnackbar('Server error: ${e.code}');
} on ApiException catch (e) {
  // Handle all other errors
  showSnackbar(e.message);
}
```

---

## Configuration

### Environment Configuration

Edit `lib/core/network/network_config.dart`:

```dart
class NetworkConfig {
  static const String environment = String.fromEnvironment(
    'ENV',
    defaultValue: 'dev',
  );

  static const Map<String, String> _baseUrls = {
    'dev': 'https://api-dev.example.com',
    'staging': 'https://api-staging.example.com',
    'prod': 'https://api.example.com',
  };

  // Update timeouts and retry config as needed
  static const int connectTimeoutSeconds = 30;
  static const int maxRetries = 3;
}
```

Run with environment:

```bash
flutter run --dart-define=ENV=prod
flutter build apk --dart-define=ENV=staging
```

### Adding API Routes

Edit `lib/core/network/api_routes.dart`:

```dart
class ApiRoutes {
  static const v1 = '/api/v1';

  // Add your routes
  static const products = '$v1/products';
  static String productById(String id) => '$v1/products/$id';
  static const createOrder = '$v1/orders';
}
```

---

## Testing

### Mock DioClient

```dart
class MockDioClient extends Mock implements DioClient {}

void main() {
  late MockDioClient mockDioClient;
  late AuthService authService;

  setUp(() {
    mockDioClient = MockDioClient();
    authService = AuthService(dioClient: mockDioClient);
  });

  test('login returns success', () async {
    // Arrange
    when(mockDioClient.post(any, data: any))
      .thenAnswer((_) async => Response(
        data: {'access_token': 'token123'},
        statusCode: 200,
        requestOptions: RequestOptions(path: ''),
      ));

    // Act
    final result = await authService.login('user@test.com', 'pass');

    // Assert
    expect(result.isSuccess, true);
    expect(result.valueOrNull?['access_token'], 'token123');
  });
}
```

---

## Best Practices

1. **Always use Result type** in services for consistent error handling
2. **Handle specific exceptions** at the UI layer for better UX
3. **Use CancelToken** for requests that can be cancelled (search, etc.)
4. **Implement secure token storage** in production (flutter_secure_storage)
5. **Add retry logic only for safe operations** (GET, idempotent endpoints)
6. **Validate files before upload** using MultipartHelper validators
7. **Show progress for long operations** (uploads, downloads)
8. **Log errors** to crash reporting (Firebase Crashlytics, Sentry)

---

## Migration from Old Code

### Before

```dart
final response = await DioClient().post("auth/login", data: {...});
return response.data;
```

### After

```dart
final result = await AuthService().login(email, password);
return result.when(
  success: (data) => data,
  failure: (error) => throw error,
);
```

---

## Additional Resources

- [Dio Documentation](https://pub.dev/packages/dio)
- [Clean Architecture in Flutter](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)
- [Flutter Secure Storage](https://pub.dev/packages/flutter_secure_storage)

---

## Support

For issues or questions, please check the code comments or create an issue in your repository.
