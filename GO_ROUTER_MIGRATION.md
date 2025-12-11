# Go Router Migration Guide

## Overview

This project has been migrated from **Navigator 1.0** (manual route generation) to **go_router** for better deep linking, URL support, type-safe navigation, and declarative routing.

## Key Changes

### 1. Dependencies Added

**packages/core/pubspec.yaml** and **packages/app/pubspec.yaml**:

```yaml
dependencies:
  go_router: ^14.6.2
```

### 2. Route Definition Changes

#### Before (Navigator 1.0):

```dart
// String-based route names
static const String home = '/home';

// Manual navigation with Navigator
Navigator.pushNamed(context, AppRoutes.home);
Navigator.pushNamedAndRemoveUntil(context, AppRoutes.login, (route) => false);
```

#### After (go_router):

```dart
// Route names (for named navigation)
static const String home = 'home';

// Route paths (actual URL paths)
static const String homePath = '/home';

// Declarative navigation with context extensions
context.go(AppRoutes.homePath);      // Replace entire stack
context.push(AppRoutes.homePath);    // Push on stack
context.pop();                        // Go back
```

### 3. Architecture Components

#### New Files Created:

- **`packages/app/lib/routes/app_router.dart`** - GoRouter configuration
- **`packages/core/lib/src/routes/app_routes.dart`** - Updated with go_router paths

#### Files Made Obsolete:

- **`packages/app/lib/routes/app_route_generator.dart`** - Can be deleted (kept for reference)

### 4. Route Configuration

The new `AppRouter.createRouter()` provides:

✅ **Deep Linking** - URLs work on web and mobile  
✅ **Authentication Guards** - Automatic redirects based on auth state  
✅ **Type-Safe Parameters** - Path parameters like `/profile/:userId`  
✅ **Query Parameters** - Support for `?search=term`  
✅ **Custom Transitions** - Fade, slide, or no transition  
✅ **Error Handling** - Graceful 404 pages  
✅ **BLoC Integration** - Works seamlessly with GetIt + BLoC

## Navigation Examples

### Basic Navigation

```dart
// Go (replace stack)
AppRoutes.navigateToHome(context);
// or
context.go(AppRoutes.homePath);

// Push (add to stack)
AppRoutes.navigateToNetworkTest(context);
// or
context.push(AppRoutes.networkTestPath);

// Pop (go back)
AppRoutes.navigateBack(context);
// or
context.pop();
```

### Navigation with Parameters

```dart
// Path parameters
context.push('/profile/user123');

// or using helper
AppRoutes.navigateToProfile(context, userId: 'user123');

// Query parameters
context.push('/search?q=flutter&filter=recent');

// Named route with parameters
context.pushNamed(
  AppRoutes.profile,
  pathParameters: {'userId': 'user123'},
  queryParameters: {'tab': 'posts'},
);
```

### Navigation with Extra Data

```dart
// Pass complex objects
context.push(
  AppRoutes.profilePath,
  extra: UserModel(id: '123', name: 'John'),
);

// Access in route builder
pageBuilder: (context, state) {
  final user = state.extra as UserModel?;
  return ProfilePage(user: user);
}
```

### Advanced Navigation

```dart
// Replace with named route
context.goNamed(AppRoutes.home);

// Push replacement
context.pushReplacement(AppRoutes.loginPath);

// Check if can pop
if (context.canPop()) {
  context.pop();
} else {
  context.go(AppRoutes.homePath);
}

// Pop with result
context.pop('result_data');

// Pop until
context.go(AppRoutes.homePath); // Clears stack
```

## Authentication Flow

The router automatically handles authentication:

```dart
redirect: (context, state) {
  final authState = authBloc.state;
  final isAuthenticated = authState is AuthAuthenticated;

  // Redirect to login if not authenticated
  if (!isAuthenticated && state.matchedLocation != AppRoutes.loginPath) {
    return AppRoutes.loginPath;
  }

  // Redirect to home if authenticated and on login page
  if (isAuthenticated && state.matchedLocation == AppRoutes.loginPath) {
    return AppRoutes.homePath;
  }

  return null; // No redirect
}
```

## Adding New Routes

### Step 1: Define Route in `app_routes.dart`

```dart
class AppRoutes {
  // Route name
  static const String products = 'products';

  // Route path
  static const String productsPath = '/products';
  static const String productDetailPath = '/products/:productId';

  // Navigation helper
  static void navigateToProducts(BuildContext context) {
    context.push(productsPath);
  }

  static void navigateToProductDetail(BuildContext context, String productId) {
    context.push('/products/$productId');
  }
}
```

### Step 2: Add Route to `app_router.dart`

```dart
GoRoute(
  path: AppRoutes.productsPath,
  name: AppRoutes.products,
  pageBuilder: (context, state) => _buildPageWithTransition(
    key: state.pageKey,
    child: BlocProvider(
      create: (_) => getIt<ProductsBloc>(),
      child: const ProductsPage(),
    ),
  ),
  // Nested routes (child routes)
  routes: [
    GoRoute(
      path: ':productId', // Relative path
      name: 'product-detail',
      pageBuilder: (context, state) {
        final productId = state.pathParameters['productId']!;
        return _buildPageWithTransition(
          key: state.pageKey,
          child: BlocProvider(
            create: (_) => getIt<ProductDetailBloc>()
              ..add(LoadProductEvent(productId)),
            child: ProductDetailPage(productId: productId),
          ),
        );
      },
    ),
  ],
),
```

## BLoC Integration

go_router works perfectly with BLoC and GetIt:

```dart
GoRoute(
  path: '/feature',
  pageBuilder: (context, state) => CustomTransitionPage(
    key: state.pageKey,
    child: BlocProvider(
      create: (_) => getIt<FeatureBloc>(),
      child: const FeaturePage(),
    ),
  ),
),
```

### Sharing BLoC Across Routes

```dart
// In parent route
GoRoute(
  path: '/parent',
  pageBuilder: (context, state) => CustomTransitionPage(
    key: state.pageKey,
    child: BlocProvider(
      create: (_) => getIt<SharedBloc>(),
      child: const ParentPage(),
    ),
  ),
  routes: [
    // Child route can access parent's BLoC
    GoRoute(
      path: 'child',
      pageBuilder: (context, state) => CustomTransitionPage(
        key: state.pageKey,
        // No BlocProvider needed - uses parent's
        child: const ChildPage(),
      ),
    ),
  ],
),
```

## Custom Transitions

Three transition types available:

### 1. Fade Transition (Default)

```dart
_buildPageWithTransition(
  key: state.pageKey,
  child: const MyPage(),
)
```

### 2. Slide Transition

```dart
_buildPageWithSlideTransition(
  key: state.pageKey,
  child: const MyPage(),
  fromRight: true, // or false for left
)
```

### 3. No Transition

```dart
_buildPageWithNoTransition(
  key: state.pageKey,
  child: const MyPage(),
)
```

## Nested Navigation

For tab-based or shell routes:

```dart
GoRoute(
  path: '/dashboard',
  pageBuilder: (context, state) => NoTransitionPage(
    child: DashboardShell(),
  ),
  routes: [
    GoRoute(
      path: 'home',
      pageBuilder: (context, state) => NoTransitionPage(
        child: const HomeTab(),
      ),
    ),
    GoRoute(
      path: 'profile',
      pageBuilder: (context, state) => NoTransitionPage(
        child: const ProfileTab(),
      ),
    ),
  ],
),
```

## Deep Linking

### Mobile (Android)

**android/app/src/main/AndroidManifest.xml**:

```xml
<intent-filter android:autoVerify="true">
  <action android:name="android.intent.action.VIEW" />
  <category android:name="android.intent.category.DEFAULT" />
  <category android:name="android.intent.category.BROWSABLE" />
  <data android:scheme="https" android:host="yourdomain.com" />
  <data android:scheme="myapp" />
</intent-filter>
```

### Mobile (iOS)

**ios/Runner/Info.plist**:

```xml
<key>CFBundleURLTypes</key>
<array>
  <dict>
    <key>CFBundleTypeRole</key>
    <string>Editor</string>
    <key>CFBundleURLSchemes</key>
    <array>
      <string>myapp</string>
    </array>
  </dict>
</array>
```

### Web

URLs automatically work! Example:

- `https://myapp.com/products/123` → Opens product detail
- `https://myapp.com/login` → Opens login page

## Testing

```dart
testWidgets('Navigation test', (tester) async {
  final router = AppRouter.createRouter(
    authBloc: MockAuthBloc(),
    initialLocation: '/login',
  );

  await tester.pumpWidget(
    MaterialApp.router(
      routerConfig: router,
    ),
  );

  // Navigate
  router.go('/home');
  await tester.pumpAndSettle();

  // Assert
  expect(find.text('Home'), findsOneWidget);
});
```

## Migration Checklist

- [x] Add go_router dependencies
- [x] Update AppRoutes with paths
- [x] Create AppRouter configuration
- [x] Update main.dart to use MaterialApp.router
- [x] Export go_router from core package
- [ ] Update CLI generators to use go_router patterns
- [ ] Delete old app_route_generator.dart (after verification)
- [ ] Test all navigation flows
- [ ] Configure deep linking (Android/iOS)
- [ ] Update documentation

## Common Patterns

### Modal Bottom Sheet with Navigation

```dart
showModalBottomSheet(
  context: context,
  builder: (context) => Column(
    children: [
      ListTile(
        title: const Text('Go to Settings'),
        onTap: () {
          context.pop(); // Close sheet
          context.push(AppRoutes.settingsPath);
        },
      ),
    ],
  ),
);
```

### Confirmation Before Navigation

```dart
Future<bool> _onWillPop() async {
  final result = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Discard changes?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          child: const Text('Discard'),
        ),
      ],
    ),
  );
  return result ?? false;
}
```

## Troubleshooting

### Issue: Router not rebuilding on auth changes

**Solution**: Wrap router creation in BlocBuilder<AuthBloc>

### Issue: BLoC not accessible in child route

**Solution**: Provide BLoC at parent route level

### Issue: Back button not working

**Solution**: Use context.pop() instead of Navigator.pop()

### Issue: Deep link not working

**Solution**: Check Android/iOS configuration and app scheme

## Resources

- [go_router Documentation](https://pub.dev/packages/go_router)
- [go_router GitHub](https://github.com/flutter/packages/tree/main/packages/go_router)
- [Flutter Navigation 2.0](https://docs.flutter.dev/ui/navigation)

## Support

For issues or questions about the routing implementation, check:

1. This migration guide
2. go_router documentation
3. Project's existing route examples in `app_router.dart`
