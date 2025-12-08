import 'package:core/core.dart';
import 'package:features_auth/features_auth.dart';
import 'package:features_user/features_user.dart';

/// Mock authentication data source for development and testing
/// Simulates real API responses without making actual network calls
class AuthMockDataSource {
  final TokenStorage? _tokenStorage;

  AuthMockDataSource({TokenStorage? tokenStorage})
    : _tokenStorage = tokenStorage;
  // Mock database of users
  static final List<Map<String, dynamic>> _mockUsers = [
    {
      'id': '1',
      'name': 'Demo User',
      'email': 'demo@test.com',
      'password': 'password123',
      'avatar': 'https://i.pravatar.cc/150?img=1',
      'created_at': '2024-01-01T00:00:00.000Z',
    },
    {
      'id': '2',
      'name': 'Admin User',
      'email': 'admin@test.com',
      'password': 'admin123',
      'avatar': 'https://i.pravatar.cc/150?img=2',
      'created_at': '2024-01-01T00:00:00.000Z',
    },
    {
      'id': '3',
      'name': 'Test User',
      'email': 'test@test.com',
      'password': 'test123',
      'avatar': 'https://i.pravatar.cc/150?img=3',
      'created_at': '2024-01-15T00:00:00.000Z',
    },
  ];

  // Current authenticated user ID
  String? _currentUserId;

  /// Simulate network delay
  Future<void> _delay() async {
    await Future.delayed(const Duration(milliseconds: 800));
  }

  /// Generate mock JWT token
  String _generateMockToken(String userId) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return 'mock_token_${userId}_$timestamp';
  }

  /// Login with email and password
  Future<AuthTokenModel> login({
    required String email,
    required String password,
  }) async {
    await _delay();

    // Find user by email
    final user = _mockUsers.firstWhere(
      (u) => u['email'] == email,
      orElse: () => throw UnauthorizedException(
        'Invalid email or password',
        null,
        StackTrace.current,
      ),
    );

    // Check password
    if (user['password'] != password) {
      throw UnauthorizedException(
        'Invalid email or password',
        null,
        StackTrace.current,
      );
    }

    // Set current user
    _currentUserId = user['id'] as String;

    // Generate tokens
    return AuthTokenModel(
      accessToken: _generateMockToken(user['id'] as String),
      refreshToken:
          'mock_refresh_token_${user['id']}_${DateTime.now().millisecondsSinceEpoch}',
      expiresIn: 3600, // 1 hour
      tokenType: 'Bearer',
    );
  }

  /// Register new user
  Future<AuthTokenModel> register({
    required String name,
    required String email,
    required String password,
  }) async {
    await _delay();

    // Check if email already exists
    final exists = _mockUsers.any((u) => u['email'] == email);
    if (exists) {
      throw ValidationException(
        'Email already registered',
        null,
        StackTrace.current,
      );
    }

    // Validate password
    if (password.length < 6) {
      throw ValidationException(
        'Password must be at least 6 characters',
        null,
        StackTrace.current,
      );
    }

    // Create new user
    final newUser = {
      'id': (_mockUsers.length + 1).toString(),
      'name': name,
      'email': email,
      'password': password,
      'avatar': 'https://i.pravatar.cc/150?img=${_mockUsers.length + 1}',
      'created_at': DateTime.now().toIso8601String(),
    };

    _mockUsers.add(newUser);
    _currentUserId = newUser['id'] as String;

    // Generate tokens
    return AuthTokenModel(
      accessToken: _generateMockToken(newUser['id'] as String),
      refreshToken:
          'mock_refresh_token_${newUser['id']}_${DateTime.now().millisecondsSinceEpoch}',
      expiresIn: 3600,
      tokenType: 'Bearer',
    );
  }

  /// Refresh access token
  Future<AuthTokenModel> refreshToken({required String refreshToken}) async {
    await _delay();

    // Validate refresh token format
    if (!refreshToken.startsWith('mock_refresh_token_')) {
      throw UnauthorizedException(
        'Invalid refresh token',
        null,
        StackTrace.current,
      );
    }

    // Extract user ID from refresh token
    final parts = refreshToken.split('_');
    if (parts.length < 4) {
      throw UnauthorizedException(
        'Invalid refresh token',
        null,
        StackTrace.current,
      );
    }

    final userId = parts[3];

    // Check if user exists
    final userExists = _mockUsers.any((u) => u['id'] == userId);
    if (!userExists) {
      throw UnauthorizedException('User not found', null, StackTrace.current);
    }

    // Generate new tokens
    return AuthTokenModel(
      accessToken: _generateMockToken(userId),
      refreshToken:
          'mock_refresh_token_${userId}_${DateTime.now().millisecondsSinceEpoch}',
      expiresIn: 3600,
      tokenType: 'Bearer',
    );
  }

  /// Get current authenticated user
  Future<UserModel> getCurrentUser() async {
    await _delay();

    // Try to get user ID from current session or token
    String? userId = _currentUserId;

    // If no session, try to extract from token storage (if available)
    if (userId == null && _tokenStorage != null) {
      try {
        final token = await _tokenStorage.getAccessToken();
        if (token != null && token.startsWith('mock_token_')) {
          // Extract user ID from token format: mock_token_<userId>_<timestamp>
          final parts = token.split('_');
          if (parts.length >= 3) {
            userId = parts[2];
          }
        }
      } catch (_) {
        // Ignore token retrieval errors
      }
    }

    // Check if user is authenticated
    if (userId == null) {
      throw UnauthorizedException(
        'Not authenticated',
        null,
        StackTrace.current,
      );
    }

    // Find user by ID
    final user = _mockUsers.firstWhere(
      (u) => u['id'] == userId,
      orElse: () =>
          throw NotFoundException('User not found', null, StackTrace.current),
    );

    // Return user without password
    final userData = Map<String, dynamic>.from(user);
    userData.remove('password');

    return UserModel.fromJson(userData);
  }

  /// Set current user ID (for testing/mocking token validation)
  void setCurrentUserId(String? userId) {
    _currentUserId = userId;
  }

  /// Get mock user for testing
  static Map<String, dynamic>? getMockUserByEmail(String email) {
    try {
      return _mockUsers.firstWhere((u) => u['email'] == email);
    } catch (_) {
      return null;
    }
  }

  /// Get all mock users (for admin/testing purposes)
  static List<Map<String, dynamic>> getAllMockUsers() {
    return _mockUsers.map((u) {
      final userData = Map<String, dynamic>.from(u);
      userData.remove('password'); // Don't expose passwords
      return userData;
    }).toList();
  }
}
