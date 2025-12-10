import 'package:core/core.dart';
import 'package:features_auth/features_auth.dart';
import 'package:features_home/features_home.dart';
import 'package:features_onboarding/features_onboarding.dart';
import 'package:features_splash/features_splash.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../injection_container.dart';

/// Centralized route generator for the entire app
class AppRouteGenerator {
  /// Generate route based on route settings
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    // Get route factory from registry if available
    final factory = AppRouteRegistry.getRouteFactory(settings.name ?? '');
    if (factory != null) {
      final route = factory(settings);
      if (route != null) return route;
    }

    // Fallback to manual route handling
    switch (settings.name) {
      case AppRoutes.splash:
        return _createRoute(
          BlocProvider(
            create: (_) => getIt<SplashBloc>(),
            child: const SplashPage(),
          ),
          settings,
        );

      case AppRoutes.onboarding:
        return _createRoute(
          BlocProvider(
            create: (_) => getIt<OnboardingBloc>(),
            child: const OnboardingPage(),
          ),
          settings,
        );

      case AppRoutes.home:
        return _createRoute(HomePage(dioClient: getIt<DioClient>()), settings);

      case AppRoutes.networkTest:
        return _createRoute(
          BlocProvider(
            create: (_) => getIt<NetworkTestBloc>(),
            child: const NetworkTestPage(),
          ),
          settings,
        );

      case AppRoutes.login:
        return _createRoute(const LoginPage(), settings);

      
      
      default:
        return _createErrorRoute(settings.name);
    }
  }

  /// Create a standard material page route
  static MaterialPageRoute _createRoute(Widget page, RouteSettings settings) {
    return MaterialPageRoute(builder: (_) => page, settings: settings);
  }

  /// Create error page for undefined routes
  static MaterialPageRoute _createErrorRoute(String? routeName) {
    return MaterialPageRoute(
      builder: (_) => Scaffold(
        appBar: AppBar(title: const Text('Error'), backgroundColor: Colors.red),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                'No route defined for: ${routeName ?? 'unknown'}',
                style: const TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: null, // Will be handled by back button
                icon: const Icon(Icons.arrow_back),
                label: const Text('Go Back'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Register all feature routes
  static void registerAllRoutes() {
    // Features can register their routes here
    // This allows features to be modular and self-contained

    // Splash route
    AppRouteRegistry.registerRoute(
      AppRoutes.splash,
      (settings) => MaterialPageRoute(
        builder: (_) => BlocProvider(
          create: (_) => getIt<SplashBloc>(),
          child: const SplashPage(),
        ),
        settings: settings,
      ),
    );

    // Onboarding route
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

    // Example: Register home routes
    AppRouteRegistry.registerRoute(
      AppRoutes.home,
      (settings) => MaterialPageRoute(
        builder: (_) => HomePage(dioClient: getIt<DioClient>()),
        settings: settings,
      ),
    );

    AppRouteRegistry.registerRoute(
      AppRoutes.networkTest,
      (settings) => MaterialPageRoute(
        builder: (_) => BlocProvider(
          create: (_) => getIt<NetworkTestBloc>(),
          child: const NetworkTestPage(),
        ),
        settings: settings,
      ),
    );

    // Auth routes can be registered similarly
    AppRouteRegistry.registerRoute(
      AppRoutes.login,
      (settings) => MaterialPageRoute(
        builder: (_) => BlocProvider(
          create: (_) => getIt<AuthBloc>(),
          child: const LoginPage(),
        ),
        settings: settings,
      ),
    );
  }
}
