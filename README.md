# Dio Network Config - Feature-Based Modular Architecture

A production-ready Flutter application demonstrating Clean Architecture with feature-based packages using Melos for monorepo management.

## 🚀 Quick Start

### 1. Bootstrap All Packages

**Option 1: Cross-platform Dart script (Recommended)**

```bash
dart bootstrap.dart
```

**Option 2: Linux/macOS shell script**

```bash
./bootstrap.sh
```

**Option 3: Windows batch script**

```cmd
bootstrap.bat
```

**Option 4: Manual installation**

```bash
cd packages/app && flutter pub get
cd packages/core && dart pub get
# ... etc
```

### 2. Try the Mock Authentication System

This project includes a **fully functional mock authentication** system - no backend required!

```bash
cd packages/app
flutter run
```

**Demo Credentials** (tap on login page to auto-fill):

- **Demo User**: `demo@test.com` / `password123`
- **Admin User**: `admin@test.com` / `admin123`
- **Test User**: `test@test.com` / `test123`

📚 **[Complete Mock Auth Guide](MOCK_AUTH_GUIDE.md)** - Learn how to use and switch to real API

## ✨ Features

- ✅ **Feature-Based Modular Architecture** - Complete isolation of features with independent domain/data/presentation layers
- ✅ **Melos Monorepo** - Multi-package workspace management
- ✅ **Clean Architecture** - Strict separation of concerns across all layers
- ✅ **BLoC Pattern** - State management with flutter_bloc
- ✅ **Mock Authentication** - Fully functional auth without backend (easy switch to real API)
- ✅ **Splash & Onboarding** - Professional app initialization flow
- ✅ **Internationalization (i18n)** - Multi-language support (English, Bengali, Spanish) with BLoC
- ✅ **Theme System** - Light/Dark/System themes with Material 3
- ✅ **Centralized Network Layer** - Dio-based HTTP client with interceptors
- ✅ **Centralized Routing** - App-wide route management in core package
- ✅ **Token Management** - Automatic token injection and refresh with request queuing
- ✅ **Error Handling** - Domain-specific exceptions with detailed error information
- ✅ **Auto Retry** - Exponential backoff with jitter
- ✅ **Environment Config** - Support for dev/staging/prod environments (compile-time)
- ✅ **Result Pattern** - Type-safe success/failure handling with dartz

## 📁 Project Structure

```
packages/
├── core/                                          # Shared infrastructure
│   ├── lib/
│   │   ├── core.dart                             # Barrel export file
│   │   └── src/
│   │       ├── network/                          # Network layer
│   │       │   ├── dio_client.dart              # Main HTTP client (singleton)
│   │       │   ├── network_config.dart          # Environment & configuration
│   │       │   ├── api_exceptions.dart          # Custom exception hierarchy
│   │       │   ├── api_response.dart            # Response wrappers & Result type
│   │       │   ├── interceptors/                # Dio interceptors
│   │       │   │   ├── auth_interceptor.dart    # Bearer token injection
│   │       │   │   ├── refresh_token_interceptor.dart  # Token refresh + queue
│   │       │   │   ├── retry_interceptor.dart   # Auto retry with backoff
│   │       │   │   ├── error_interceptor.dart   # Error mapping
│   │       │   │   └── logging_interceptor.dart # Debug logging
│   │       │   └── utils/
│   │       │       └── multipart_helper.dart    # File upload utilities
│   │       ├── routes/                           # Routing
│   │       │   ├── api_routes.dart              # API endpoint definitions
│   │       │   └── app_routes.dart              # App navigation routes
│   │       ├── storage/                          # Storage
│   │       │   ├── token_storage.dart           # Token storage interface
│   │       │   └── locale_storage.dart          # Locale storage (SharedPreferences)
│   │       ├── localization/                     # Localization system (i18n)
│   │       │   ├── domain/                      # Business logic
│   │       │   │   ├── entities/
│   │       │   │   │   └── app_locale.dart      # AppLocale entity (EN, BN, ES)
│   │       │   │   ├── repositories/
│   │       │   │   │   └── locale_repository.dart # Locale repository interface
│   │       │   │   └── usecases/
│   │       │   │       ├── get_saved_locale.dart # Get saved locale
│   │       │   │       └── save_locale.dart      # Save locale
│   │       │   ├── data/                        # Data layer
│   │       │   │   └── repositories/
│   │       │   │       └── locale_repository_impl.dart # Implementation
│   │       │   ├── presentation/                # UI layer
│   │       │   │   └── bloc/
│   │       │   │       ├── localization_bloc.dart   # State management
│   │       │   │       ├── localization_event.dart  # Events
│   │       │   │       └── localization_state.dart  # States
│   │       │   ├── l10n/                        # Translation files (ARB)
│   │       │   │   ├── app_en.arb               # English (40+ keys)
│   │       │   │   ├── app_bn.arb               # Bengali (বাংলা)
│   │       │   │   └── app_es.arb               # Spanish (Español)
│   │       │   ├── generated/                   # Auto-generated by flutter gen-l10n
│   │       │   │   ├── app_localizations.dart   # Main class
│   │       │   │   ├── app_localizations_en.dart # English delegate
│   │       │   │   ├── app_localizations_bn.dart # Bengali delegate
│   │       │   │   └── app_localizations_es.dart # Spanish delegate
│   │       │   └── localization.dart            # Barrel export
│   │       └── theme/                            # Theme system
│   │           ├── config/
│   │           │   ├── app_light_theme.dart     # Light theme
│   │           │   ├── app_dark_theme.dart      # Dark theme
│   │           │   └── theme_extensions.dart    # Custom extensions
│   │           └── presentation/
│   │               └── cubit/
│   │                   └── theme_cubit.dart     # Theme BLoC
│   ├── l10n.yaml                                 # Localization config
│   └── pubspec.yaml
│
├── features_auth/                                 # Authentication Feature
│   ├── lib/
│   │   ├── features_auth.dart                    # Barrel export file
│   │   ├── domain/                               # Business logic (pure Dart)
│   │   │   ├── entities/
│   │   │   │   └── auth_token_entity.dart       # AuthToken entity
│   │   │   ├── repositories/
│   │   │   │   └── auth_repository.dart         # Auth repository interface
│   │   │   └── usecases/
│   │   │       ├── login_usecase.dart           # Login use case
│   │   │       ├── logout_usecase.dart          # Logout use case
│   │   │       └── get_current_user_usecase.dart # Get current user
│   │   ├── data/                                 # Data layer
│   │   │   ├── models/
│   │   │   │   └── auth_token_model.dart        # AuthToken model (DTO)
│   │   │   ├── datasources/
│   │   │   │   └── remote/
│   │   │   │       └── auth_remote_datasource.dart # API calls
│   │   │   └── repositories/
│   │   │       └── auth_repository_impl.dart    # Repository implementation
│   │   └── presentation/                         # UI layer
│   │       ├── bloc/
│   │       │   ├── auth_bloc.dart               # Auth BLoC
│   │       │   ├── auth_event.dart              # Auth events
│   │       │   └── auth_state.dart              # Auth states
│   │       ├── pages/
│   │       │   └── login_page.dart              # Login page
│   │       └── widgets/
│   │           └── login_form.dart              # Login form widget
│   └── pubspec.yaml
│
├── features_user/                                 # User Feature
│   ├── lib/
│   │   ├── features_user.dart                    # Barrel export file
│   │   ├── domain/                               # Business logic (pure Dart)
│   │   │   ├── entities/
│   │   │   │   └── user_entity.dart             # User entity
│   │   │   ├── repositories/
│   │   │   │   └── user_repository.dart         # User repository interface
│   │   │   └── usecases/
│   │   │       └── get_user_by_id_usecase.dart  # Get user by ID
│   │   ├── data/                                 # Data layer
│   │   │   ├── models/
│   │   │   │   └── user_model.dart              # User model (DTO)
│   │   │   ├── datasources/
│   │   │   │   └── remote/
│   │   │   │       └── user_remote_datasource.dart # API calls
│   │   │   └── repositories/
│   │   │       └── user_repository_impl.dart    # Repository implementation
│   │   └── presentation/                         # UI layer (placeholder)
│   │       ├── bloc/                            # (to be implemented)
│   │       ├── pages/                           # (to be implemented)
│   │       └── widgets/                         # (to be implemented)
│   └── pubspec.yaml
│
├── features_home/                                 # Home Feature (Network Testing)
│   ├── lib/
│   │   ├── features_home.dart                    # Barrel export file
│   │   ├── main.dart                             # Entry point (for testing)
│   │   ├── domain/                               # Business logic (pure Dart)
│   │   │   ├── entities/
│   │   │   │   └── network_test_entity.dart     # NetworkTest entity
│   │   │   ├── repositories/
│   │   │   │   └── network_test_repository.dart # NetworkTest repository interface
│   │   │   └── usecases/
│   │   │       └── run_network_tests_usecase.dart # Run network tests
│   │   ├── data/                                 # Data layer
│   │   │   ├── models/
│   │   │   │   └── network_test_model.dart      # NetworkTest model (DTO)
│   │   │   ├── datasources/
│   │   │   │   └── network_test_datasource.dart # Network test API calls
│   │   │   └── repositories/
│   │   │       └── network_test_repository_impl.dart # Repository implementation
│   │   └── presentation/                         # UI layer
│   │       ├── bloc/
│   │       │   ├── network_test_bloc.dart       # NetworkTest BLoC
│   │       │   ├── network_test_event.dart      # NetworkTest events
│   │       │   └── network_test_state.dart      # NetworkTest states
│   │       ├── pages/
│   │       │   ├── home_page.dart               # Home page
│   │       │   ├── network_test_page.dart       # Network test page (simple)
│   │       │   └── network_test_page_bloc.dart  # Network test page (with BLoC)
│   │       └── widgets/
│   │           ├── auth_status_card.dart        # Auth status widget
│   │           └── info_card.dart               # Info card widget
│   └── pubspec.yaml
│
└── app/                                           # Main Application
    ├── lib/
    │   ├── main.dart                             # App entry point
    │   ├── injection_container.dart              # Dependency injection (GetIt)
    │   └── routes/
    │       └── app_route_generator.dart          # Route generation & BLoC providers
    └── pubspec.yaml
```

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (>=3.9.2)
- Dart SDK
- Melos (optional but recommended)

### Installation

**Option 1: Using Melos (Recommended)**

```bash
# Install Melos globally
dart pub global activate melos

# Bootstrap all packages
melos bootstrap
```

**Option 2: Manual**

```bash
# Install dependencies for each package
cd packages/core && flutter pub get
cd ../features_auth && flutter pub get
cd ../features_user && flutter pub get
cd ../features_home && flutter pub get
cd ../app && flutter pub get
```

### Running the App

```bash
cd packages/app
flutter run
```

### Run with Environment

```bash
# Development (default - uses JSONPlaceholder API)
flutter run

# Staging
flutter run --dart-define=ENV=staging

# Production
flutter run --dart-define=ENV=prod
```

## 🏗️ Architecture

This project follows **Clean Architecture** with **feature-based modular structure**. Each feature is completely self-contained.

### Dependency Flow

```
Presentation → Domain ← Data
     ↓            ↓
        Core (Infrastructure)
```

### Layer Responsibilities

**Domain Layer** (Pure Business Logic)

- Entities: Core business objects
- Repositories: Abstract interfaces
- Use Cases: Single-responsibility business operations
- ✅ No dependencies on Flutter or external frameworks

**Data Layer** (Implementation)

- Models: Data transfer objects extending entities
- Data Sources: API communication (Remote) or local storage
- Repository Implementations: Concrete repository implementations
- ✅ Depends on domain interfaces and core infrastructure

**Presentation Layer** (UI)

- BLoC: State management (events, states, bloc)
- Pages: Full-screen views
- Widgets: Reusable UI components
- ✅ Depends on domain layer for business logic

**Core Package** (Shared Infrastructure)

- Network: DioClient, interceptors, exceptions
- Routes: App routes & API routes
- Storage: Token storage interface
- ✅ No dependencies on features

**App Package** (Orchestration)

- Dependency Injection: GetIt setup
- Route Generation: Route registry and generation
- Main Entry: App initialization
- ✅ Depends on all features and core

## 🔧 Key Components

### Network Layer (Core Package)

**DioClient** - Singleton HTTP client with:

- 5 interceptors: Logging → Auth → RefreshToken → Retry → Error
- Methods: GET, POST, PUT, PATCH, DELETE
- File upload/download with progress
- Request cancellation

**Interceptors:**

- `AuthInterceptor` - Adds Bearer tokens
- `RefreshTokenInterceptor` - Handles token refresh with request queuing
- `RetryInterceptor` - Exponential backoff retry
- `ErrorInterceptor` - Maps Dio errors to ApiExceptions
- `LoggingInterceptor` - Debug logging

**Network Config:**

- Uses `String.fromEnvironment('ENV')` for compile-time configuration
- No .env file needed - more secure
- Default: 'dev' (JSONPlaceholder API)

### Routing System

**AppRoutes** (Core Package)

- Centralized route definitions
- Navigation helpers: `navigateToHome()`, `navigateToLogin()`, etc.
- Used by all feature modules

**AppRouteGenerator** (App Package)

- Route generation with `onGenerateRoute()`
- BLoC providers at route level
- Route registry for modular registration

### State Management

**BLoC Pattern** using flutter_bloc:

- Events: User actions
- States: UI states (loading, success, error)
- BLoC: Business logic transforming events to states

Example:

```dart
BlocProvider<NetworkTestBloc>(
  create: (_) => getIt<NetworkTestBloc>(),
  child: NetworkTestPage(),
)
```

### Dependency Injection

**GetIt** for service location:

- Registered in `app/injection_container.dart`
- Chain: DataSources → Repositories → UseCases → BLoCs
- Singleton instances for core services

## 📖 Usage Examples

### Making API Requests

```dart
// Using DioClient directly (in DataSources)
final dioClient = DioClient();
final response = await dioClient.get(ApiRoutes.posts);

// Using Repository → UseCase → BLoC (recommended)
context.read<NetworkTestBloc>().add(RunAllNetworkTestsEvent());
```

### Navigation

```dart
// Using navigation helpers
AppRoutes.navigateToNetworkTest(context);

// Or using route names
Navigator.pushNamed(context, AppRoutes.networkTest);
```

### Error Handling

```dart
try {
  final response = await dioClient.get(ApiRoutes.posts);
} on UnauthorizedException catch (e) {
  // Handle 401
} on NetworkException catch (e) {
  // Handle network errors
} on ApiException catch (e) {
  // Handle other errors
}
```

## 🌍 Internationalization (i18n)

The app supports **3 languages** with complete Clean Architecture implementation:

### Supported Languages

- **English** (en_US) - Default
- **Bengali** (বাংলা - bn_BD)
- **Spanish** (Español - es_ES)

### Usage

```dart
// Access translations
Text(AppLocalizations.of(context).appTitle)
Text(AppLocalizations.of(context).login)
Text(AppLocalizations.of(context).welcome)

// Change language
context.read<LocalizationBloc>().add(
  ChangeLocaleEvent(AppLocale.bengali),
);

// Reset to system locale
context.read<LocalizationBloc>().add(
  const ResetToSystemLocaleEvent(),
);
```

### Features

- ✅ **BLoC State Management** - LocalizationBloc for reactive language changes
- ✅ **Persistent Selection** - Language preference saved using SharedPreferences
- ✅ **Auto-load on Startup** - Saved language loaded automatically
- ✅ **Type-Safe Translations** - Generated `AppLocalizations` class
- ✅ **Clean Architecture** - Domain/Data/Presentation layers
- ✅ **40+ Translation Keys** - Complete UI coverage

### Adding New Translations

1. Edit `packages/core/lib/src/localization/l10n/app_en.arb`
2. Add translations to `app_bn.arb` and `app_es.arb`
3. Run `flutter pub get` to regenerate
4. Use `AppLocalizations.of(context).yourKey`

See [ARCHITECTURE.md](./ARCHITECTURE.md) for complete localization documentation.

## 🎨 Theme System

**Material 3** theming with BLoC state management:

```dart
// Change theme
context.read<ThemeCubit>().changeTheme(ThemeMode.dark);
context.read<ThemeCubit>().changeTheme(ThemeMode.light);
context.read<ThemeCubit>().changeTheme(ThemeMode.system);

// Access theme
final themeMode = context.watch<ThemeCubit>().state;
```

Features:

- ✅ Light/Dark/System modes
- ✅ Material 3 design tokens
- ✅ Custom color extensions
- ✅ Persistent theme preference

## 📝 Adding New Features

1. **Create feature package structure:**

   ```bash
   mkdir -p packages/features_<name>/lib/{domain,data,presentation}
   ```

2. **Implement layers:**

   - Domain: entities → repositories → usecases
   - Data: models → datasources → repository implementations
   - Presentation: bloc → pages → widgets

3. **Create barrel export** (`features_<name>.dart`)

4. **Add to app dependencies** (`app/pubspec.yaml`)

5. **Register in DI** (`app/injection_container.dart`)

6. **Register routes** (`app/routes/app_route_generator.dart`)

See [ARCHITECTURE.md](./ARCHITECTURE.md) for detailed guide.

## 🛠️ Maloc CLI - Feature Generator

**Maloc** (Melos + BLoC) is a custom CLI tool to quickly generate feature packages with complete Clean Architecture structure.

### Installation

```bash
cd cli
dart pub global activate --source path .
```

### Usage

```bash
# Create a new feature
maloc create --name products
maloc create -n user_profile

# Show help
maloc --help
```

### What Gets Generated

Complete feature package with:

- ✅ Domain layer (entities, repositories, use cases)
- ✅ Data layer (models, datasources, repository implementations)
- ✅ Presentation layer (BLoC with events/states, pages)
- ✅ Barrel export file
- ✅ pubspec.yaml with all dependencies
- ✅ Proper imports and boilerplate code

See **[CLI Documentation](./cli/README.md)** for complete guide.

## 🔐 Environment Configuration

The app uses **compile-time constants** via `String.fromEnvironment()`:

```dart
// packages/core/lib/src/network/network_config.dart
static const String environment = String.fromEnvironment(
  'ENV',
  defaultValue: 'dev',
);
```

**No .env file or dotenv package needed** - values are baked into the compiled app.

**Usage:**

```bash
flutter run --dart-define=ENV=prod
flutter build apk --dart-define=ENV=staging
```

**Benefits:**

- More secure (no .env file to accidentally commit)
- Values can't be changed at runtime
- Follows Flutter best practices

## 🧪 Testing

```bash
# Test all packages
melos run test

# Test specific feature
cd packages/features_home
flutter test
```

## 📊 Melos Commands

```bash
melos clean       # Clean all packages
melos get         # Get dependencies for all packages
melos analyze     # Analyze all packages
melos format      # Format all Dart code
melos test        # Run tests in all packages
```

## 📖 Documentation

- **[ARCHITECTURE.md](./ARCHITECTURE.md)** - Complete architecture guide ✅
- **[ROUTING.md](./ROUTING.md)** - Routing system documentation
- **[CLI README](./cli/README.md)** - Maloc CLI documentation for feature generation ✅

## 🎯 Current Features

- ✅ **Authentication** (login/logout with mock system)
- ✅ **Splash & Onboarding** (first-time user experience)
- ✅ **Multi-language Support** (English, Bengali, Spanish)
- ✅ **Theme System** (Light/Dark/System with Material 3)
- ✅ **Network Testing** (8 comprehensive tests)
- ✅ **Centralized Routing** (app-wide navigation)
- ✅ **Token Management** (auto-refresh with request queuing)
- ✅ **Error Handling** (custom exceptions hierarchy)
- ✅ **BLoC State Management** (AuthBloc, LocalizationBloc, ThemeCubit)
- ✅ **Persistent Storage** (tokens, locale, theme, onboarding status)

## 📄 License

This project is provided as-is for educational and development purposes.
