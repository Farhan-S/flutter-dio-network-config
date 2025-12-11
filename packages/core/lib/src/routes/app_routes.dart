import 'package:core/core.dart';
import 'package:flutter/material.dart';

/// Centralized app routes for the entire application
/// All feature modules should register their routes here
///
/// Using go_router path-based routing:
/// - Use paths with parameters: '/user/:id'
/// - Use query parameters: '/search?q=term'
/// - Nested routes use relative paths
class AppRoutes {
  // ==================== Route Names (for go_router) ====================

  // Splash & Onboarding Routes
  static const String splash = 'splash';
  static const String onboarding = 'onboarding';

  // Home Routes
  static const String home = 'home';
  static const String networkTest = 'network-test';

  // Auth Routes
  static const String login = 'login';
  static const String register = 'register';
  static const String forgotPassword = 'forgot-password';

  // User Routes
  static const String profile = 'profile';
  static const String settings = 'settings';

  // ==================== Route Paths ====================

  // Root paths
  static const String splashPath = '/';
  static const String onboardingPath = '/onboarding';
  static const String homePath = '/home';
  static const String networkTestPath = '/network-test';
  static const String loginPath = '/login';
  static const String registerPath = '/register';
  static const String forgotPasswordPath = '/forgot-password';
  static const String profilePath = '/profile';
  static const String profileWithIdPath = '/profile/:userId';
  static const String settingsPath = '/settings';

  // ==================== Route Parameters ====================

  /// Keys for route arguments
  static const String userIdParam = 'userId';

  // ==================== Navigation Helpers (go_router) ====================
  // Note: These methods now require GoRouter to be accessible
  // Import: import 'package:go_router/go_router.dart';

  /// Navigate to splash page (replace all)
  static void navigateToSplash(BuildContext context) {
    context.go(splashPath);
  }

  /// Navigate to onboarding page (replace all)
  static void navigateToOnboarding(BuildContext context) {
    context.go(onboardingPath);
  }

  /// Navigate to home page (replace all)
  static void navigateToHome(BuildContext context) {
    context.go(homePath);
  }

  /// Navigate to login page (replace all)
  static void navigateToLogin(BuildContext context) {
    context.go(loginPath);
  }

  /// Navigate to network test page (push)
  static void navigateToNetworkTest(BuildContext context) {
    context.push(networkTestPath);
  }

  /// Navigate to profile page
  static void navigateToProfile(BuildContext context, {String? userId}) {
    if (userId != null) {
      context.push('/profile/$userId');
    } else {
      context.push(profilePath);
    }
  }

  /// Navigate to register page
  static void navigateToRegister(BuildContext context) {
    context.push(registerPath);
  }

  /// Navigate to forgot password page
  static void navigateToForgotPassword(BuildContext context) {
    context.push(forgotPasswordPath);
  }

  /// Navigate to settings page
  static void navigateToSettings(BuildContext context) {
    context.push(settingsPath);
  }

  /// Navigate back
  static void navigateBack(BuildContext context) {
    context.pop();
  }

  /// Check if can pop
  static bool canPop(BuildContext context) {
    return context.canPop();
  }

  /// Go to named route with parameters
  static void goNamed(
    BuildContext context,
    String name, {
    Map<String, String> pathParameters = const {},
    Map<String, dynamic> queryParameters = const {},
    Object? extra,
  }) {
    context.goNamed(
      name,
      pathParameters: pathParameters,
      queryParameters: queryParameters,
      extra: extra,
    );
  }

  /// Push named route with parameters
  static void pushNamed(
    BuildContext context,
    String name, {
    Map<String, String> pathParameters = const {},
    Map<String, dynamic> queryParameters = const {},
    Object? extra,
  }) {
    context.pushNamed(
      name,
      pathParameters: pathParameters,
      queryParameters: queryParameters,
      extra: extra,
    );
  }
}
