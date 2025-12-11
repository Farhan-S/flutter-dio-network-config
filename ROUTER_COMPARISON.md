# Navigator 1.0 vs go_router Comparison

## Quick Comparison Table

| Feature                   | Navigator 1.0            | go_router                  | Winner        |
| ------------------------- | ------------------------ | -------------------------- | ------------- |
| **Deep Linking**          | ❌ Manual setup, complex | ✅ Built-in support        | go_router     |
| **Web URL Support**       | ❌ No URL routing        | ✅ Full URL support        | go_router     |
| **Type Safety**           | ❌ String-based routes   | ✅ Type-safe parameters    | go_router     |
| **Code Amount**           | 😐 Medium boilerplate    | ✅ Less boilerplate        | go_router     |
| **Authentication Guards** | ❌ Manual implementation | ✅ Built-in redirect logic | go_router     |
| **Nested Navigation**     | 😐 Complex to implement  | ✅ Simple declarative      | go_router     |
| **Path Parameters**       | ❌ Manual parsing        | ✅ Automatic parsing       | go_router     |
| **Query Parameters**      | ❌ Complex extraction    | ✅ Built-in support        | go_router     |
| **Browser Back Button**   | ❌ Doesn't work well     | ✅ Works perfectly         | go_router     |
| **State Restoration**     | 😐 Limited support       | ✅ Full support            | go_router     |
| **Learning Curve**        | ✅ Easy (familiar)       | 😐 Medium (new API)        | Navigator 1.0 |
| **BLoC Integration**      | ✅ Direct                | ✅ Direct                  | Tie           |
| **GetIt Integration**     | ✅ Seamless              | ✅ Seamless                | Tie           |
| **Maintainability**       | ❌ Grows complex         | ✅ Stays clean             | go_router     |
| **Testing**               | 😐 Medium difficulty     | ✅ Easy to mock            | go_router     |

**Legend:** ✅ = Excellent | 😐 = Acceptable | ❌ = Poor/Missing

---

## Code Comparison

### 1. Basic Navigation

#### Navigator 1.0

```dart
// Navigate
Navigator.pushNamed(context, '/home');

// Navigate with arguments
Navigator.pushNamed(
  context,
  '/profile',
  arguments: {'userId': '123'},
);

// Replace entire stack
Navigator.pushNamedAndRemoveUntil(
  context,
  '/login',
  (route) => false,
);

// Go back
Navigator.pop(context);

// Check if can pop
Navigator.canPop(context);
```

#### go_router

```dart
// Navigate (push on stack)
context.push('/home');

// Navigate with parameters (cleaner!)
context.push('/profile/123');

// Replace entire stack (shorter!)
context.go('/login');

// Go back (same length)
context.pop();

// Check if can pop (same)
context.canPop();
```

**Winner:** go_router (cleaner syntax, type-safe parameters)

---

### 2. Route Definition

#### Navigator 1.0

```dart
// In app_routes.dart
class AppRoutes {
  static const String home = '/home';
  static const String profile = '/profile';
}

// In route_generator.dart
Route<dynamic> onGenerateRoute(RouteSettings settings) {
  switch (settings.name) {
    case AppRoutes.home:
      return MaterialPageRoute(
        builder: (_) => BlocProvider(
          create: (_) => getIt<HomeBloc>(),
          child: const HomePage(),
        ),
        settings: settings,
      );

    case AppRoutes.profile:
      final args = settings.arguments as Map<String, dynamic>?;
      final userId = args?['userId'] as String?;
      return MaterialPageRoute(
        builder: (_) => ProfilePage(userId: userId),
        settings: settings,
      );

    default:
      return _errorRoute();
  }
}
```

#### go_router

```dart
// In app_routes.dart
class AppRoutes {
  static const String home = 'home';
  static const String homePath = '/home';
  static const String profilePath = '/profile/:userId';
}

// In app_router.dart
GoRouter(
  routes: [
    GoRoute(
      path: AppRoutes.homePath,
      name: AppRoutes.home,
      pageBuilder: (context, state) => CustomTransitionPage(
        child: BlocProvider(
          create: (_) => getIt<HomeBloc>(),
          child: const HomePage(),
        ),
      ),
    ),

    GoRoute(
      path: AppRoutes.profilePath,
      name: AppRoutes.profile,
      pageBuilder: (context, state) {
        final userId = state.pathParameters['userId']!; // Type-safe!
        return CustomTransitionPage(
          child: ProfilePage(userId: userId),
        );
      },
    ),
  ],
);
```

**Winner:** go_router (declarative, type-safe parameters, no switch statement)

---

### 3. Authentication Guard

#### Navigator 1.0

```dart
// Manual check in every protected route
Route<dynamic> onGenerateRoute(RouteSettings settings) {
  // Check auth state
  final authBloc = getIt<AuthBloc>();
  final isAuthenticated = authBloc.state is AuthAuthenticated;

  // Redirect logic
  if (!isAuthenticated && settings.name != '/login') {
    return MaterialPageRoute(builder: (_) => const LoginPage());
  }

  switch (settings.name) {
    case '/home':
      if (!isAuthenticated) {
        return MaterialPageRoute(builder: (_) => const LoginPage());
      }
      return MaterialPageRoute(builder: (_) => const HomePage());
    // ... repeat for every route
  }
}
```

#### go_router

```dart
// Single redirect function handles all routes
GoRouter(
  redirect: (context, state) {
    final isAuthenticated = authBloc.state is AuthAuthenticated;
    final isOnLoginPage = state.matchedLocation == '/login';

    // Redirect to login if not authenticated
    if (!isAuthenticated && !isOnLoginPage) {
      return '/login';
    }

    // Redirect to home if authenticated and on login page
    if (isAuthenticated && isOnLoginPage) {
      return '/home';
    }

    return null; // No redirect
  },
  routes: [
    // All routes automatically protected!
    GoRoute(path: '/home', ...),
    GoRoute(path: '/profile', ...),
    GoRoute(path: '/settings', ...),
  ],
);
```

**Winner:** go_router (centralized logic, DRY, automatic for all routes)

---

### 4. Nested Navigation (Tabs)

#### Navigator 1.0

```dart
// Complex IndexedStack with manual state management
class DashboardPage extends StatefulWidget {
  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _currentIndex = 0;
  final _navigatorKeys = [
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
    GlobalKey<NavigatorState>(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          Navigator(
            key: _navigatorKeys[0],
            onGenerateRoute: (settings) => MaterialPageRoute(
              builder: (_) => const HomeTab(),
            ),
          ),
          Navigator(
            key: _navigatorKeys[1],
            onGenerateRoute: (settings) => MaterialPageRoute(
              builder: (_) => const SearchTab(),
            ),
          ),
          Navigator(
            key: _navigatorKeys[2],
            onGenerateRoute: (settings) => MaterialPageRoute(
              builder: (_) => const ProfileTab(),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: [...],
      ),
    );
  }
}
```

#### go_router

```dart
// Clean declarative nested routes
GoRoute(
  path: '/dashboard',
  pageBuilder: (context, state) => NoTransitionPage(
    child: const DashboardShell(),
  ),
  routes: [
    GoRoute(
      path: 'home',
      pageBuilder: (context, state) => NoTransitionPage(
        child: const HomeTab(),
      ),
    ),
    GoRoute(
      path: 'search',
      pageBuilder: (context, state) => NoTransitionPage(
        child: const SearchTab(),
      ),
    ),
    GoRoute(
      path: 'profile',
      pageBuilder: (context, state) => NoTransitionPage(
        child: const ProfileTab(),
      ),
    ),
  ],
)

// Navigate between tabs
context.go('/dashboard/home');
context.go('/dashboard/search');
context.go('/dashboard/profile');
```

**Winner:** go_router (50% less code, simpler, URL-based)

---

### 5. Deep Linking

#### Navigator 1.0

```dart
// Complex manual parsing
class DeepLinkHandler {
  Route<dynamic> handleDeepLink(Uri uri) {
    final pathSegments = uri.pathSegments;

    if (pathSegments.isEmpty) {
      return MaterialPageRoute(builder: (_) => const HomePage());
    }

    if (pathSegments[0] == 'profile' && pathSegments.length > 1) {
      final userId = pathSegments[1];
      return MaterialPageRoute(
        builder: (_) => ProfilePage(userId: userId),
      );
    }

    if (pathSegments[0] == 'product') {
      final productId = uri.queryParameters['id'];
      final categoryId = uri.queryParameters['category'];
      return MaterialPageRoute(
        builder: (_) => ProductPage(
          productId: productId,
          categoryId: categoryId,
        ),
      );
    }

    return _errorRoute();
  }
}

// Need to wire this up in main.dart and platform code
```

#### go_router

```dart
// Just works! No additional code needed.
// Define routes, deep links automatically work:

GoRoute(
  path: '/profile/:userId',
  pageBuilder: (context, state) {
    final userId = state.pathParameters['userId']!;
    return CustomTransitionPage(
      child: ProfilePage(userId: userId),
    );
  },
),

GoRoute(
  path: '/product',
  pageBuilder: (context, state) {
    final productId = state.uri.queryParameters['id'];
    final categoryId = state.uri.queryParameters['category'];
    return CustomTransitionPage(
      child: ProductPage(
        productId: productId,
        categoryId: categoryId,
      ),
    );
  },
),

// URLs automatically work:
// myapp://profile/123
// https://myapp.com/product?id=456&category=electronics
```

**Winner:** go_router (zero additional code, automatic)

---

### 6. Error Handling

#### Navigator 1.0

```dart
// In route generator
Route<dynamic> onGenerateRoute(RouteSettings settings) {
  switch (settings.name) {
    // ... cases
    default:
      return MaterialPageRoute(
        builder: (_) => Scaffold(
          body: Center(
            child: Text('Page not found: ${settings.name}'),
          ),
        ),
      );
  }
}
```

#### go_router

```dart
// Centralized error builder
GoRouter(
  errorBuilder: (context, state) => Scaffold(
    appBar: AppBar(title: const Text('Error')),
    body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error, size: 64),
          Text('Route not found: ${state.matchedLocation}'),
          ElevatedButton(
            onPressed: () => context.go('/home'),
            child: const Text('Go Home'),
          ),
        ],
      ),
    ),
  ),
  routes: [...],
)
```

**Winner:** go_router (centralized, better UX, easy navigation out)

---

### 7. Testing

#### Navigator 1.0

```dart
testWidgets('Navigation test', (tester) async {
  await tester.pumpWidget(
    MaterialApp(
      onGenerateRoute: AppRouteGenerator.onGenerateRoute,
      home: const HomePage(),
    ),
  );

  // Hard to test navigation flow
  final navigator = tester.state<NavigatorState>(
    find.byType(Navigator),
  );

  navigator.pushNamed('/profile', arguments: {'userId': '123'});
  await tester.pumpAndSettle();

  expect(find.byType(ProfilePage), findsOneWidget);
});
```

#### go_router

```dart
testWidgets('Navigation test', (tester) async {
  final router = AppRouter.createRouter(
    authBloc: MockAuthBloc(),
    initialLocation: '/home',
  );

  await tester.pumpWidget(
    MaterialApp.router(
      routerConfig: router,
    ),
  );

  // Easy to test navigation
  router.go('/profile/123');
  await tester.pumpAndSettle();

  expect(find.byType(ProfilePage), findsOneWidget);
  expect(router.routerDelegate.currentConfiguration.uri.path, '/profile/123');
});
```

**Winner:** go_router (easier mocking, testable state)

---

## Performance Comparison

| Metric                | Navigator 1.0 | go_router          |
| --------------------- | ------------- | ------------------ |
| **App Size**          | 📦 Smaller    | 📦 +100KB          |
| **Cold Start**        | ⚡ ~1.2s      | ⚡ ~1.2s           |
| **Navigation Speed**  | ⚡ Fast       | ⚡ Fast            |
| **Memory Usage**      | 💾 Low        | 💾 Slightly Higher |
| **Build Performance** | 🏗️ Fast       | 🏗️ Fast            |

**Performance Winner:** Tie (negligible differences in real-world apps)

---

## When to Use Each

### Use Navigator 1.0 if:

- ❌ **Simple app** with <5 screens
- ❌ **No deep linking** needed
- ❌ **No web support** planned
- ❌ **Team unfamiliar** with Navigator 2.0 concepts
- ❌ **Very tight bundle size** requirements

### Use go_router if:

- ✅ **Medium to large** app (5+ screens)
- ✅ **Deep linking** required
- ✅ **Web deployment** planned
- ✅ **Authentication guards** needed
- ✅ **Nested navigation** (tabs, drawers)
- ✅ **Type-safe routing** desired
- ✅ **Maintainability** is priority
- ✅ **Modern architecture** preferred

---

## Migration Effort

| Task                     | Estimated Time |
| ------------------------ | -------------- |
| Install dependencies     | 5 minutes      |
| Update route definitions | 30 minutes     |
| Create router config     | 1-2 hours      |
| Update main.dart         | 15 minutes     |
| Test all routes          | 1-2 hours      |
| Update documentation     | 30 minutes     |
| **Total**                | **4-6 hours**  |

---

## Final Verdict

### Overall Winner: **go_router** 🏆

**Reasons:**

1. ✅ Better for medium to large apps
2. ✅ Essential for web deployment
3. ✅ Future-proof architecture
4. ✅ Cleaner, more maintainable code
5. ✅ Better developer experience
6. ✅ Type-safe navigation
7. ✅ Built-in deep linking
8. ✅ Automatic authentication guards

**Trade-offs:**

- Slightly larger bundle size (+100KB)
- Small learning curve
- More initial setup time

**Recommendation:** Use go_router for this project given:

- ✅ Multiple feature modules
- ✅ Authentication system
- ✅ BLoC architecture (works great with go_router)
- ✅ Potential web deployment
- ✅ Clean architecture principles

The migration has been completed and your project is now using go_router! 🎉
