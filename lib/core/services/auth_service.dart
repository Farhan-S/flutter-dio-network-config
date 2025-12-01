import '../network/api_exceptions.dart';
import '../network/api_response.dart';
import '../network/api_routes.dart';
import '../network/dio_client.dart';

/// Authentication service following Clean Architecture principles
/// This is a DATA LAYER service that uses DioClient
class AuthService {
  final DioClient _dioClient;

  AuthService({DioClient? dioClient}) : _dioClient = dioClient ?? DioClient();

  /// Login user with email and password
  /// Returns Result<Map> with user data and tokens
  Future<Result<Map<String, dynamic>>> login(
    String email,
    String password,
  ) async {
    try {
      final response = await _dioClient.post(
        ApiRoutes.login,
        data: {'email': email, 'password': password},
      );

      // Parse response
      final data = response.data as Map<String, dynamic>;
      return Success(data);
    } on ApiException catch (e) {
      return Failure(e);
    } catch (e) {
      return Failure(UnknownException('Login failed: ${e.toString()}'));
    }
  }

  /// Register new user
  Future<Result<Map<String, dynamic>>> register({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      final response = await _dioClient.post(
        ApiRoutes.register,
        data: {'email': email, 'password': password, 'name': name},
      );

      final data = response.data as Map<String, dynamic>;
      return Success(data);
    } on ApiException catch (e) {
      return Failure(e);
    } catch (e) {
      return Failure(UnknownException('Registration failed: ${e.toString()}'));
    }
  }

  /// Refresh authentication token
  Future<Result<Map<String, dynamic>>> refreshToken(String refreshToken) async {
    try {
      final response = await _dioClient.post(
        ApiRoutes.refreshToken,
        data: {'refresh_token': refreshToken},
      );

      final data = response.data as Map<String, dynamic>;
      return Success(data);
    } on ApiException catch (e) {
      return Failure(e);
    } catch (e) {
      return Failure(UnknownException('Token refresh failed: ${e.toString()}'));
    }
  }

  /// Logout user
  Future<Result<void>> logout() async {
    try {
      await _dioClient.post(ApiRoutes.logout);
      return const Success(null);
    } on ApiException catch (e) {
      return Failure(e);
    } catch (e) {
      return Failure(UnknownException('Logout failed: ${e.toString()}'));
    }
  }

  /// Request password reset
  Future<Result<void>> forgotPassword(String email) async {
    try {
      await _dioClient.post(ApiRoutes.forgotPassword, data: {'email': email});
      return const Success(null);
    } on ApiException catch (e) {
      return Failure(e);
    } catch (e) {
      return Failure(
        UnknownException('Password reset request failed: ${e.toString()}'),
      );
    }
  }

  /// Reset password with token
  Future<Result<void>> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    try {
      await _dioClient.post(
        ApiRoutes.resetPassword,
        data: {'token': token, 'password': newPassword},
      );
      return const Success(null);
    } on ApiException catch (e) {
      return Failure(e);
    } catch (e) {
      return Failure(
        UnknownException('Password reset failed: ${e.toString()}'),
      );
    }
  }
}
