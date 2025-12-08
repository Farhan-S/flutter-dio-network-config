import 'package:core/core.dart';
import 'package:features_auth/features_auth.dart';
import 'package:features_home/features_home.dart';
import 'package:features_onboarding/features_onboarding.dart';
import 'package:features_splash/features_splash.dart';
import 'package:features_user/features_user.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

final getIt = GetIt.instance;

/// Setup dependency injection for the entire app
/// Call this once before runApp()
Future<void> setupDependencyInjection() async {
  // ==================== Core Layer ====================

  // SharedPreferences - Singleton
  final sharedPreferences = await SharedPreferences.getInstance();
  getIt.registerLazySingleton<SharedPreferences>(() => sharedPreferences);

  // Token Storage - Singleton
  getIt.registerLazySingleton<TokenStorage>(() => SecureTokenStorage());

  // DioClient - Singleton
  getIt.registerLazySingleton<DioClient>(() => DioClient());

  // ==================== Data Layer ====================

  // Data Sources
  getIt.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSource(getIt<DioClient>()),
  );

  getIt.registerLazySingleton<UserRemoteDataSource>(
    () => UserRemoteDataSource(getIt<DioClient>()),
  );

  // Repositories
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      getIt<AuthRemoteDataSource>(),
      getIt<TokenStorage>(),
    ),
  );

  getIt.registerLazySingleton<UserRepository>(
    () => UserRepositoryImpl(getIt<UserRemoteDataSource>()),
  );

  // ==================== Domain Layer ====================

  // Use Cases
  getIt.registerLazySingleton<LoginUseCase>(
    () => LoginUseCase(getIt<AuthRepository>()),
  );

  getIt.registerLazySingleton<LogoutUseCase>(
    () => LogoutUseCase(getIt<AuthRepository>()),
  );

  getIt.registerLazySingleton<GetCurrentUserUseCase>(
    () => GetCurrentUserUseCase(getIt<AuthRepository>()),
  );

  getIt.registerLazySingleton<GetUserByIdUseCase>(
    () => GetUserByIdUseCase(getIt<UserRepository>()),
  );

  // ==================== Features Home ====================

  // Network Test Data Source
  getIt.registerLazySingleton<NetworkTestDataSource>(
    () => NetworkTestDataSource(getIt<DioClient>()),
  );

  // Network Test Repository
  getIt.registerLazySingleton<NetworkTestRepository>(
    () => NetworkTestRepositoryImpl(getIt<NetworkTestDataSource>()),
  );

  // Network Test Use Case
  getIt.registerLazySingleton<RunNetworkTestsUseCase>(
    () => RunNetworkTestsUseCase(getIt<NetworkTestRepository>()),
  );

  // ==================== Features Splash ====================

  // App Init Data Source
  getIt.registerLazySingleton<AppInitDataSource>(
    () => AppInitDataSource(getIt<TokenStorage>(), getIt<SharedPreferences>()),
  );

  // App Initialization Repository
  getIt.registerLazySingleton<AppInitializationRepository>(
    () => AppInitializationRepositoryImpl(getIt<AppInitDataSource>()),
  );

  // App Initialization Use Cases
  getIt.registerLazySingleton<InitializeAppUseCase>(
    () => InitializeAppUseCase(getIt<AppInitializationRepository>()),
  );

  getIt.registerLazySingleton<CheckAuthStatusUseCase>(
    () => CheckAuthStatusUseCase(getIt<AppInitializationRepository>()),
  );

  // ==================== Features Onboarding ====================

  // Onboarding Local Data Source
  getIt.registerLazySingleton<OnboardingLocalDataSource>(
    () => OnboardingLocalDataSource(getIt<SharedPreferences>()),
  );

  // Onboarding Repository
  getIt.registerLazySingleton<OnboardingRepository>(
    () => OnboardingRepositoryImpl(getIt<OnboardingLocalDataSource>()),
  );

  // Onboarding Use Cases
  getIt.registerLazySingleton<CompleteOnboardingUseCase>(
    () => CompleteOnboardingUseCase(getIt<OnboardingRepository>()),
  );

  getIt.registerLazySingleton<CheckOnboardingStatusUseCase>(
    () => CheckOnboardingStatusUseCase(getIt<OnboardingRepository>()),
  );

  // ==================== Presentation Layer ====================

  // Auth BLoC - Factory (new instance each time)
  getIt.registerFactory<AuthBloc>(
    () => AuthBloc(
      loginUseCase: getIt<LoginUseCase>(),
      logoutUseCase: getIt<LogoutUseCase>(),
      getCurrentUserUseCase: getIt<GetCurrentUserUseCase>(),
    ),
  );

  // Network Test BLoC - Factory
  getIt.registerFactory<NetworkTestBloc>(
    () => NetworkTestBloc(
      runNetworkTestsUseCase: getIt<RunNetworkTestsUseCase>(),
    ),
  );

  // Splash BLoC - Factory
  getIt.registerFactory<SplashBloc>(
    () => SplashBloc(
      initializeAppUseCase: getIt<InitializeAppUseCase>(),
      checkAuthStatusUseCase: getIt<CheckAuthStatusUseCase>(),
    ),
  );

  // Onboarding BLoC - Factory
  getIt.registerFactory<OnboardingBloc>(
    () => OnboardingBloc(
      repository: getIt<OnboardingRepository>(),
      completeOnboardingUseCase: getIt<CompleteOnboardingUseCase>(),
    ),
  );
}
