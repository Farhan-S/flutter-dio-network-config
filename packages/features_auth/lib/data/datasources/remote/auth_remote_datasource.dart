import 'package:core/core.dart';
import 'package:dio/dio.dart';
import 'package:features_auth/features_auth.dart';
import 'package:features_user/features_user.dart';

/// Remote data source for authentication operations
/// Uses DioClient to make HTTP requests
class AuthRemoteDataSource {
  final DioClient _dioClient;

  AuthRemoteDataSource(this._dioClient);

  /// Login with email and password
  Future<AuthTokenModel> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dioClient.post(
        ApiRoutes.login,
        data: {'email': email, 'password': password},
      );

      return AuthTokenModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      if (e.error is ApiException) {
        throw e.error as ApiException;
      }
      throw UnknownException('Login failed', e, e.stackTrace);
    } catch (e, stackTrace) {
      throw UnknownException('Login failed', e, stackTrace);
    }
  }

  /// Register new user
  Future<AuthTokenModel> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dioClient.post(
        ApiRoutes.register,
        data: {'name': name, 'email': email, 'password': password},
      );

      return AuthTokenModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      if (e.error is ApiException) {
        throw e.error as ApiException;
      }
      throw UnknownException('Registration failed', e, e.stackTrace);
    } catch (e, stackTrace) {
      throw UnknownException('Registration failed', e, stackTrace);
    }
  }

  /// Refresh access token
  Future<AuthTokenModel> refreshToken({required String refreshToken}) async {
    try {
      final response = await _dioClient.post(
        ApiRoutes.refreshToken,
        data: {'refresh_token': refreshToken},
      );

      return AuthTokenModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      if (e.error is ApiException) {
        throw e.error as ApiException;
      }
      throw UnknownException('Token refresh failed', e, e.stackTrace);
    } catch (e, stackTrace) {
      throw UnknownException('Token refresh failed', e, stackTrace);
    }
  }

  /// Get current authenticated user
  Future<UserModel> getCurrentUser() async {
    try {
      final response = await _dioClient.get(ApiRoutes.getUser);

      return UserModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      if (e.error is ApiException) {
        throw e.error as ApiException;
      }
      throw UnknownException('Failed to get user', e, e.stackTrace);
    } catch (e, stackTrace) {
      throw UnknownException('Failed to get user', e, stackTrace);
    }
  }
}
