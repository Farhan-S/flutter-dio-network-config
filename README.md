# Dio Network Config - Production-Ready Network Layer

A comprehensive, production-ready Dio-based network layer for Flutter applications following Clean Architecture principles.

## ✨ Features

- ✅ **Clean Architecture** - Organized, scalable, and maintainable code structure
- ✅ **Complete HTTP Methods** - GET, POST, PUT, PATCH, DELETE
- ✅ **File Uploads** - Single & multiple file uploads with progress tracking
- ✅ **File Downloads** - With progress callbacks
- ✅ **Error Handling** - Domain-specific exceptions with detailed error information
- ✅ **Auto Retry** - Exponential backoff with jitter
- ✅ **Token Management** - Automatic token injection and refresh with request queuing
- ✅ **Request Cancellation** - Cancel ongoing requests with CancelToken
- ✅ **Environment Config** - Support for dev/staging/prod environments
- ✅ **Result Pattern** - Type-safe success/failure handling
- ✅ **Debug Logging** - Comprehensive logging (debug mode only)
- ✅ **Type-Safe Routes** - Centralized API route management
- ✅ **Progress Tracking** - Upload/download progress callbacks
- ✅ **Multipart Support** - Complete multipart form-data utilities

## 📁 Project Structure

```
lib/core/
├── network/
│   ├── dio_client.dart                    # Main HTTP client
│   ├── network_config.dart                # Configuration & environment
│   ├── api_routes.dart                    # Centralized routes
│   ├── api_response.dart                  # Response wrappers & Result type
│   ├── api_exceptions.dart                # Custom exceptions
│   ├── interceptors/
│   │   ├── auth_interceptor.dart         # Add auth tokens
│   │   ├── refresh_token_interceptor.dart # Token refresh + queue
│   │   ├── retry_interceptor.dart         # Auto retry with backoff
│   │   ├── error_interceptor.dart         # Error mapping
│   │   └── logging_interceptor.dart       # Debug logging
│   └── utils/
│       └── multipart_helper.dart          # File upload utilities
├── storage/
│   └── token_storage.dart                 # Token management
├── services/
│   ├── auth_service.dart                  # Auth operations
│   └── user_service.dart                  # User operations
└── routes/
    └── routes.dart                        # Re-exports api_routes
```

## 🚀 Quick Start

### 1. Installation

The project already includes Dio. No additional setup needed.

### 2. Initialize Network Layer

In your `main.dart`:

```dart
import 'package:dio_network_config/core/network/dio_client.dart';

void main() {
  // Initialize DioClient with refresh token support
  final dioClient = DioClient();

  dioClient.addRefreshTokenInterceptor(
    onRefresh: (refreshToken) async {
      // Your refresh token logic here
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

### 3. Basic Usage

```dart
import 'package:dio_network_config/core/network/dio_client.dart';
import 'package:dio_network_config/core/network/api_routes.dart';
import 'package:dio_network_config/core/network/api_exceptions.dart';

// Using DioClient directly
final dioClient = DioClient();

try {
  final response = await dioClient.get(ApiRoutes.getUser);
  print(response.data);
} on UnauthorizedException catch (e) {
  // Handle 401
} on NetworkException catch (e) {
  // Handle network errors
} on ApiException catch (e) {
  // Handle other errors
}

// Using Services with Result pattern
final authService = AuthService();
final result = await authService.login('email@example.com', 'password');

result.when(
  success: (data) => print('Login successful: $data'),
  failure: (error) => print('Login failed: ${error.message}'),
);
```

## 📖 Documentation

For detailed documentation, examples, and best practices, see:

- **[NETWORK_LAYER_GUIDE.md](./NETWORK_LAYER_GUIDE.md)** - Complete guide with all features and examples
- **[example_usage.dart](./lib/example_usage.dart)** - Interactive examples of all features

## 🔑 Key Concepts

### Result Pattern

Type-safe way to handle success/failure states:

```dart
final result = await userService.getCurrentUser();

// Pattern matching
result.when(
  success: (user) => showUser(user),
  failure: (error) => showError(error.message),
);

// Properties
if (result.isSuccess) {
  final user = result.valueOrNull;
}

// Transform
final nameResult = result.map((user) => user['name']);
```

### Exception Hierarchy

```dart
ApiException (base)
├── NetworkException         // No connection
├── TimeoutException         // Request timeout
├── CancelException          // Request cancelled
├── UnauthorizedException    // 401
├── ForbiddenException       // 403
├── NotFoundException        // 404
├── ValidationException      // 400, 422 + field errors
├── TooManyRequestsException // 429 + retry-after
├── ServerException          // 5xx
└── UnknownException         // Unexpected
```

### File Uploads

```dart
// Single file
await dioClient.uploadFile(
  ApiRoutes.uploadFile,
  file: File('/path/to/image.jpg'),
  onSendProgress: (sent, total) {
    print('Progress: ${sent / total * 100}%');
  },
);

// Multiple files
await dioClient.uploadFiles(
  ApiRoutes.uploadMultiple,
  files: [File('file1.jpg'), File('file2.png')],
  additionalFields: {'category': 'photos'},
);
```

### Request Cancellation

```dart
final cancelToken = CancelToken();

dioClient.get(ApiRoutes.getUser, cancelToken: cancelToken)
  .then((response) => print(response.data))
  .catchError((e) {
    if (CancelToken.isCancel(e)) {
      print('Request cancelled');
    }
  });

// Cancel when needed
cancelToken.cancel('User cancelled');
```

## ⚙️ Configuration

### Environment Setup

Edit `lib/core/network/network_config.dart`:

```dart
static const Map<String, String> _baseUrls = {
  'dev': 'https://api-dev.example.com',
  'staging': 'https://api-staging.example.com',
  'prod': 'https://api.example.com',
};
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
  static const products = '$v1/products';
  static String productById(String id) => '$v1/products/$id';
}
```

### Token Storage

The default implementation uses in-memory storage. For production, implement secure storage:

```dart
// 1. Add dependency
// flutter pub add flutter_secure_storage

// 2. Uncomment SecureTokenStorage in token_storage.dart

// 3. Update factory constructor:
factory TokenStorage() => SecureTokenStorage();
```

## 🧪 Testing

```dart
import 'package:mockito/mockito.dart';

class MockDioClient extends Mock implements DioClient {}

void main() {
  test('login success', () async {
    final mockClient = MockDioClient();
    final authService = AuthService(dioClient: mockClient);

    when(mockClient.post(any, data: any))
      .thenAnswer((_) async => Response(
        data: {'access_token': 'token'},
        statusCode: 200,
        requestOptions: RequestOptions(path: ''),
      ));

    final result = await authService.login('user@test.com', 'pass');

    expect(result.isSuccess, true);
  });
}
```

## 📝 Best Practices

1. **Always use Result type** for service methods
2. **Handle specific exceptions** for better UX
3. **Use CancelToken** for cancellable operations
4. **Implement secure token storage** in production
5. **Add retry only for idempotent operations**
6. **Show progress for long operations**
7. **Log errors to crash reporting services**

## 🤝 Contributing

This is a template/example project demonstrating clean architecture for network layers in Flutter. Feel free to adapt it to your needs.

## 📄 License

This project is provided as-is for educational and development purposes.

---

Made with ❤️ for Flutter developers building scalable applications.
