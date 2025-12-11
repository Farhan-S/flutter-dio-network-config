import 'dart:async';

import 'package:core/core.dart';
import 'package:features_auth/features_auth.dart';
import 'package:features_home/features_home.dart';
import 'package:features_onboarding/features_onboarding.dart';
import 'package:features_splash/features_splash.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../injection_container.dart';

/// GoRouter configuration for the entire app
/// Provides type-safe navigation, deep linking, and URL support
class AppRouter {
  /// Create and configure GoRouter instance
  static GoRouter createRouter({
    required AuthBloc authBloc,
    String? initialLocation,
  }) {
    return GoRouter(
      debugLogDiagnostics: true,
      initialLocation: initialLocation ?? AppRoutes.splashPath,
      refreshListenable: GoRouterRefreshStream(authBloc.stream),

      // Redirect logic for authentication guards
      redirect: (context, state) {
        final authState = authBloc.state;
        final isAuthenticated = authState is AuthAuthenticated;
        final isLoading = authState is AuthInitial || authState is AuthLoading;
        final currentLocation = state.matchedLocation;

        // Don't redirect during loading or initial state
        if (isLoading) {
          return null;
        }

        // Allow splash and onboarding pages always
        if (currentLocation == AppRoutes.splashPath ||
            currentLocation == AppRoutes.onboardingPath) {
          return null;
        }

        // Allow login page for unauthenticated users
        if (currentLocation == AppRoutes.loginPath) {
          // Only redirect away from login if authenticated
          if (isAuthenticated) {
            return AppRoutes.homePath;
          }
          return null;
        }

        // Protect all other routes - require authentication
        if (!isAuthenticated) {
          return AppRoutes.loginPath;
        }

        return null; // No redirect needed
      },

      // Error handling
      errorBuilder: (context, state) => Scaffold(
        appBar: AppBar(title: const Text('Error'), backgroundColor: Colors.red),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                'Route not found: ${state.matchedLocation}',
                style: const TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () => context.go(AppRoutes.homePath),
                icon: const Icon(Icons.home),
                label: const Text('Go Home'),
              ),
            ],
          ),
        ),
      ),

      // Route definitions
      routes: [
        // ==================== Splash Route ====================
        GoRoute(
          path: AppRoutes.splashPath,
          name: AppRoutes.splash,
          pageBuilder: (context, state) => _buildPageWithTransition(
            key: state.pageKey,
            child: BlocProvider(
              create: (_) => getIt<SplashBloc>(),
              child: const SplashPage(),
            ),
          ),
        ),

        // ==================== Onboarding Route ====================
        GoRoute(
          path: AppRoutes.onboardingPath,
          name: AppRoutes.onboarding,
          pageBuilder: (context, state) => _buildPageWithTransition(
            key: state.pageKey,
            child: BlocProvider(
              create: (_) => getIt<OnboardingBloc>(),
              child: const OnboardingPage(),
            ),
          ),
        ),

        // ==================== Auth Routes ====================
        GoRoute(
          path: AppRoutes.loginPath,
          name: AppRoutes.login,
          pageBuilder: (context, state) => _buildPageWithTransition(
            key: state.pageKey,
            child: const LoginPage(),
          ),
        ),

        GoRoute(
          path: AppRoutes.registerPath,
          name: AppRoutes.register,
          pageBuilder: (context, state) => _buildPageWithTransition(
            key: state.pageKey,
            child: const Scaffold(
              body: Center(child: Text('Register Page - Coming Soon')),
            ),
          ),
        ),

        GoRoute(
          path: AppRoutes.forgotPasswordPath,
          name: AppRoutes.forgotPassword,
          pageBuilder: (context, state) => _buildPageWithTransition(
            key: state.pageKey,
            child: const Scaffold(
              body: Center(child: Text('Forgot Password Page - Coming Soon')),
            ),
          ),
        ),

        // ==================== Home Routes ====================
        GoRoute(
          path: AppRoutes.homePath,
          name: AppRoutes.home,
          pageBuilder: (context, state) => _buildPageWithTransition(
            key: state.pageKey,
            child: const HomePage(),
          ),
        ),

        GoRoute(
          path: AppRoutes.networkTestPath,
          name: AppRoutes.networkTest,
          pageBuilder: (context, state) => _buildPageWithTransition(
            key: state.pageKey,
            child: BlocProvider(
              create: (_) => getIt<NetworkTestBloc>(),
              child: const NetworkTestPage(),
            ),
          ),
        ),

        // ==================== User Routes ====================
        GoRoute(
          path: AppRoutes.profilePath,
          name: AppRoutes.profile,
          pageBuilder: (context, state) => _buildPageWithTransition(
            key: state.pageKey,
            child: const Scaffold(
              body: Center(child: Text('Profile Page - Coming Soon')),
            ),
          ),
        ),

        // Profile with user ID parameter
        GoRoute(
          path: AppRoutes.profileWithIdPath,
          name: '${AppRoutes.profile}-with-id',
          pageBuilder: (context, state) {
            final userId = state.pathParameters[AppRoutes.userIdParam];
            return _buildPageWithTransition(
              key: state.pageKey,
              child: Scaffold(
                appBar: AppBar(title: Text('Profile: $userId')),
                body: Center(child: Text('User Profile: $userId')),
              ),
            );
          },
        ),

        GoRoute(
          path: AppRoutes.settingsPath,
          name: AppRoutes.settings,
          pageBuilder: (context, state) => _buildPageWithTransition(
            key: state.pageKey,
            child: const Scaffold(
              body: Center(child: Text('Settings Page - Coming Soon')),
            ),
          ),
        ),
      ],
    );
  }

  /// Build page with custom transition animation
  static Page<dynamic> _buildPageWithTransition({
    required LocalKey key,
    required Widget child,
    Duration duration = const Duration(milliseconds: 300),
  }) {
    return CustomTransitionPage(
      key: key,
      child: child,
      transitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        // Fade transition
        return FadeTransition(
          opacity: CurveTween(curve: Curves.easeInOut).animate(animation),
          child: child,
        );
      },
    );
  }

  /// Build page with slide transition
  // ignore: unused_element
  static Page<dynamic> _buildPageWithSlideTransition({
    required LocalKey key,
    required Widget child,
    bool fromRight = true,
  }) {
    return CustomTransitionPage(
      key: key,
      child: child,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final begin = fromRight
            ? const Offset(1.0, 0.0)
            : const Offset(-1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeInOut;

        final tween = Tween(
          begin: begin,
          end: end,
        ).chain(CurveTween(curve: curve));

        return SlideTransition(position: animation.drive(tween), child: child);
      },
    );
  }

  /// Build page with no transition (instant)
  // ignore: unused_element
  static Page<dynamic> _buildPageWithNoTransition({
    required LocalKey key,
    required Widget child,
  }) {
    return NoTransitionPage(key: key, child: child);
  }
}

/// Helper class to convert a Stream into a Listenable for GoRouter
/// This allows the router to refresh when the auth state changes
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen(
      (dynamic _) => notifyListeners(),
    );
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
