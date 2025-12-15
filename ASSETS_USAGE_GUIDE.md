# Asset Access Guide for All Features

## ✅ All Features Can Access Assets

Since all feature packages depend on the `core` package, they can access `AppAssets` anywhere in their **presentation layer**.

## 📦 Feature Package Dependencies

All features already have `core` as a dependency:
- ✅ `features_auth` → depends on `core`
- ✅ `features_home` → depends on `core`
- ✅ `features_splash` → depends on `core`
- ✅ `features_onboarding` → depends on `core`
- ✅ `features_user` → depends on `core`

## 🎯 How to Use Assets in Any Feature

### Import Statement (same for all features)
```dart
import 'package:core/core.dart';
```

### Example Usage by Feature

#### 1. **features_auth** - Login Page
```dart
// lib/presentation/pages/login_page.dart
import 'package:flutter/material.dart';
import 'package:core/core.dart';  // ✅ Access AppAssets

class LoginPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Use login background
          Image.asset(
            AppAssets.loginBackground,
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
          // Login form overlay
          Center(
            child: Image.asset(
              AppAssets.appLogo,
              width: 120,
              height: 120,
            ),
          ),
        ],
      ),
    );
  }
}
```

#### 2. **features_splash** - Splash Screen
```dart
// lib/presentation/pages/splash_page.dart
import 'package:flutter/material.dart';
import 'package:core/core.dart';  // ✅ Access AppAssets

class SplashPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              AppAssets.appLogo,
              width: 150,
              height: 150,
            ),
            SizedBox(height: 24),
            // Use Lottie animation (requires lottie package)
            // Lottie.asset(AppAssets.loadingAnimation),
          ],
        ),
      ),
    );
  }
}
```

#### 3. **features_home** - Dashboard
```dart
// lib/presentation/pages/home_page.dart
import 'package:flutter/material.dart';
import 'package:core/core.dart';  // ✅ Access AppAssets
// import 'package:flutter_svg/flutter_svg.dart'; // For SVG icons

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard'),
        leading: Image.asset(AppAssets.appLogo),
      ),
      body: Column(
        children: [
          // Dashboard banner
          Image.asset(
            AppAssets.dashboardBanner,
            fit: BoxFit.cover,
            width: double.infinity,
            height: 200,
          ),
          // Content here
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home), // Or use: SvgPicture.asset(AppAssets.homeIcon)
            label: 'Home',
          ),
        ],
      ),
    );
  }
}
```

#### 4. **features_onboarding** - Onboarding Screens
```dart
// lib/presentation/pages/onboarding_page.dart
import 'package:flutter/material.dart';
import 'package:core/core.dart';  // ✅ Access AppAssets

class OnboardingPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        children: [
          OnboardingSlide(
            image: AppAssets.appLogo,
            title: 'Welcome',
            description: 'Get started with our app',
          ),
          // More slides...
        ],
      ),
    );
  }
}
```

#### 5. **features_user** - Profile Page
```dart
// lib/presentation/pages/profile_page.dart
import 'package:flutter/material.dart';
import 'package:core/core.dart';  // ✅ Access AppAssets

class ProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Profile')),
      body: Center(
        child: Column(
          children: [
            // Default avatar if user has no profile picture
            Image.asset(
              AppAssets.appLogo,
              width: 80,
              height: 80,
            ),
            // User info...
          ],
        ),
      ),
    );
  }
}
```

## 🚨 Critical Rules

### ✅ DO Use Assets In:
- **Widgets** (`lib/presentation/widgets/`)
- **Pages** (`lib/presentation/pages/`)
- **UI Components** (any presentation layer code)

### ❌ DON'T Use Assets In:
- **BLoC** (`lib/presentation/bloc/`)
- **UseCases** (`lib/domain/usecases/`)
- **Repositories** (`lib/data/repositories/`, `lib/domain/repositories/`)
- **DataSources** (`lib/data/datasources/`)
- **Entities** (`lib/domain/entities/`)
- **Models** (`lib/data/models/`)

## 📚 Additional Packages for Assets

### For SVG Icons
```yaml
# Add to app/pubspec.yaml
dependencies:
  flutter_svg: ^2.0.0
```

Usage:
```dart
import 'package:flutter_svg/flutter_svg.dart';
SvgPicture.asset(AppAssets.homeIcon, width: 24, height: 24);
```

### For Lottie Animations
```yaml
# Add to app/pubspec.yaml
dependencies:
  lottie: ^3.0.0
```

Usage:
```dart
import 'package:lottie/lottie.dart';
Lottie.asset(AppAssets.loadingAnimation);
```

## 🎯 Summary

**No additional configuration needed!** All features can access assets through:
```dart
import 'package:core/core.dart';
// Then use: AppAssets.appLogo, AppAssets.loginBackground, etc.
```

The assets are centralized in the `app` package but accessible everywhere through the `core` package's `AppAssets` class. This maintains Clean Architecture while providing convenient access across all features.
