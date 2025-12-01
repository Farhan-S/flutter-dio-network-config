import 'dart:io';

import '../network/api_exceptions.dart';
import '../network/api_response.dart';
import '../network/api_routes.dart';
import '../network/dio_client.dart';

/// User service for user-related operations
class UserService {
  final DioClient _dioClient;

  UserService({DioClient? dioClient}) : _dioClient = dioClient ?? DioClient();

  /// Get current user profile
  Future<Result<Map<String, dynamic>>> getCurrentUser() async {
    try {
      final response = await _dioClient.get(ApiRoutes.getUser);
      final data = response.data as Map<String, dynamic>;
      return Success(data);
    } on ApiException catch (e) {
      return Failure(e);
    } catch (e) {
      return Failure(UnknownException('Failed to get user: ${e.toString()}'));
    }
  }

  /// Get user by ID
  Future<Result<Map<String, dynamic>>> getUserById(String userId) async {
    try {
      final response = await _dioClient.get(ApiRoutes.userById(userId));
      final data = response.data as Map<String, dynamic>;
      return Success(data);
    } on ApiException catch (e) {
      return Failure(e);
    } catch (e) {
      return Failure(UnknownException('Failed to get user: ${e.toString()}'));
    }
  }

  /// Update user profile
  Future<Result<Map<String, dynamic>>> updateUser(
    Map<String, dynamic> userData,
  ) async {
    try {
      final response = await _dioClient.put(
        ApiRoutes.updateUser,
        data: userData,
      );
      final data = response.data as Map<String, dynamic>;
      return Success(data);
    } on ApiException catch (e) {
      return Failure(e);
    } catch (e) {
      return Failure(
        UnknownException('Failed to update user: ${e.toString()}'),
      );
    }
  }

  /// Delete user account
  Future<Result<void>> deleteUser() async {
    try {
      await _dioClient.delete(ApiRoutes.deleteUser);
      return const Success(null);
    } on ApiException catch (e) {
      return Failure(e);
    } catch (e) {
      return Failure(
        UnknownException('Failed to delete user: ${e.toString()}'),
      );
    }
  }

  /// Upload user avatar
  Future<Result<Map<String, dynamic>>> uploadAvatar(
    File avatarFile, {
    Function(int sent, int total)? onProgress,
  }) async {
    try {
      final response = await _dioClient.uploadFile(
        ApiRoutes.uploadFile,
        file: avatarFile,
        fieldName: 'avatar',
        onSendProgress: onProgress,
      );
      final data = response.data as Map<String, dynamic>;
      return Success(data);
    } on ApiException catch (e) {
      return Failure(e);
    } catch (e) {
      return Failure(
        UnknownException('Failed to upload avatar: ${e.toString()}'),
      );
    }
  }
}
