/// Centralized asset paths for the Flutter application.
///
/// This class provides compile-time constants for all asset paths used in the
/// presentation layer. Using constants prevents typo bugs, enables refactoring,
/// and provides IDE autocomplete.
///
/// **CRITICAL RULE**: Assets should ONLY be used in the presentation/UI layer.
/// - ✅ Use in: Widgets, Pages
/// - ❌ Do NOT use in: BLoC, UseCases, Repositories, DataSources
///
/// This preserves Clean Architecture dependency rules and keeps business logic
/// platform-independent.
///
/// Example usage:
/// ```dart
/// Image.asset(AppAssets.appLogo);
/// SvgPicture.asset(AppAssets.homeIcon);
/// ```
///
/// Reference:
/// - Flutter assets guide: https://docs.flutter.dev/development/ui/assets-and-images
/// - BLoC architecture: https://bloclibrary.dev/#/architecture
/// - Clean Architecture: https://8thlight.com/blog/uncle-bob/2012/08/13/the-clean-architecture.html
class AppAssets {
  // Private constructor to prevent instantiation
  AppAssets._();

  // ============================================================================
  // Common Images
  // ============================================================================

  /// Main application logo
  /// Used in splash screen, login, and about pages
  static const String appLogo = 'assets/images/common/app_logo.png';

  // ============================================================================
  // Auth Images
  // ============================================================================

  /// Background image for login screen
  static const String loginBackground = 'assets/images/auth/login_bg.png';

  // ============================================================================
  // Dashboard Images
  // ============================================================================

  /// Banner image displayed on dashboard
  static const String dashboardBanner =
      'assets/images/dashboard/dashboard_banner.png';

  // ============================================================================
  // Icons
  // ============================================================================

  /// Home navigation icon (SVG)
  /// Requires flutter_svg package: https://pub.dev/packages/flutter_svg
  static const String homeIcon = 'assets/icons/home.svg';

  // ============================================================================
  // Animations
  // ============================================================================

  /// Loading animation (Lottie JSON)
  /// Requires lottie package: https://pub.dev/packages/lottie
  static const String loadingAnimation = 'assets/animations/loading.json';

  // ============================================================================
  // Fonts
  // ============================================================================
  // Note: Fonts are typically registered in pubspec.yaml under flutter.fonts
  // and accessed via TextStyle(fontFamily: 'Roboto')
}
