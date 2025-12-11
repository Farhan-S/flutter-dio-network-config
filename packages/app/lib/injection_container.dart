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

  // Locale Storage - Singleton
  getIt.registerLazySingleton<LocaleStorage>(
    () => LocaleStorage(getIt<SharedPreferences>()),
  );

  // Theme Storage - Singleton
  getIt.registerLazySingleton<ThemeStorage>(
    () => ThemeStorage(getIt<SharedPreferences>()),
  );

  // DioClient - Singleton
  getIt.registerLazySingleton<DioClient>(() => DioClient());

  // ==================== Data Layer ====================

  // Data Sources
  getIt.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSource(getIt<DioClient>()),
  );

  // Mock Auth Data Source (for development/testing)
  getIt.registerLazySingleton<AuthMockDataSource>(
    () => AuthMockDataSource(tokenStorage: getIt<TokenStorage>()),
  );

  getIt.registerLazySingleton<UserRemoteDataSource>(
    () => UserRemoteDataSource(getIt<DioClient>()),
  );

  // Repositories
  // Using mock auth in development - switch to remote when you have real API
  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      // remoteDataSource: getIt<AuthRemoteDataSource>(), // Uncomment when using real API
      mockDataSource:
          getIt<AuthMockDataSource>(), // Comment out when using real API
      tokenStorage: getIt<TokenStorage>(),
    ),
  );

  getIt.registerLazySingleton<UserRepository>(
    () => UserRepositoryImpl(getIt<UserRemoteDataSource>()),
  );

  // Locale Repository
  getIt.registerLazySingleton<LocaleRepository>(
    () => LocaleRepositoryImpl(getIt<LocaleStorage>()),
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

  // Localization Use Cases
  getIt.registerLazySingleton<GetSavedLocaleUseCase>(
    () => GetSavedLocaleUseCase(getIt<LocaleRepository>()),
  );

  getIt.registerLazySingleton<SaveLocaleUseCase>(
    () => SaveLocaleUseCase(getIt<LocaleRepository>()),
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

  // Auth BLoC - Singleton (same instance throughout app lifecycle)
  // This is critical for maintaining authentication state across the app
  getIt.registerLazySingleton<AuthBloc>(
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

  // Localization BLoC - Singleton (persists language selection)
  getIt.registerLazySingleton<LocalizationBloc>(
    () => LocalizationBloc(
      getSavedLocaleUseCase: getIt<GetSavedLocaleUseCase>(),
      saveLocaleUseCase: getIt<SaveLocaleUseCase>(),
    ),
  );

  // Theme Cubit - Singleton (persists theme selection)
  getIt.registerLazySingleton<ThemeCubit>(
    () => ThemeCubit(getIt<ThemeStorage>()),
  );
}
