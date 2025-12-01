# Quick Start Guide

## 🚀 Get Started in 5 Minutes

### Step 1: Update Base URL

Edit `lib/core/network/network_config.dart`:

```dart
static const Map<String, String> _baseUrls = {
  'dev': 'https://your-api-dev.com',
  'staging': 'https://your-api-staging.com',
  'prod': 'https://your-api.com',
};
```

### Step 2: Add Your API Routes

Edit `lib/core/network/api_routes.dart`:

```dart
class ApiRoutes {
  static const v1 = '/api/v1';

  // Your routes here
  static const login = '$v1/auth/login';
  static const products = '$v1/products';
  static String productById(String id) => '$v1/products/$id';
}
```

### Step 3: Setup Token Refresh (Optional)

In `lib/main.dart`:

```dart
void main() {
  // Setup token refresh
  DioClient().addRefreshTokenInterceptor(
    onRefresh: (refreshToken) async {
      final authService = AuthService();
      final result = await authService.refreshToken(refreshToken);

      return result.when(
        success: (data) => {
          'accessToken': data['access_token'] as String,
          'refreshToken': data['refresh_token'] as String,
        },
        failure: (error) => throw error,
      );
    },
  );

  runApp(const MyApp());
}
```

### Step 4: Make Your First Request

```dart
import 'package:dio_network_config/core/network/dio_client.dart';
import 'package:dio_network_config/core/network/api_routes.dart';
import 'package:dio_network_config/core/network/api_exceptions.dart';

final dioClient = DioClient();

// Simple request
try {
  final response = await dioClient.get(ApiRoutes.products);
  print('Products: ${response.data}');
} on ApiException catch (e) {
  print('Error: ${e.message}');
}
```

### Step 5: Use Services with Result Pattern

```dart
import 'package:dio_network_config/core/services/auth_service.dart';

final authService = AuthService();

final result = await authService.login(
  'user@example.com',
  'password123',
);

result.when(
  success: (data) {
    print('Login successful!');
    print('Token: ${data['access_token']}');
    // Navigate to home screen
  },
  failure: (error) {
    print('Login failed: ${error.message}');
    // Show error message
  },
);
```

## 📝 Common Use Cases

### POST Request with Data

```dart
final response = await dioClient.post(
  ApiRoutes.createProduct,
  data: {
    'name': 'New Product',
    'price': 99.99,
    'description': 'Product description',
  },
);
```

### Upload File

```dart
import 'dart:io';

final file = File('/path/to/image.jpg');

await dioClient.uploadFile(
  ApiRoutes.uploadFile,
  file: file,
  additionalFields: {
    'title': 'My Image',
    'category': 'photos',
  },
  onSendProgress: (sent, total) {
    final progress = (sent / total * 100).toStringAsFixed(1);
    print('Upload progress: $progress%');
  },
);
```

### Handle Specific Errors

```dart
try {
  final response = await dioClient.post(ApiRoutes.register, data: userData);
} on ValidationException catch (e) {
  // Show validation errors
  print('Validation failed: ${e.message}');
  if (e.errors != null) {
    e.errors!.forEach((field, messages) {
      print('$field: $messages');
    });
  }
} on UnauthorizedException catch (e) {
  // Redirect to login
  navigateToLogin();
} on NetworkException catch (e) {
  // Show offline message
  showSnackbar('No internet connection');
} on ApiException catch (e) {
  // Handle other errors
  showSnackbar(e.message);
}
```

### Download File

```dart
await dioClient.downloadFile(
  'https://example.com/file.pdf',
  '/path/to/save/file.pdf',
  onReceiveProgress: (received, total) {
    if (total != -1) {
      final progress = (received / total * 100).toStringAsFixed(1);
      print('Download: $progress%');
    }
  },
);
```

### Cancel Request

```dart
final cancelToken = CancelToken();

// Start request
dioClient.get(ApiRoutes.products, cancelToken: cancelToken)
  .then((response) => print(response.data));

// Cancel later (e.g., when user leaves screen)
cancelToken.cancel('User navigated away');
```

## 🔐 Production Setup

### 1. Add Secure Storage

```bash
flutter pub add flutter_secure_storage
```

In `lib/core/storage/token_storage.dart`, uncomment `SecureTokenStorage` and update:

```dart
factory TokenStorage() => SecureTokenStorage();
```

### 2. Run with Environment

```bash
# Development
flutter run --dart-define=ENV=dev

# Staging
flutter run --dart-define=ENV=staging

# Production
flutter build apk --dart-define=ENV=prod
```

### 3. Add Error Tracking

```bash
flutter pub add firebase_crashlytics
```

```dart
try {
  await dioClient.get(ApiRoutes.products);
} on ApiException catch (e, stackTrace) {
  FirebaseCrashlytics.instance.recordError(e, stackTrace);
  rethrow;
}
```

## 📚 Next Steps

1. ✅ Read [NETWORK_LAYER_GUIDE.md](./NETWORK_LAYER_GUIDE.md) for complete documentation
2. ✅ Check [example_usage.dart](./lib/example_usage.dart) for more examples
3. ✅ Read [IMPLEMENTATION_SUMMARY.md](./IMPLEMENTATION_SUMMARY.md) for architecture overview
4. ✅ Customize `network_config.dart` for your needs
5. ✅ Add your API routes to `api_routes.dart`
6. ✅ Create your own service classes following `auth_service.dart` pattern

## 🆘 Need Help?

- Check the documentation files in the project root
- Run the example app to see all features in action
- Review the code comments in each file

## ✅ You're Ready!

Your network layer is now production-ready. Start building your app with confidence! 🎉
