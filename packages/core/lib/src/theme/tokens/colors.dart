import 'package:flutter/material.dart';

/// Design token: Color palette for the application
/// Following Material 3 color system
class AppColors {
  AppColors._();

  // Primary colors
  static const Color primaryLight = Color(0xFF1976D2); // Blue 700
  static const Color primaryDark = Color(0xFF90CAF9); // Blue 200
  static const Color primaryContainerLight = Color(0xFFBBDEFB); // Blue 100
  static const Color primaryContainerDark = Color(0xFF1565C0); // Blue 800

  // Secondary colors
  static const Color secondaryLight = Color(0xFF7B1FA2); // Purple 700
  static const Color secondaryDark = Color(0xFFCE93D8); // Purple 200
  static const Color secondaryContainerLight = Color(0xFFE1BEE7); // Purple 100
  static const Color secondaryContainerDark = Color(0xFF6A1B9A); // Purple 800

  // Tertiary colors
  static const Color tertiaryLight = Color(0xFFFF6F00); // Orange 900
  static const Color tertiaryDark = Color(0xFFFFB74D); // Orange 300
  static const Color tertiaryContainerLight = Color(0xFFFFE0B2); // Orange 100
  static const Color tertiaryContainerDark = Color(
    0xFFE65100,
  ); // Orange 900 dark

  // Error colors
  static const Color errorLight = Color(0xFFD32F2F); // Red 700
  static const Color errorDark = Color(0xFFEF9A9A); // Red 200
  static const Color errorContainerLight = Color(0xFFFFCDD2); // Red 100
  static const Color errorContainerDark = Color(0xFFC62828); // Red 800

  // Success colors
  static const Color successLight = Color(0xFF388E3C); // Green 700
  static const Color successDark = Color(0xFF81C784); // Green 300
  static const Color successContainerLight = Color(0xFFC8E6C9); // Green 100
  static const Color successContainerDark = Color(0xFF2E7D32); // Green 800

  // Warning colors
  static const Color warningLight = Color(0xFFF57C00); // Orange 700
  static const Color warningDark = Color(0xFFFFB74D); // Orange 300
  static const Color warningContainerLight = Color(0xFFFFE0B2); // Orange 100
  static const Color warningContainerDark = Color(0xFFEF6C00); // Orange 800

  // Info colors
  static const Color infoLight = Color(0xFF0288D1); // Light Blue 700
  static const Color infoDark = Color(0xFF4FC3F7); // Light Blue 300
  static const Color infoContainerLight = Color(0xFFB3E5FC); // Light Blue 100
  static const Color infoContainerDark = Color(0xFF0277BD); // Light Blue 800

  // Surface colors
  static const Color surfaceLight = Color(0xFFFAFAFA); // Grey 50
  static const Color surfaceDark = Color(0xFF121212); // Almost black
  static const Color surfaceVariantLight = Color(0xFFF5F5F5); // Grey 100
  static const Color surfaceVariantDark = Color(0xFF1E1E1E);

  // Background colors
  static const Color backgroundLight = Color(0xFFFFFFFF);
  static const Color backgroundDark = Color(0xFF0A0A0A);

  // On colors (text on colored backgrounds)
  static const Color onPrimaryLight = Color(0xFFFFFFFF);
  static const Color onPrimaryDark = Color(0xFF000000);
  static const Color onSecondaryLight = Color(0xFFFFFFFF);
  static const Color onSecondaryDark = Color(0xFF000000);
  static const Color onErrorLight = Color(0xFFFFFFFF);
  static const Color onErrorDark = Color(0xFF000000);
  static const Color onBackgroundLight = Color(0xFF000000);
  static const Color onBackgroundDark = Color(0xFFFFFFFF);
  static const Color onSurfaceLight = Color(0xFF000000);
  static const Color onSurfaceDark = Color(0xFFFFFFFF);

  // Outline colors
  static const Color outlineLight = Color(0xFFBDBDBD); // Grey 400
  static const Color outlineDark = Color(0xFF616161); // Grey 700
  static const Color outlineVariantLight = Color(0xFFE0E0E0); // Grey 300
  static const Color outlineVariantDark = Color(0xFF424242); // Grey 800

  // Shadow colors
  static const Color shadowLight = Color(0x1F000000);
  static const Color shadowDark = Color(0x3F000000);

  // Scrim colors
  static const Color scrimLight = Color(0x99000000);
  static const Color scrimDark = Color(0xBB000000);

  // Inverse colors
  static const Color inverseSurfaceLight = Color(0xFF303030);
  static const Color inverseSurfaceDark = Color(0xFFE0E0E0);
  static const Color inversePrimaryLight = Color(0xFF90CAF9);
  static const Color inversePrimaryDark = Color(0xFF1976D2);

  // Neutral colors
  static const Color neutral0 = Color(0xFF000000);
  static const Color neutral10 = Color(0xFF1A1A1A);
  static const Color neutral20 = Color(0xFF333333);
  static const Color neutral30 = Color(0xFF4D4D4D);
  static const Color neutral40 = Color(0xFF666666);
  static const Color neutral50 = Color(0xFF808080);
  static const Color neutral60 = Color(0xFF999999);
  static const Color neutral70 = Color(0xFFB3B3B3);
  static const Color neutral80 = Color(0xFFCCCCCC);
  static const Color neutral90 = Color(0xFFE6E6E6);
  static const Color neutral95 = Color(0xFFF2F2F2);
  static const Color neutral99 = Color(0xFFFCFCFC);
  static const Color neutral100 = Color(0xFFFFFFFF);

  // Authentication specific colors
  static const Color authButtonLight = primaryLight;
  static const Color authButtonDark = primaryDark;
  static const Color authBackgroundLight = backgroundLight;
  static const Color authBackgroundDark = backgroundDark;

  // Card colors
  static const Color cardLight = Color(0xFFFFFFFF);
  static const Color cardDark = Color(0xFF1E1E1E);
}
