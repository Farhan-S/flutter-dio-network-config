/// Token storage interface for managing authentication tokens
/// Implement this with your preferred storage solution
/// (SharedPreferences, FlutterSecureStorage, Hive, etc.)
abstract class TokenStorage {
  /// Save access token
  Future<void> saveAccessToken(String token);

  /// Save refresh token
  Future<void> saveRefreshToken(String token);

  /// Get access token
  Future<String?> getAccessToken();

  /// Get refresh token
  Future<String?> getRefreshToken();

  /// Clear all tokens
  Future<void> clearTokens();

  /// Check if user is authenticated (has valid token)
  Future<bool> isAuthenticated();

  /// Factory constructor for default implementation
  factory TokenStorage() => _TokenStorageImpl();
}

/// Default implementation using memory storage
/// Replace this with secure storage in production (e.g., flutter_secure_storage)
class _TokenStorageImpl implements TokenStorage {
  static final _TokenStorageImpl _instance = _TokenStorageImpl._internal();

  String? _accessToken;
  String? _refreshToken;

  factory _TokenStorageImpl() => _instance;

  _TokenStorageImpl._internal();

  @override
  Future<void> saveAccessToken(String token) async {
    _accessToken = token;
    // TODO: In production, save to secure storage
    // await secureStorage.write(key: 'access_token', value: token);
  }

  @override
  Future<void> saveRefreshToken(String token) async {
    _refreshToken = token;
    // TODO: In production, save to secure storage
    // await secureStorage.write(key: 'refresh_token', value: token);
  }

  @override
  Future<String?> getAccessToken() async {
    // TODO: In production, read from secure storage
    // return await secureStorage.read(key: 'access_token');
    return _accessToken;
  }

  @override
  Future<String?> getRefreshToken() async {
    // TODO: In production, read from secure storage
    // return await secureStorage.read(key: 'refresh_token');
    return _refreshToken;
  }

  @override
  Future<void> clearTokens() async {
    _accessToken = null;
    _refreshToken = null;
    // TODO: In production, clear from secure storage
    // await secureStorage.delete(key: 'access_token');
    // await secureStorage.delete(key: 'refresh_token');
  }

  @override
  Future<bool> isAuthenticated() async {
    final token = await getAccessToken();
    return token != null && token.isNotEmpty;
  }
}

/// Example implementation with flutter_secure_storage
/// Uncomment and use this in production
/*
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureTokenStorage implements TokenStorage {
  static final SecureTokenStorage _instance = SecureTokenStorage._internal();
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  
  factory SecureTokenStorage() => _instance;
  
  SecureTokenStorage._internal();

  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';

  @override
  Future<void> saveAccessToken(String token) async {
    await _storage.write(key: _accessTokenKey, value: token);
  }

  @override
  Future<void> saveRefreshToken(String token) async {
    await _storage.write(key: _refreshTokenKey, value: token);
  }

  @override
  Future<String?> getAccessToken() async {
    return await _storage.read(key: _accessTokenKey);
  }

  @override
  Future<String?> getRefreshToken() async {
    return await _storage.read(key: _refreshTokenKey);
  }

  @override
  Future<void> clearTokens() async {
    await _storage.delete(key: _accessTokenKey);
    await _storage.delete(key: _refreshTokenKey);
  }

  @override
  Future<bool> isAuthenticated() async {
    final token = await getAccessToken();
    return token != null && token.isNotEmpty;
  }
}
*/
