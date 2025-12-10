# Mono Repo Clean Architecture- Feature-Based Modular Architecture

A fully modular Flutter project demonstrating Clean Architecture with feature-based packages using Melos.

## 🏗️ Architecture Overview

This project follows a **feature-based modular architecture** where each feature is completely self-contained with its own domain, data, and presentation layers.

### Package Structure

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
│   │       │   ├── domain/                       # Business logic
│   │       │   │   ├── entities/
│   │       │   │   │   └── app_locale.dart      # AppLocale entity (EN, BN, ES)
│   │       │   │   ├── repositories/
│   │       │   │   │   └── locale_repository.dart # Locale repository interface
│   │       │   │   └── usecases/
│   │       │   │       ├── get_saved_locale.dart # Get saved locale use case
│   │       │   │       └── save_locale.dart      # Save locale use case
│   │       │   ├── data/                         # Data layer
│   │       │   │   └── repositories/
│   │       │   │       └── locale_repository_impl.dart # Locale repository implementation
│   │       │   ├── presentation/                 # UI layer
│   │       │   │   └── bloc/
│   │       │   │       ├── localization_bloc.dart   # Localization BLoC
│   │       │   │       ├── localization_event.dart  # Localization events
│   │       │   │       └── localization_state.dart  # Localization states
│   │       │   ├── l10n/                         # Translation files (ARB)
│   │       │   │   ├── app_en.arb               # English translations (40+ keys)
│   │       │   │   ├── app_bn.arb               # Bengali translations (বাংলা)
│   │       │   │   └── app_es.arb               # Spanish translations (Español)
│   │       │   ├── generated/                    # Auto-generated files
│   │       │   │   ├── app_localizations.dart   # Main localizations class
│   │       │   │   ├── app_localizations_en.dart # English delegate
│   │       │   │   ├── app_localizations_bn.dart # Bengali delegate
│   │       │   │   └── app_localizations_es.dart # Spanish delegate
│   │       │   └── localization.dart            # Barrel export file
│   │       └── theme/                            # Theme system
│   │           ├── config/
│   │           │   ├── app_light_theme.dart     # Light theme config
│   │           │   ├── app_dark_theme.dart      # Dark theme config
│   │           │   └── theme_extensions.dart    # Custom theme extensions
│   │           └── presentation/
│   │               └── cubit/
│   │                   └── theme_cubit.dart     # Theme state management (BLoC)
│   ├── l10n.yaml                                 # Localization generation config
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

## 🎯 Key Principles

### 1. **Complete Feature Isolation**

- Each feature package is fully self-contained
- Features can be developed, tested, and maintained independently
- No shared domain or data layers across features

### 2. **Clean Architecture Layers**

Each feature follows Clean Architecture:

#### Domain Layer (Pure Business Logic)

- **Entities**: Core business objects (e.g., `UserEntity`, `AuthTokenEntity`)
- **Repositories**: Abstract interfaces defining contracts
- **Use Cases**: Single-responsibility business operations
- ✅ No dependencies on Flutter or external packages (except dartz, equatable)

#### Data Layer (Implementation Details)

- **Models**: Data transfer objects that extend entities
- **Data Sources**: API communication (Remote) or local storage
- **Repository Implementations**: Concrete implementations of domain repositories
- ✅ Depends on domain layer and core infrastructure

#### Presentation Layer (UI)

- **BLoC**: State management following BLoC pattern
- **Pages**: Full-screen views
- **Widgets**: Reusable UI components
- ✅ Depends on domain layer for business logic
- ✅ Uses flutter_bloc for reactive state management

### 3. **Dependency Rules**

```
Presentation → Domain ← Data
     ↓
   Core (Infrastructure)
```

- **Core**: No dependencies on features (only Flutter, Dio, storage)
- **Domain**: Only depends on core for exceptions
- **Data**: Depends on domain interfaces and core infrastructure
- **Presentation**: Depends on domain for business logic
- **App**: Orchestrates all features and handles DI

## 📦 Package Dependencies

### Core Package

```yaml
dependencies:
  - dio ^5.9.0
  - flutter_secure_storage ^9.2.4
  - shared_preferences ^2.5.3
  - flutter_localizations (SDK)
  - intl
  - dartz ^0.10.1
```

### Feature Packages (Auth & User)

```yaml
dependencies:
  - core (local)
  - dartz ^0.10.1 # Functional programming
  - flutter_bloc ^8.1.6 # State management
  - equatable ^2.0.7 # Value equality
```

### App Package

```yaml
dependencies:
  - core (local)
  - features_auth (local)
  - features_user (local)
  - get_it ^8.0.2 # Dependency injection
```

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (>=3.9.2)
- Dart SDK
- Melos CLI (optional, for monorepo commands)

### Installation

1. **Install dependencies for all packages:**

   ```bash
   cd packages/core && flutter pub get
   cd ../features_user && flutter pub get
   cd ../features_auth && flutter pub get
   cd ../app && flutter pub get
   ```

2. **Or use Melos (if installed):**
   ```bash
   melos bootstrap
   ```

### Running the App

```bash
cd packages/app
flutter run
```

## 🛠️ Development Workflow

### Adding a New Feature

1. **Create feature package:**

   ```bash
   mkdir -p packages/features_<feature_name>/lib/{domain,data,presentation}
   ```

2. **Define domain layer:**

   - Create entities in `domain/entities/`
   - Define repository interfaces in `domain/repositories/`
   - Implement use cases in `domain/usecases/`

3. **Implement data layer:**

   - Create models in `data/models/`
   - Implement data sources in `data/datasources/`
   - Implement repositories in `data/repositories/`

4. **Build presentation layer:**

   - Create BLoC in `presentation/bloc/`
   - Build pages in `presentation/pages/`
   - Create widgets in `presentation/widgets/`

5. **Create barrel export:**

   ```dart
   // lib/features_<feature_name>.dart
   library features_<feature_name>;

   export 'domain/entities/...';
   export 'domain/repositories/...';
   export 'domain/usecases/...';
   export 'data/models/...';
   export 'data/datasources/...';
   export 'data/repositories/...';
   export 'presentation/bloc/...';
   export 'presentation/pages/...';
   export 'presentation/widgets/...';
   ```

6. **Update app dependencies:**

   ```yaml
   # packages/app/pubspec.yaml
   dependencies:
     features_<feature_name>:
       path: ../features_<feature_name>
   ```

7. **Register in DI container:**
   ```dart
   // packages/app/lib/injection_container.dart
   getIt.registerLazySingleton<FeatureRepository>(
     () => FeatureRepositoryImpl(...),
   );
   ```

## 🧪 Testing

Each feature can be tested independently:

```bash
# Test specific feature
cd packages/features_auth
flutter test

# Test all packages
melos run test
```

## 📊 Analysis

Run static analysis:

```bash
# Analyze specific package
cd packages/features_auth
flutter analyze

# Analyze all packages
melos run analyze
```

## 🎨 State Management

This project uses **BLoC (Business Logic Component)** pattern:

- **Events**: User actions or triggers
- **States**: UI states (loading, success, error)
- **BLoC**: Business logic that transforms events into states

Example:

```dart
// Feature exports BLoC, Events, and States
import 'package:features_auth/features_auth.dart';

// Usage in UI
BlocProvider<AuthBloc>(
  create: (context) => getIt<AuthBloc>(),
  child: LoginPage(),
)
```

## 🔐 Network Layer

Centralized in the `core` package:

- **DioClient**: Configured HTTP client
- **Interceptors**:
  - AuthInterceptor (adds tokens)
  - RefreshTokenInterceptor (refreshes expired tokens)
  - ErrorInterceptor (handles errors)
  - RetryInterceptor (retries failed requests)
  - LoggingInterceptor (logs requests/responses)
- **TokenStorage**: Secure token persistence

## 🌍 Localization System

The app includes a **complete internationalization (i18n) system** following Clean Architecture principles:

### Supported Languages

- **English** (en_US) - Default
- **Bengali** (বাংলা - bn_BD)
- **Spanish** (Español - es_ES)

### Architecture

**Domain Layer:**

- `AppLocale` entity with supported locale definitions
- `LocaleRepository` interface for locale persistence
- `GetSavedLocaleUseCase` - Retrieves saved language preference
- `SaveLocaleUseCase` - Persists language selection

**Data Layer:**

- `LocaleRepositoryImpl` - Repository implementation
- `LocaleStorage` - SharedPreferences wrapper for persistence

**Presentation Layer:**

- `LocalizationBloc` - State management with events/states
  - `LoadSavedLocaleEvent` - Load saved locale on app start
  - `ChangeLocaleEvent` - Switch to a new locale
  - `ResetToSystemLocaleEvent` - Reset to device locale
- `LocalizationState` - States: Initial, Loading, Loaded, Error

### Translation Files

Location: `packages/core/lib/src/localization/l10n/`

- `app_en.arb` - English translations (40+ keys)
- `app_bn.arb` - Bengali translations
- `app_es.arb` - Spanish translations

### Code Generation

The project uses Flutter's built-in localization generator (`flutter gen-l10n`):

```yaml
# packages/core/l10n.yaml
arb-dir: lib/src/localization/l10n
template-arb-file: app_en.arb
output-localization-file: app_localizations.dart
output-class: AppLocalizations
output-dir: lib/src/localization/generated
```

Generated file: `AppLocalizations` with type-safe accessor methods.

### Usage

**In UI:**

```dart
// Access translations
Text(AppLocalizations.of(context).appTitle)
Text(AppLocalizations.of(context).login)
Text(AppLocalizations.of(context).logout)

// Change language
context.read<LocalizationBloc>().add(
  ChangeLocaleEvent(AppLocale.bengali),
);
```

**MaterialApp Configuration:**

```dart
MaterialApp(
  locale: currentLocale, // From LocalizationBloc
  supportedLocales: AppLocale.supportedFlutterLocales,
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  // ...
)
```

### Persistence

- Language preference saved using `SharedPreferences`
- Automatically loaded on app startup
- Persists across app sessions

### Adding New Translations

1. Add key to `app_en.arb`:

   ```json
   "newKey": "English text",
   "@newKey": {
     "description": "Description of this key"
   }
   ```

2. Add translations to `app_bn.arb` and `app_es.arb`

3. Run code generation:

   ```bash
   flutter pub get
   # Auto-generates on build
   ```

4. Use in code:
   ```dart
   AppLocalizations.of(context).newKey
   ```

## 🎨 Theme System

Centralized theming with Material 3:

- **ThemeCubit**: State management for theme mode
- **Light/Dark Themes**: Separate theme configurations
- **Custom Extensions**: Additional design tokens
- **System Default**: Respects device theme preference

Usage:

```dart
// Change theme
context.read<ThemeCubit>().changeTheme(ThemeMode.dark);

// In MaterialApp
themeMode: currentThemeMode, // From ThemeCubit
```

## 🔐 Network Layer

Centralized in the `core` package:

```
User Action (UI)
    ↓
  Event
    ↓
  BLoC (calls UseCase)
    ↓
UseCase (business logic)
    ↓
Repository Interface (domain)
    ↓
Repository Implementation (data)
    ↓
Data Source (API/Local)
    ↓
  Model
    ↓
  Entity
    ↓
  State
    ↓
UI Update
```

## 📝 Naming Conventions

- **Entities**: `<Name>Entity` (e.g., `UserEntity`)
- **Models**: `<Name>Model` (e.g., `UserModel`)
- **Repositories**: `<Name>Repository` (interface), `<Name>RepositoryImpl` (implementation)
- **Use Cases**: `<Action><Entity>UseCase` (e.g., `GetUserByIdUseCase`)
- **Data Sources**: `<Name>RemoteDataSource`, `<Name>LocalDataSource`
- **BLoC**: `<Feature>Bloc`, `<Feature>Event`, `<Feature>State`

## 🏆 Benefits of This Architecture

1. **Scalability**: Add features without affecting existing code
2. **Testability**: Each layer can be tested independently
3. **Maintainability**: Clear separation of concerns
4. **Reusability**: Features can be reused across projects
5. **Team Collaboration**: Multiple teams can work on different features
6. **Independence**: Features can be developed/deployed separately

## 📚 Additional Resources

- [Clean Architecture by Robert C. Martin](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)
- [Flutter BLoC Package](https://bloclibrary.dev/)
- [Melos - Monorepo Management](https://melos.invertase.dev/)
- [Dio - HTTP Client](https://pub.dev/packages/dio)

## 🤝 Contributing

When contributing:

1. Follow the existing architecture patterns
2. Keep features isolated and self-contained
3. Write tests for new features
4. Update documentation as needed

## 📄 License

This project is licensed under the MIT License.
