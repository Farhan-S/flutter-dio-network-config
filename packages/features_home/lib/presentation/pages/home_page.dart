import 'package:core/core.dart';
import 'package:features_auth/features_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/home_bloc.dart';
import '../bloc/home_event.dart';
import '../bloc/home_state.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => HomeBloc()..add(const LoadHomeDataEvent()),
      child: const _HomePageContent(),
    );
  }
}

class _HomePageContent extends StatelessWidget {
  const _HomePageContent();

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listenWhen: (previous, current) {
        debugPrint(
          '🏠 HomePage - Auth state changed: ${previous.runtimeType} -> ${current.runtimeType}',
        );
        return true;
      },
      listener: (context, state) {
        debugPrint('🏠 HomePage - Auth listener: ${state.runtimeType}');

        // Handle logout success
        if (state is AuthUnauthenticated) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(AppLocalizations.of(context).logout),
              backgroundColor: Colors.orange,
              behavior: SnackBarBehavior.floating,
            ),
          );
          // Navigate to login page
          AppRoutes.navigateToLogin(context);
        }
        // Handle auth errors
        else if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      child: const _HomePageView(),
    );
  }
}

class _HomePageView extends StatelessWidget {
  const _HomePageView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<HomeBloc, HomeState>(
        builder: (context, homeState) {
          // Handle HomeBloc loading state
          if (homeState is HomeLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          // Handle HomeBloc error state
          if (homeState is HomeError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    homeState.message,
                    style: const TextStyle(color: Colors.red),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () =>
                        context.read<HomeBloc>().add(const LoadHomeDataEvent()),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          // Home data is loaded, show content with auth state
          return BlocConsumer<AuthBloc, AuthState>(
            listenWhen: (previous, current) {
              // Listen to all state changes
              debugPrint(
                '🏠 HomePage - State changed: ${previous.runtimeType} -> ${current.runtimeType}',
              );
              return true;
            },
            buildWhen: (previous, current) {
              // Rebuild on all state changes
              debugPrint('🏠 HomePage - Rebuilding: ${current.runtimeType}');
              return true;
            },
            listener: (context, state) {
              debugPrint(
                '🏠 HomePage - Listener triggered: ${state.runtimeType}',
              );

              // Handle logout success
              if (state is AuthUnauthenticated) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(AppLocalizations.of(context).logout),
                    backgroundColor: Colors.orange,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
                // Navigate to login page
                AppRoutes.navigateToLogin(context);
              }
              // Handle auth errors
              else if (state is AuthError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: Colors.red,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            builder: (context, state) {
              debugPrint(
                '🏠 HomePage - Building with state: ${state.runtimeType}',
              );

              final isAuthenticated = state is AuthAuthenticated;
              final isLoading = state is AuthLoading;

              debugPrint(
                '🏠 HomePage - isAuthenticated: $isAuthenticated, isLoading: $isLoading',
              );

              return RefreshIndicator(
                onRefresh: () async {
                  context.read<HomeBloc>().add(const RefreshHomeDataEvent());
                  await Future.delayed(const Duration(milliseconds: 600));
                },
                child: CustomScrollView(
                  slivers: [
                    // App Bar
                    SliverAppBar(
                      expandedHeight: 200,
                      pinned: true,
                      actions: [
                        // Theme toggle button
                        BlocBuilder<ThemeCubit, ThemeMode>(
                          builder: (context, themeMode) {
                            return IconButton(
                              icon: Icon(
                                themeMode == ThemeMode.dark
                                    ? Icons.light_mode
                                    : Icons.dark_mode,
                              ),
                              onPressed: () {
                                context.read<ThemeCubit>().toggleTheme();
                              },
                              tooltip: 'Toggle theme',
                            );
                          },
                        ),
                      ],
                      flexibleSpace: FlexibleSpaceBar(
                        title: Text(
                          AppLocalizations.of(context).appTitle,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            shadows: [
                              Shadow(blurRadius: 10, color: Colors.black26),
                            ],
                          ),
                        ),
                        background: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Theme.of(context).colorScheme.primary,
                                Theme.of(context).colorScheme.secondary,
                              ],
                            ),
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.architecture,
                              size: 80,
                              color: Colors.white70,
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Content
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const SizedBox(height: 16),

                            // User Profile Card (if authenticated)
                            if (state is AuthAuthenticated)
                              _buildUserProfileCard(context, state),

                            // Authentication Status Card
                            _buildAuthStatusCard(
                              context,
                              state,
                              isAuthenticated,
                              isLoading,
                            ),

                            const SizedBox(height: 16),

                            // Quick Actions
                            _buildQuickActions(context, isAuthenticated, state),

                            const SizedBox(height: 24),

                            // Theme Demo Section
                            _buildThemeDemoSection(context),

                            const SizedBox(height: 24),

                            // Language Selector Section
                            _buildLanguageSection(context),

                            const SizedBox(height: 24),

                            // Features Section
                            _buildFeaturesSection(context),

                            const SizedBox(height: 24),

                            // Architecture Info
                            _buildArchitectureInfo(context),

                            const SizedBox(height: 32),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildUserProfileCard(BuildContext context, AuthAuthenticated state) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Theme.of(context).colorScheme.primaryContainer,
              Theme.of(context).colorScheme.secondaryContainer,
            ],
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            CircleAvatar(
              radius: 40,
              backgroundColor: Theme.of(context).colorScheme.primary,
              backgroundImage: state.user.avatar != null
                  ? NetworkImage(state.user.avatar!)
                  : null,
              child: state.user.avatar == null
                  ? Text(
                      state.user.name[0].toUpperCase(),
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    state.user.name,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    state.user.email,
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: Colors.grey[700]),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.check_circle,
                          size: 16,
                          color: Colors.green[700],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Authenticated',
                          style: TextStyle(
                            color: Colors.green[700],
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAuthStatusCard(
    BuildContext context,
    AuthState state,
    bool isAuthenticated,
    bool isLoading,
  ) {
    Color statusColor;
    IconData statusIcon;
    String statusText;
    String statusSubtext;

    if (isLoading) {
      statusColor = Colors.orange;
      statusIcon = Icons.hourglass_empty;
      statusText = 'Loading...';
      statusSubtext = 'Checking authentication status';
    } else if (isAuthenticated) {
      statusColor = Colors.green;
      statusIcon = Icons.verified_user;
      statusText = 'Secure Session';
      statusSubtext = 'Your session is active and secure';
    } else if (state is AuthError) {
      statusColor = Colors.red;
      statusIcon = Icons.error_outline;
      statusText = 'Authentication Error';
      statusSubtext = state.message;
    } else {
      statusColor = Colors.grey;
      statusIcon = Icons.lock_open;
      statusText = 'Not Authenticated';
      statusSubtext = 'Login to access all features';
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(statusIcon, color: statusColor, size: 32),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    statusText,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: statusColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    statusSubtext,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions(
    BuildContext context,
    bool isAuthenticated,
    AuthState state,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Quick Actions',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        if (!isAuthenticated)
          ElevatedButton.icon(
            onPressed: () => AppRoutes.navigateToLogin(context),
            icon: const Icon(Icons.login),
            label: Text(AppLocalizations.of(context).login),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.all(16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          )
        else ...[
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => AppRoutes.navigateToNetworkTest(context),
                  icon: const Icon(Icons.network_check),
                  label: const Text('Network Tests'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.all(16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    context.read<AuthBloc>().add(const AuthLogoutRequested());
                  },
                  icon: const Icon(Icons.logout),
                  label: Text(AppLocalizations.of(context).logout),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.all(16),
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildFeaturesSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Features',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        _buildFeatureCard(
          context,
          Icons.security,
          'Mock Authentication',
          'Test with 3 demo users without backend',
          Colors.blue,
        ),
        const SizedBox(height: 8),
        _buildFeatureCard(
          context,
          Icons.architecture,
          'Clean Architecture',
          'Domain, Data, and Presentation layers',
          Colors.purple,
        ),
        const SizedBox(height: 8),
        _buildFeatureCard(
          context,
          Icons.view_module,
          'BLoC State Management',
          'Reactive UI with flutter_bloc',
          Colors.orange,
        ),
        const SizedBox(height: 8),
        _buildFeatureCard(
          context,
          Icons.storage,
          'Secure Token Storage',
          'Encrypted storage with auto-refresh',
          Colors.green,
        ),
      ],
    );
  }

  Widget _buildFeatureCard(
    BuildContext context,
    IconData icon,
    String title,
    String description,
    Color color,
  ) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(description),
      ),
    );
  }

  Widget _buildArchitectureInfo(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'About This App',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'This is a production-ready Flutter app demonstrating Clean Architecture with feature-based packages using Melos for monorepo management.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildTechChip('Flutter', Colors.blue),
                _buildTechChip('Clean Architecture', Colors.green),
                _buildTechChip('BLoC', Colors.purple),
                _buildTechChip('Melos', Colors.orange),
                _buildTechChip('Dio', Colors.red),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTechChip(String label, Color color) {
    return Chip(
      label: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
      backgroundColor: color.withOpacity(0.1),
      side: BorderSide(color: color.withOpacity(0.3)),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    );
  }

  Widget _buildThemeDemoSection(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeMode>(
      builder: (context, themeMode) {
        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.palette,
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Theme Management',
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'BLoC-based theme switching with Material 3',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Text(
                  'Current Theme Mode',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                // Theme mode selector
                SegmentedButton<ThemeMode>(
                  segments: [
                    ButtonSegment(
                      value: ThemeMode.light,
                      icon: const Icon(Icons.light_mode),
                      label: Text(AppLocalizations.of(context).lightMode),
                    ),
                    ButtonSegment(
                      value: ThemeMode.dark,
                      icon: const Icon(Icons.dark_mode),
                      label: Text(AppLocalizations.of(context).darkMode),
                    ),
                    ButtonSegment(
                      value: ThemeMode.system,
                      icon: const Icon(Icons.settings_brightness),
                      label: Text(AppLocalizations.of(context).systemDefault),
                    ),
                  ],
                  selected: {themeMode},
                  onSelectionChanged: (Set<ThemeMode> newSelection) {
                    context.read<ThemeCubit>().setThemeMode(newSelection.first);
                  },
                ),
                const SizedBox(height: 20),
                // Theme info
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceVariant,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            size: 20,
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Theme Features',
                            style: Theme.of(context).textTheme.titleSmall
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _buildThemeFeatureItem(
                        context,
                        '✓',
                        'Material 3 Design System',
                      ),
                      _buildThemeFeatureItem(
                        context,
                        '✓',
                        'ThemeCubit for state management',
                      ),
                      _buildThemeFeatureItem(
                        context,
                        '✓',
                        'Custom theme extensions',
                      ),
                      _buildThemeFeatureItem(
                        context,
                        '✓',
                        'Design tokens (colors, spacing, typography)',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Color palette preview
                Text(
                  'Color Palette Preview',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    _buildColorSwatch(
                      context,
                      'Primary',
                      Theme.of(context).colorScheme.primary,
                    ),
                    _buildColorSwatch(
                      context,
                      'Secondary',
                      Theme.of(context).colorScheme.secondary,
                    ),
                    _buildColorSwatch(
                      context,
                      'Tertiary',
                      Theme.of(context).colorScheme.tertiary,
                    ),
                    _buildColorSwatch(
                      context,
                      'Error',
                      Theme.of(context).colorScheme.error,
                    ),
                    _buildColorSwatch(
                      context,
                      'Success',
                      Theme.of(
                            context,
                          ).extension<AppColorsExtension>()?.success ??
                          Colors.green,
                    ),
                    _buildColorSwatch(
                      context,
                      'Warning',
                      Theme.of(
                            context,
                          ).extension<AppColorsExtension>()?.warning ??
                          Colors.orange,
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildThemeFeatureItem(
    BuildContext context,
    String bullet,
    String text,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            bullet,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text, style: Theme.of(context).textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }

  Widget _buildColorSwatch(BuildContext context, String label, Color color) {
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Theme.of(context).colorScheme.outline,
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  Widget _buildLanguageSection(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return BlocBuilder<LocalizationBloc, LocalizationState>(
      builder: (context, localeState) {
        final currentLocale = localeState is LocalizationLoaded
            ? localeState.locale
            : AppLocale.english;

        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.secondaryContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.language,
                        color: Theme.of(
                          context,
                        ).colorScheme.onSecondaryContainer,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.language,
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Select your preferred language',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Text(
                  'Current Language',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                // Language selector buttons
                ...AppLocale.supportedLocales.map((locale) {
                  final isSelected =
                      currentLocale.languageCode == locale.languageCode;

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: InkWell(
                      onTap: () {
                        context.read<LocalizationBloc>().add(
                          ChangeLocaleEvent(locale),
                        );
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Theme.of(context).colorScheme.primaryContainer
                              : Theme.of(context).colorScheme.surfaceVariant,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected
                                ? Theme.of(context).colorScheme.primary
                                : Colors.transparent,
                            width: 2,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              isSelected
                                  ? Icons.radio_button_checked
                                  : Icons.radio_button_unchecked,
                              color: isSelected
                                  ? Theme.of(context).colorScheme.primary
                                  : Theme.of(
                                      context,
                                    ).colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    locale.displayName,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(
                                          fontWeight: isSelected
                                              ? FontWeight.bold
                                              : FontWeight.normal,
                                          color: isSelected
                                              ? Theme.of(
                                                  context,
                                                ).colorScheme.onPrimaryContainer
                                              : null,
                                        ),
                                  ),
                                  Text(
                                    '${locale.languageCode}${locale.countryCode != null ? '_${locale.countryCode}' : ''}',
                                    style: Theme.of(context).textTheme.bodySmall
                                        ?.copyWith(
                                          color: isSelected
                                              ? Theme.of(
                                                  context,
                                                ).colorScheme.onPrimaryContainer
                                              : Theme.of(
                                                  context,
                                                ).colorScheme.onSurfaceVariant,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                            if (isSelected)
                              Icon(
                                Icons.check_circle,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
                const SizedBox(height: 16),
                // Info container
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceVariant,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 20,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Language preference is saved locally and will persist across app restarts.',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
