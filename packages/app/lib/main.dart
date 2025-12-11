import 'package:core/core.dart';
import 'package:features_auth/features_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'injection_container.dart';
import 'routes/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Setup dependency injection
  await setupDependencyInjection();

  // Initialize network layer
  _initializeNetworkLayer();

  runApp(const MyApp());
}

/// Initialize network layer with token refresh interceptor
void _initializeNetworkLayer() {
  final dioClient = getIt<DioClient>();

  // Configure token refresh interceptor
  dioClient.addRefreshTokenInterceptor(
    onRefresh: (refreshToken) async {
      debugPrint('🔄 Refreshing token...');

      // Get token storage
      final tokenStorage = getIt<TokenStorage>();

      // Create a temporary Dio instance to avoid interceptor recursion
      final refreshDio = DioClient().dio;

      try {
        final response = await refreshDio.post(
          ApiRoutes.refreshToken,
          data: {'refresh_token': refreshToken},
        );

        final newAccessToken = response.data['access_token'] as String;
        final newRefreshToken = response.data['refresh_token'] as String?;

        // Save new tokens
        await tokenStorage.saveAccessToken(newAccessToken);
        if (newRefreshToken != null) {
          await tokenStorage.saveRefreshToken(newRefreshToken);
        }

        debugPrint('✅ Token refreshed successfully');

        return {
          'accessToken': newAccessToken,
          'refreshToken': newRefreshToken ?? refreshToken,
        };
      } catch (e) {
        debugPrint('❌ Token refresh failed: $e');
        rethrow;
      }
    },
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    // Create router once during initialization
    _router = AppRouter.createRouter(authBloc: getIt<AuthBloc>());

    // Check authentication status on app start to restore user session
    // This loads user data if tokens exist in storage
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getIt<AuthBloc>().add(const AuthCheckRequested());
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: getIt<AuthBloc>()),
        BlocProvider.value(value: getIt<ThemeCubit>()),
        BlocProvider.value(
          value: getIt<LocalizationBloc>()..add(const LoadSavedLocaleEvent()),
        ),
      ],
      child: BlocBuilder<LocalizationBloc, LocalizationState>(
        builder: (context, localeState) {
          final locale = localeState is LocalizationLoaded
              ? localeState.locale.toLocale()
              : null;

          return BlocBuilder<ThemeCubit, ThemeMode>(
            builder: (context, themeMode) {
              return MaterialApp.router(
                title: 'Clean Architecture App',
                debugShowCheckedModeBanner: false,
                theme: AppLightTheme.theme,
                darkTheme: AppDarkTheme.theme,
                themeMode: themeMode,
                locale: locale,
                supportedLocales: AppLocale.supportedFlutterLocales,
                localizationsDelegates: AppLocalizations.localizationsDelegates,
                routerConfig: _router,
              );
            },
          );
        },
      ),
    );
  }
}
