import '../../domain/entities/app_init_entity.dart';

/// Model for app initialization (extends entity)
class AppInitModel extends AppInitEntity {
  const AppInitModel({
    required super.isInitialized,
    required super.isAuthenticated,
    required super.hasCompletedOnboarding,
    super.userId,
    super.errorMessage,
  });

  /// Create model from entity
  factory AppInitModel.fromEntity(AppInitEntity entity) {
    return AppInitModel(
      isInitialized: entity.isInitialized,
      isAuthenticated: entity.isAuthenticated,
      hasCompletedOnboarding: entity.hasCompletedOnboarding,
      userId: entity.userId,
      errorMessage: entity.errorMessage,
    );
  }

  /// Create model from JSON
  factory AppInitModel.fromJson(Map<String, dynamic> json) {
    return AppInitModel(
      isInitialized: json['isInitialized'] as bool? ?? false,
      isAuthenticated: json['isAuthenticated'] as bool? ?? false,
      hasCompletedOnboarding: json['hasCompletedOnboarding'] as bool? ?? false,
      userId: json['userId'] as String?,
      errorMessage: json['errorMessage'] as String?,
    );
  }

  /// Convert model to JSON
  Map<String, dynamic> toJson() {
    return {
      'isInitialized': isInitialized,
      'isAuthenticated': isAuthenticated,
      'hasCompletedOnboarding': hasCompletedOnboarding,
      'userId': userId,
      'errorMessage': errorMessage,
    };
  }

  /// Create a copy with updated values
  AppInitModel copyWith({
    bool? isInitialized,
    bool? isAuthenticated,
    bool? hasCompletedOnboarding,
    String? userId,
    String? errorMessage,
  }) {
    return AppInitModel(
      isInitialized: isInitialized ?? this.isInitialized,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      hasCompletedOnboarding:
          hasCompletedOnboarding ?? this.hasCompletedOnboarding,
      userId: userId ?? this.userId,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
