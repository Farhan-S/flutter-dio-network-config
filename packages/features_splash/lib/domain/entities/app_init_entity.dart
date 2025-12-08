import 'package:equatable/equatable.dart';

/// Entity representing app initialization status
class AppInitEntity extends Equatable {
  final bool isInitialized;
  final bool isAuthenticated;
  final bool hasCompletedOnboarding;
  final String? userId;
  final String? errorMessage;

  const AppInitEntity({
    required this.isInitialized,
    required this.isAuthenticated,
    required this.hasCompletedOnboarding,
    this.userId,
    this.errorMessage,
  });

  @override
  List<Object?> get props => [
    isInitialized,
    isAuthenticated,
    hasCompletedOnboarding,
    userId,
    errorMessage,
  ];

  @override
  String toString() {
    return 'AppInitEntity(isInitialized: $isInitialized, isAuthenticated: $isAuthenticated, hasCompletedOnboarding: $hasCompletedOnboarding, userId: $userId)';
  }
}
