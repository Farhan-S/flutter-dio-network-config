import 'package:core/core.dart';
import 'package:dartz/dartz.dart';
import 'package:features_auth/features_auth.dart';
import 'package:features_user/features_user.dart';

/// Implementation of AuthRepository
/// Connects domain layer with data sources
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource? _remoteDataSource;
  final AuthMockDataSource? _mockDataSource;
  final TokenStorage _tokenStorage;

  AuthRepositoryImpl({
    AuthRemoteDataSource? remoteDataSource,
    AuthMockDataSource? mockDataSource,
    required TokenStorage tokenStorage,
  }) : _remoteDataSource = remoteDataSource,
       _mockDataSource = mockDataSource,
       _tokenStorage = tokenStorage {
    // Ensure at least one data source is provided
    assert(
      remoteDataSource != null || mockDataSource != null,
      'Either remoteDataSource or mockDataSource must be provided',
    );
  }

  /// Get the active data source (mock takes priority for testing)
  bool get _useMock => _mockDataSource != null;

  @override
  Future<Either<ApiException, AuthTokenEntity>> login({
    required String email,
    required String password,
  }) async {
    try {
      final tokenModel = _useMock
          ? await _mockDataSource!.login(email: email, password: password)
          : await _remoteDataSource!.login(email: email, password: password);

      // Save tokens to storage
      await _tokenStorage.saveAccessToken(tokenModel.accessToken);
      await _tokenStorage.saveRefreshToken(tokenModel.refreshToken);

      return Right(tokenModel.toEntity());
    } on ApiException catch (e) {
      return Left(e);
    } catch (e, stackTrace) {
      return Left(UnknownException('Login failed', e, stackTrace));
    }
  }

  @override
  Future<Either<ApiException, AuthTokenEntity>> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final tokenModel = _useMock
          ? await _mockDataSource!.register(
              name: name,
              email: email,
              password: password,
            )
          : await _remoteDataSource!.register(
              name: name,
              email: email,
              password: password,
            );

      // Save tokens to storage
      await _tokenStorage.saveAccessToken(tokenModel.accessToken);
      await _tokenStorage.saveRefreshToken(tokenModel.refreshToken);

      return Right(tokenModel.toEntity());
    } on ApiException catch (e) {
      return Left(e);
    } catch (e, stackTrace) {
      return Left(UnknownException('Registration failed', e, stackTrace));
    }
  }

  @override
  Future<Either<ApiException, AuthTokenEntity>> refreshToken({
    required String refreshToken,
  }) async {
    try {
      final tokenModel = _useMock
          ? await _mockDataSource!.refreshToken(refreshToken: refreshToken)
          : await _remoteDataSource!.refreshToken(refreshToken: refreshToken);

      // Save new tokens
      await _tokenStorage.saveAccessToken(tokenModel.accessToken);
      await _tokenStorage.saveRefreshToken(tokenModel.refreshToken);

      return Right(tokenModel.toEntity());
    } on ApiException catch (e) {
      return Left(e);
    } catch (e, stackTrace) {
      return Left(UnknownException('Token refresh failed', e, stackTrace));
    }
  }

  @override
  Future<Either<ApiException, void>> logout() async {
    try {
      // Clear tokens from storage
      await _tokenStorage.clearTokens();

      return const Right(null);
    } catch (e, stackTrace) {
      return Left(UnknownException('Logout failed', e, stackTrace));
    }
  }

  @override
  Future<Either<ApiException, UserEntity>> getCurrentUser() async {
    try {
      final userModel = _useMock
          ? await _mockDataSource!.getCurrentUser()
          : await _remoteDataSource!.getCurrentUser();

      return Right(userModel.toEntity());
    } on ApiException catch (e) {
      return Left(e);
    } catch (e, stackTrace) {
      return Left(
        UnknownException('Failed to get current user', e, stackTrace),
      );
    }
  }

  @override
  Future<bool> isAuthenticated() async {
    try {
      return await _tokenStorage.isAuthenticated();
    } catch (_) {
      return false;
    }
  }
}
