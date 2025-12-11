# Flutter Dio Network Config - Complete Documentation

A production-ready Flutter application template featuring **Clean Architecture**, **BLoC State Management**, and **Advanced Networking** with Dio. This template provides a scalable foundation for building enterprise-grade Flutter applications with proper separation of concerns, testability, and maintainability.

---

## 📋 Table of Contents

- [Overview](#overview)
- [Architecture](#architecture)
- [Project Structure](#project-structure)
- [Core Features](#core-features)
- [Network Layer](#network-layer)
- [State Management](#state-management)
- [Storage Layer](#storage-layer)
- [Routing & Navigation](#routing--navigation)
- [Dependency Injection](#dependency-injection)
- [Getting Started](#getting-started)
- [Development Guidelines](#development-guidelines)

---

## 🎯 Overview

This template demonstrates best practices for Flutter app development with a focus on:

- **Clean Architecture** - Clear separation between Presentation, Domain, and Data layers
- **Feature-First Structure** - Modular packages for each feature (auth, home, user, etc.)
- **Advanced Networking** - Dio with custom interceptors for logging, retry, error handling, and token refresh
- **State Management** - BLoC pattern with reactive UI updates
- **Persistent Storage** - Secure token storage and theme/locale persistence
- **Type-Safe Routing** - go_router with authentication guards and deep linking
- **Dependency Injection** - GetIt for centralized dependency management
- **Monorepo Setup** - Melos for managing multiple packages

---

## 🏗️ Architecture

This project follows **Clean Architecture** principles with three distinct layers:

```
┌─────────────────────────────────────────────────────┐
│                 Presentation Layer                  │
│  (UI, Pages, Widgets, BLoC/Cubit)                  │
└─────────────────┬───────────────────────────────────┘
                  │
                  │ Events/States
                  ↓
┌─────────────────────────────────────────────────────┐
│                   Domain Layer                      │
│  (Entities, Use Cases, Repository Interfaces)      │
└─────────────────┬───────────────────────────────────┘
                  │
                  │ Entities/Failures
                  ↓
┌─────────────────────────────────────────────────────┐
│                    Data Layer                       │
│  (Models, Data Sources, Repository Implementations)│
└─────────────────────────────────────────────────────┘
```

### Layer Responsibilities

#### 🎨 Presentation Layer

- **Pages**: Full-screen UI components
- **Widgets**: Reusable UI components
- **BLoC/Cubit**: Business logic and state management
- **Dependency**: Only depends on Domain layer

#### 🎯 Domain Layer

- **Entities**: Core business models (immutable, framework-independent)
- **Use Cases**: Single-responsibility business operations
- **Repository Interfaces**: Contracts for data access
- **Dependency**: No dependencies on other layers

#### 💾 Data Layer

- **Models**: Data transfer objects (DTO) with JSON serialization
- **Data Sources**: Remote (API) and Local (Database/Storage) implementations
- **Repository Implementations**: Concrete implementations of domain interfaces
- **Dependency**: Depends on Domain layer

---

## 📁 Project Structure

```
dio_network_config/
├── melos.yaml                      # Monorepo configuration
├── pubspec.yaml                    # Root dependencies
├── bootstrap.dart                  # Bootstrap script for dependencies
│
└── packages/
    ├── app/                        # Main application
    │   ├── lib/
    │   │   ├── main.dart          # App entry point
    │   │   ├── injection_container.dart  # DI setup
    │   │   └── routes/
    │   │       └── app_router.dart       # Router configuration
    │   └── pubspec.yaml
    │
    ├── core/                       # Shared core utilities
    │   ├── lib/
    │   │   └── src/
    │   │       ├── network/       # Networking layer
    │   │       │   ├── dio_client.dart
    │   │       │   ├── api_exceptions.dart
    │   │       │   ├── network_config.dart
    │   │       │   └── interceptors/
    │   │       │       ├── logging_interceptor.dart
    │   │       │       ├── error_interceptor.dart
    │   │       │       ├── auth_interceptor.dart
    │   │       │       ├── retry_interceptor.dart
    │   │       │       └── refresh_token_interceptor.dart
    │   │       ├── storage/       # Storage abstractions
    │   │       │   ├── token_storage.dart
    │   │       │   ├── theme_storage.dart
    │   │       │   └── locale_storage.dart
    │   │       ├── theme/         # Theme configuration
    │   │       │   ├── app_theme.dart
    │   │       │   └── theme_provider.dart
    │   │       ├── localization/  # Internationalization
    │   │       │   └── localization_bloc.dart
    │   │       └── routes/        # Route constants
    │   │           ├── app_routes.dart
    │   │           └── api_routes.dart
    │   └── pubspec.yaml
    │
    ├── features_auth/              # Authentication feature
    │   ├── lib/
    │   │   ├── data/
    │   │   │   ├── datasources/
    │   │   │   │   └── remote/
    │   │   │   │       ├── auth_remote_datasource.dart
    │   │   │   │       └── auth_mock_datasource.dart
    │   │   │   ├── models/
    │   │   │   │   └── auth_token_model.dart
    │   │   │   └── repositories/
    │   │   │       └── auth_repository_impl.dart
    │   │   ├── domain/
    │   │   │   ├── entities/
    │   │   │   │   └── auth_token_entity.dart
    │   │   │   ├── repositories/
    │   │   │   │   └── auth_repository.dart
    │   │   │   └── usecases/
    │   │   │       ├── login_usecase.dart
    │   │   │       ├── logout_usecase.dart
    │   │   │       └── get_current_user_usecase.dart
    │   │   └── presentation/
    │   │       ├── bloc/
    │   │       │   ├── auth_bloc.dart
    │   │       │   ├── auth_event.dart
    │   │       │   └── auth_state.dart
    │   │       ├── pages/
    │   │       │   └── login_page.dart
    │   │       └── widgets/
    │   └── pubspec.yaml
    │
    ├── features_home/              # Home feature
    ├── features_user/              # User profile feature
    ├── features_splash/            # Splash screen feature
    └── features_onboarding/        # Onboarding feature
```

---

## ⚡ Core Features

### 1. **Clean Architecture Implementation**

- Strict separation of concerns across layers
- Dependency rule: outer layers depend on inner layers, never the reverse
- Framework-independent domain layer for maximum testability

### 2. **Feature-First Package Organization**

- Each feature is a separate Dart package
- Features are independently testable and reusable
- Shared code lives in the `core` package

### 3. **Type-Safe Error Handling**

- Custom `ApiException` hierarchy for domain-specific errors
- `Either<Failure, Success>` pattern using dartz for functional error handling
- Comprehensive error mapping from network to domain layer

### 4. **Persistent State Management**

- Authentication state persists across app restarts
- Theme and locale preferences saved automatically
- Secure token storage using FlutterSecureStorage

### 5. **Network Testing Suite**

- Built-in network test feature demonstrating all HTTP methods
- Real-time progress updates during test execution
- Error handling demonstrations for various scenarios

---

## 🌐 Network Layer

### DioClient Architecture

The `DioClient` is a singleton wrapper around Dio providing:

```dart
DioClient() // Singleton instance
  └── Dio with BaseOptions
      ├── Base URL (environment-based)
      ├── Timeout configuration
      ├── Default headers
      └── Interceptor chain
          ├── 1. LoggingInterceptor     // Request/response logging
          ├── 2. AuthInterceptor        // Add Bearer token
          ├── 3. RefreshTokenInterceptor // Auto token refresh
          ├── 4. RetryInterceptor       // Retry failed requests
          └── 5. ErrorInterceptor       // Map errors to exceptions
```

### HTTP Methods Support

```dart
// GET Request
final response = await dioClient.get('/posts');

// GET with Query Parameters
final response = await dioClient.get('/posts', queryParameters: {'userId': 1});

// POST Request
final response = await dioClient.post('/posts', data: {'title': 'New Post'});

// PUT Request
final response = await dioClient.put('/posts/1', data: {'title': 'Updated'});

// DELETE Request
final response = await dioClient.delete('/posts/1');

// File Upload
final response = await dioClient.uploadFile('/upload',
  filePath: '/path/to/file.jpg',
  fileKey: 'image'
);

// Download File
await dioClient.downloadFile('/files/doc.pdf', '/save/path.pdf');
```

### Interceptors Explained

#### 1. **LoggingInterceptor**

- Logs all requests and responses in debug mode
- Pretty-prints JSON for readability
- Non-blocking: continues request flow immediately

```dart
📤 REQUEST[GET] => /posts?userId=1
Headers: {Authorization: Bearer token...}

📥 RESPONSE[200] <= /posts (345ms)
Data: [{"id": 1, "title": "Post"}]
```

#### 2. **AuthInterceptor**

- Automatically adds Authorization header to requests
- Retrieves access token from secure storage
- Skips for public endpoints (login, register)

```dart
// Automatically adds:
headers['Authorization'] = 'Bearer $accessToken'
```

#### 3. **RefreshTokenInterceptor**

- Detects 401 Unauthorized responses
- Automatically refreshes the access token
- Retries the original request with new token
- Prevents multiple simultaneous refresh attempts

**Flow:**

```
Request → 401 Response → Refresh Token → Retry Request → Success
```

#### 4. **RetryInterceptor**

- Retries failed requests due to network issues
- Exponential backoff: 500ms, 1s, 2s...
- Configurable max retries (default: 3)
- Adds jitter to prevent thundering herd

**Retries on:**

- Connection timeouts
- Server errors (5xx)
- Rate limiting (429)
- Request timeout (408)

#### 5. **ErrorInterceptor**

- Converts DioException to domain-specific ApiException
- Maps HTTP status codes to exception types
- Extracts error messages from response body

**Exception Hierarchy:**

```dart
ApiException (abstract)
  ├── NetworkException         // No internet connection
  ├── TimeoutException         // Request timeout
  ├── UnauthorizedException    // 401
  ├── ForbiddenException       // 403
  ├── NotFoundException        // 404
  ├── ValidationException      // 400, 422
  ├── ServerException          // 5xx
  ├── TooManyRequestsException // 429
  └── UnknownException         // Unexpected errors
```

### Environment Configuration

Configure different environments in `NetworkConfig`:

```dart
class NetworkConfig {
  static const Map<String, String> _baseUrls = {
    'dev': 'https://dev-api.example.com',
    'staging': 'https://staging-api.example.com',
    'prod': 'https://api.example.com',
  };

  // Currently using JSONPlaceholder for demo
  static String get baseUrl => _baseUrls[environment]!;

  static const int connectTimeoutSeconds = 30;
  static const int receiveTimeoutSeconds = 30;
  static const int maxRetries = 3;
}
```

Run with specific environment:

```bash
flutter run --dart-define=ENV=prod
```

---

## 🎭 State Management

### BLoC Pattern Implementation

This template uses **BLoC (Business Logic Component)** for predictable state management:

```dart
UI Event → BLoC → Use Case → Repository → Data Source
   ↑                                           ↓
   └──────────── State Update ←────────────────┘
```

### BLoC Types

#### 1. **Singleton BLoCs** (Persistent State)

For app-wide state that should persist:

- `AuthBloc` - Authentication state
- `LocalizationBloc` - Language preferences
- `ThemeCubit` - Theme mode (light/dark/system)

```dart
// Registered as singleton in DI
getIt.registerLazySingleton<AuthBloc>(() => AuthBloc(...));

// Used globally with BlocProvider.value
BlocProvider<AuthBloc>.value(
  value: getIt<AuthBloc>(),
  child: MaterialApp(...),
)
```

#### 2. **Factory BLoCs** (Page-Specific)

For feature-specific state that resets on navigation:

- `HomeBloc` - Home page data
- `NetworkTestBloc` - Network test execution

```dart
// Registered as factory in DI
getIt.registerFactory<HomeBloc>(() => HomeBloc(...));

// Created per page
BlocProvider(
  create: (_) => getIt<HomeBloc>()..add(LoadHomeDataEvent()),
  child: HomePage(),
)
```

### State Persistence

States are persisted using storage layers:

```dart
// Authentication State
AuthBloc checks token on app start:
AuthCheckRequested → TokenStorage.getAccessToken() → AuthAuthenticated

// Theme State
ThemeCubit auto-loads on creation:
ThemeCubit() → ThemeStorage.getSavedThemeMode() → emit(ThemeMode.dark)

// Locale State
LocalizationBloc restores language:
LoadSavedLocale → LocaleStorage.getSavedLocale() → LocaleLoaded(Locale('en'))
```

### Reactive UI Updates

The template demonstrates progressive UI updates with the Network Test feature:

```dart
// Emit state after each test completion
await runNetworkTestsUseCase(
  onTestComplete: (testResult) {
    completedResults.add(testResult);
    emit(NetworkTestRunning(
      currentResults: List.from(completedResults),
      completedCount: completedResults.length,
    ));
  },
);

// UI automatically rebuilds on each state change
BlocBuilder<NetworkTestBloc, NetworkTestState>(
  builder: (context, state) {
    if (state is NetworkTestRunning) {
      return ProgressIndicator(
        progress: state.completedCount / state.totalCount,
      );
    }
    return TestResults(tests: state.results);
  },
)
```

---

## 💾 Storage Layer

### Token Storage (Secure)

Uses `FlutterSecureStorage` for encrypted token storage:

```dart
abstract class TokenStorage {
  Future<void> saveAccessToken(String token);
  Future<void> saveRefreshToken(String token);
  Future<String?> getAccessToken();
  Future<String?> getRefreshToken();
  Future<void> clearTokens();
  Future<bool> isAuthenticated();
}

// Implementation
class SecureTokenStorage implements TokenStorage {
  final FlutterSecureStorage _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );

  // Tokens stored encrypted on device
  // Android: EncryptedSharedPreferences
  // iOS: Keychain
}
```

### Theme Storage (Preferences)

Uses `SharedPreferences` for theme preferences:

```dart
class ThemeStorage {
  Future<void> saveThemeMode(ThemeMode mode);
  Future<ThemeMode?> getSavedThemeMode();
}

// Usage
await themeStorage.saveThemeMode(ThemeMode.dark);
final theme = await themeStorage.getSavedThemeMode(); // ThemeMode.dark
```

### Locale Storage (Preferences)

```dart
class LocaleStorage {
  Future<void> saveLocale(Locale locale);
  Future<Locale?> getSavedLocale();
}
```

---

## 🧭 Routing & Navigation

### go_router Configuration

Type-safe routing with authentication guards:

```dart
GoRouter(
  initialLocation: '/splash',
  refreshListenable: GoRouterRefreshStream(authBloc.stream),
  redirect: (context, state) {
    final authState = authBloc.state;
    final isAuthenticated = authState is AuthAuthenticated;

    // Public routes: splash, onboarding, login
    // Protected routes: home, profile, settings

    if (!isAuthenticated && state.matchedLocation != '/login') {
      return '/login'; // Redirect to login
    }
    return null; // Allow navigation
  },
  routes: [...],
)
```

### Route Definitions

All routes defined in `AppRoutes`:

```dart
class AppRoutes {
  // Route names
  static const String home = 'home';
  static const String login = 'login';
  static const String profile = 'profile';

  // Route paths
  static const String homePath = '/home';
  static const String loginPath = '/login';
  static const String profilePath = '/profile/:userId';

  // Navigation helpers
  static void goHome(BuildContext context) => context.go(homePath);
  static void goToProfile(BuildContext context, String userId) {
    context.go('/profile/$userId');
  }
}
```

### Deep Linking Support

Routes automatically support deep links:

- `myapp://home` → Home page
- `myapp://profile/123` → User profile with ID 123

---

## 💉 Dependency Injection

### GetIt Setup

Centralized DI configuration in `injection_container.dart`:

```dart
final getIt = GetIt.instance;

Future<void> setupDependencyInjection() async {
  // ===== Core Layer =====
  final sharedPreferences = await SharedPreferences.getInstance();
  getIt.registerLazySingleton<SharedPreferences>(() => sharedPreferences);
  getIt.registerLazySingleton<TokenStorage>(() => SecureTokenStorage());
  getIt.registerLazySingleton<DioClient>(() => DioClient());

  // ===== Data Layer =====
  getIt.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSource(getIt<DioClient>()),
  );

  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: getIt<AuthRemoteDataSource>(),
      tokenStorage: getIt<TokenStorage>(),
    ),
  );

  // ===== Domain Layer =====
  getIt.registerLazySingleton<LoginUseCase>(
    () => LoginUseCase(getIt<AuthRepository>()),
  );

  // ===== Presentation Layer =====
  // Singleton for persistent state
  getIt.registerLazySingleton<AuthBloc>(
    () => AuthBloc(
      loginUseCase: getIt<LoginUseCase>(),
      logoutUseCase: getIt<LogoutUseCase>(),
      getCurrentUserUseCase: getIt<GetCurrentUserUseCase>(),
    ),
  );

  // Factory for page-specific state
  getIt.registerFactory<HomeBloc>(() => HomeBloc());
}
```

### Registration Patterns

**LazySingleton** - Created once when first accessed:

```dart
getIt.registerLazySingleton<T>(() => Implementation());
```

Use for: Core services, repositories, persistent BLoCs

**Singleton** - Created immediately during setup:

```dart
getIt.registerSingleton<T>(Implementation());
```

Use for: Initialized async resources

**Factory** - New instance every time:

```dart
getIt.registerFactory<T>(() => Implementation());
```

Use for: Page-specific BLoCs, transient objects

---

## 🚀 Getting Started

### Prerequisites

- Flutter SDK 3.9.2 or higher
- Dart SDK 3.9.2 or higher
- Melos CLI (optional but recommended)

### Installation

1. **Clone the repository:**

```bash
git clone https://github.com/yourusername/dio_network_config.git
cd dio_network_config
```

2. **Install Melos (recommended):**

```bash
dart pub global activate melos
```

3. **Bootstrap all packages:**

```bash
# Using Melos
melos bootstrap

# OR using the bootstrap script
dart bootstrap.dart

# OR manually
cd packages/app && flutter pub get
cd packages/core && flutter pub get
cd packages/features_auth && flutter pub get
# ... repeat for all packages
```

### Running the App

```bash
# Using Melos
melos run:app

# OR using Flutter directly
cd packages/app
flutter run

# Run with specific environment
flutter run --dart-define=ENV=prod
```

### Available Melos Commands

```bash
melos bootstrap    # Get dependencies for all packages
melos clean       # Clean all packages
melos analyze     # Analyze all packages
melos format      # Format all Dart code
melos test        # Run tests in all packages
melos run:app     # Run the main application
```

---

## 📚 Development Guidelines

For detailed instructions on:

- Creating new features
- Implementing data fetching
- Managing state with BLoC
- Creating new pages and routes
- Error handling patterns
- Testing strategies

**See [DEVELOPMENT_GUIDELINES.md](DEVELOPMENT_GUIDELINES.md)**

---

## 🏗️ Key Architectural Decisions

### Why Clean Architecture?

- **Testability**: Domain layer is framework-independent
- **Flexibility**: Easy to swap data sources (mock vs. real API)
- **Maintainability**: Clear separation of concerns
- **Scalability**: New features don't affect existing code

### Why BLoC?

- **Predictability**: Unidirectional data flow
- **Testability**: Business logic separate from UI
- **Reactivity**: Automatic UI updates on state changes
- **Debugging**: Event/state logging for easy debugging

### Why Monorepo with Melos?

- **Code Sharing**: Shared core package across features
- **Consistency**: Unified dependency versions
- **Efficiency**: Single command to manage all packages
- **Modularity**: Features can be independently tested/published

### Why GetIt?

- **Simplicity**: Straightforward service locator pattern
- **Performance**: Fast lookup with compile-time safety
- **Flexibility**: Supports singletons, factories, and scoped instances
- **No Magic**: Explicit registration, no code generation

---

## 🔐 Security Features

- **Encrypted Token Storage**: FlutterSecureStorage for sensitive data
- **HTTPS Only**: All network requests use HTTPS
- **Token Refresh**: Automatic token renewal before expiration
- **Request Signing**: Can add request signatures in interceptors
- **Certificate Pinning**: Configurable in DioClient

---

## 🧪 Testing Strategy

### Unit Tests

```dart
// Domain Layer - Use Cases
test('LoginUseCase should return token on success', () async {
  final result = await loginUseCase(email: 'test@example.com', password: 'pass');
  expect(result.isRight(), true);
});

// BLoC Tests
blocTest<AuthBloc, AuthState>(
  'emits [AuthLoading, AuthAuthenticated] when login succeeds',
  build: () => AuthBloc(loginUseCase: mockLoginUseCase),
  act: (bloc) => bloc.add(AuthLoginRequested(email: '...', password: '...')),
  expect: () => [AuthLoading(), AuthAuthenticated(user)],
);
```

### Widget Tests

```dart
testWidgets('LoginPage should show login form', (tester) async {
  await tester.pumpWidget(MaterialApp(home: LoginPage()));
  expect(find.byType(TextFormField), findsNWidgets(2));
  expect(find.text('Login'), findsOneWidget);
});
```

### Integration Tests

```dart
testWidgets('Full login flow', (tester) async {
  await tester.pumpWidget(MyApp());
  await tester.enterText(find.byKey(emailKey), 'user@example.com');
  await tester.enterText(find.byKey(passwordKey), 'password');
  await tester.tap(find.text('Login'));
  await tester.pumpAndSettle();
  expect(find.text('Home'), findsOneWidget);
});
```

---

## 📊 Performance Optimization

- **Lazy Loading**: Singleton BLoCs created only when needed
- **Connection Pooling**: Dio maintains persistent HTTP connections
- **Response Caching**: Can enable with cache interceptor
- **Image Optimization**: Use cached_network_image for remote images
- **Code Splitting**: Features as separate packages reduce initial load

---

## 🛠️ Built With

- **[Flutter](https://flutter.dev/)** - UI framework
- **[Dio](https://pub.dev/packages/dio)** - HTTP client
- **[BLoC](https://pub.dev/packages/flutter_bloc)** - State management
- **[GetIt](https://pub.dev/packages/get_it)** - Dependency injection
- **[go_router](https://pub.dev/packages/go_router)** - Routing
- **[dartz](https://pub.dev/packages/dartz)** - Functional programming
- **[flutter_secure_storage](https://pub.dev/packages/flutter_secure_storage)** - Secure storage
- **[shared_preferences](https://pub.dev/packages/shared_preferences)** - Local preferences
- **[equatable](https://pub.dev/packages/equatable)** - Value equality
- **[Melos](https://pub.dev/packages/melos)** - Monorepo management

---

## 📝 License

This project is licensed under the MIT License - see the LICENSE file for details.

---

## 👥 Contributing

Contributions are welcome! Please read the contributing guidelines before submitting PRs.

---

## 📞 Support

For questions or issues:

- Create an issue on GitHub
- Contact: [your-email@example.com]

---

## 🎓 Learn More

- [Flutter Documentation](https://docs.flutter.dev/)
- [BLoC Library](https://bloclibrary.dev/)
- [Clean Architecture by Uncle Bob](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)
- [Effective Dart](https://dart.dev/guides/language/effective-dart)

---

**Built with ❤️ for the Flutter community**
