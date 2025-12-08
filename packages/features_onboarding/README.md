# Features Onboarding

Onboarding feature module following Clean Architecture principles with introduction screens.

## Features

- ✅ Multiple onboarding pages with swipe navigation
- ✅ Page indicators with animation
- ✅ Skip functionality
- ✅ Persistent onboarding completion status
- ✅ Back/Next navigation buttons
- ✅ Beautiful UI with emoji icons
- ✅ Clean Architecture (Domain/Data/Presentation)
- ✅ BLoC state management

## Structure

```
lib/
├── domain/
│   ├── entities/
│   │   └── onboarding_page_entity.dart
│   ├── repositories/
│   │   └── onboarding_repository.dart
│   └── usecases/
│       ├── complete_onboarding_usecase.dart
│       └── check_onboarding_status_usecase.dart
├── data/
│   ├── models/
│   │   └── onboarding_page_model.dart
│   ├── datasources/
│   │   └── onboarding_local_datasource.dart
│   └── repositories/
│       └── onboarding_repository_impl.dart
└── presentation/
    ├── bloc/
    │   ├── onboarding_bloc.dart
    │   ├── onboarding_event.dart
    │   └── onboarding_state.dart
    ├── pages/
    │   └── onboarding_page.dart
    └── widgets/
        └── onboarding_content.dart
```

## Usage

### 1. Add to app dependencies

```yaml
dependencies:
  features_onboarding:
    path: ../features_onboarding
```

### 2. Register in DI container

```dart
// Onboarding
sl.registerLazySingleton<OnboardingLocalDataSource>(
  () => OnboardingLocalDataSource(sl()),
);
sl.registerLazySingleton<OnboardingRepository>(
  () => OnboardingRepositoryImpl(sl()),
);
sl.registerLazySingleton(() => CompleteOnboardingUseCase(sl()));
sl.registerLazySingleton(() => CheckOnboardingStatusUseCase(sl()));
sl.registerFactory(
  () => OnboardingBloc(
    repository: sl(),
    completeOnboardingUseCase: sl(),
  ),
);
```

### 3. Register onboarding route

```dart
AppRouteRegistry.registerRoute(
  AppRoutes.onboarding,
  (settings) => MaterialPageRoute(
    builder: (_) => BlocProvider(
      create: (_) => getIt<OnboardingBloc>(),
      child: const OnboardingPage(),
    ),
    settings: settings,
  ),
);
```

### 4. Check onboarding status in splash

```dart
// In splash screen initialization
final hasCompletedOnboarding = await checkOnboardingStatusUseCase();

if (!hasCompletedOnboarding) {
  // Navigate to onboarding
  AppRoutes.navigateToOnboarding(context);
} else if (isAuthenticated) {
  // Navigate to home
  AppRoutes.navigateToHome(context);
} else {
  // Navigate to login
  AppRoutes.navigateToLogin(context);
}
```

## Navigation Flow

```
First App Launch
    ↓
Splash Screen
    ↓
Check Onboarding Status
    ↓
    ├─→ Not Completed → OnboardingPage
    │                   (user completes/skips)
    │                        ↓
    │                   Mark as Completed
    │                        ↓
    │                   Navigate to Splash
    │
    └─→ Completed → Check Auth
                        ↓
                    Home/Login
```

## States

- `OnboardingInitial` - Initial state
- `OnboardingLoading` - Loading pages
- `OnboardingLoaded` - Pages loaded with current page index
- `OnboardingCompleted` - User completed onboarding
- `OnboardingSkipped` - User skipped onboarding
- `OnboardingError` - Failed to load pages

## Events

- `LoadOnboardingPagesEvent` - Load onboarding pages
- `NextPageEvent` - Go to next page
- `PreviousPageEvent` - Go to previous page
- `PageChangedEvent` - Page changed by swipe
- `SkipOnboardingEvent` - Skip onboarding
- `CompleteOnboardingEvent` - Complete onboarding

## Customization

### Add/Modify Onboarding Pages

Edit `onboarding_local_datasource.dart`:

```dart
return const [
  OnboardingPageModel(
    title: 'Your Custom Title',
    description: 'Your description here',
    image: '🎨', // Use emoji or path to image
    index: 0,
  ),
  // Add more pages...
];
```

### Change Colors/Theme

Edit `onboarding_page.dart` and `onboarding_content.dart` to customize:

- Background colors
- Text styles
- Button styles
- Page indicator colors
- Animations

### Use Real Images

Replace emoji with image paths:

```dart
// In OnboardingContent widget
Image.asset(
  page.image, // Now contains image path
  width: 200,
  height: 200,
)
```

## Features

### Swipe Navigation

- Users can swipe left/right to navigate
- Smooth page transitions

### Page Indicators

- Shows current page position
- Animated transitions

### Skip Button

- Allows users to skip onboarding
- Marks onboarding as completed

### Get Started Button

- On last page, shows "Get Started"
- Completes onboarding and navigates

### Persistent Storage

- Uses SharedPreferences
- Onboarding shown only once
- Can be reset by clearing app data
