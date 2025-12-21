import 'dart:ui';

import 'package:core/core.dart';
import 'package:features_auth/features_auth.dart';
import 'package:features_user/features_user.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class GlassNavigationDrawer extends StatelessWidget {
  const GlassNavigationDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        final isAuthenticated = authState is AuthAuthenticated;
        final user = isAuthenticated ? authState.user : null;

        return Drawer(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Container(
            margin: const EdgeInsets.only(right: 20),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface.withValues(alpha: 0.7),
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
              border: Border.all(
                color: theme.colorScheme.outline.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  color: Colors.transparent,
                  child: ListView(
                    padding: const EdgeInsets.only(top: 20),
                    children: [
                      // Drawer Header
                      _buildDrawerHeader(context, isAuthenticated, user),
                      // Menu Items
                      _buildDrawerItem(
                        context,
                        Icons.home_outlined,
                        'Home',
                        () => Navigator.pop(context),
                        isSelected: true,
                      ),
                      if (isAuthenticated)
                        _buildDrawerItem(
                          context,
                          Icons.network_check,
                          'Network Tests',
                          () {
                            Navigator.pop(context);
                            AppRoutes.navigateToNetworkTest(context);
                          },
                        ),
                      _buildDrawerItem(
                        context,
                        Icons.person_outline,
                        'Profile',
                        () {
                          Navigator.pop(context);
                          // Navigate to profile when implemented
                        },
                      ),
                      _buildDrawerItem(
                        context,
                        Icons.settings_outlined,
                        'Settings',
                        () {
                          Navigator.pop(context);
                          AppRoutes.navigateToSettings(context);
                        },
                      ),
                      const Divider(
                        height: 32,
                        thickness: 1,
                        indent: 16,
                        endIndent: 16,
                      ),
                      _buildDrawerItem(
                        context,
                        Icons.info_outline,
                        'About',
                        () {
                          Navigator.pop(context);
                          _showAboutDialog(context);
                        },
                      ),
                      if (isAuthenticated)
                        _buildDrawerItem(context, Icons.logout, 'Logout', () {
                          Navigator.pop(context);
                          context.read<AuthBloc>().add(
                            const AuthLogoutRequested(),
                          );
                        }, isDestructive: true)
                      else
                        _buildDrawerItem(context, Icons.login, 'Login', () {
                          Navigator.pop(context);
                          AppRoutes.navigateToLogin(context);
                        }),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDrawerHeader(
    BuildContext context,
    bool isAuthenticated,
    UserEntity? user,
  ) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: theme.colorScheme.outline.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: theme.colorScheme.outline, width: 2),
              color: theme.colorScheme.surface,
            ),
            child: Center(
              child: isAuthenticated
                  ? Text(
                      user!.name[0].toUpperCase(),
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w300,
                        color: theme.colorScheme.primary,
                      ),
                    )
                  : Icon(
                      Icons.person_outline,
                      size: 30,
                      color: theme.colorScheme.primary,
                    ),
            ),
          ),
          const SizedBox(height: 16),
          if (isAuthenticated) ...[
            Text(
              user!.name,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w400,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              user.email,
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w300,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ] else ...[
            Text(
              'Guest User',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w400,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Login to access all features',
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w300,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDrawerItem(
    BuildContext context,
    IconData icon,
    String title,
    VoidCallback onTap, {
    bool isSelected = false,
    bool isDestructive = false,
  }) {
    final theme = Theme.of(context);
    final color = isDestructive
        ? theme.colorScheme.error
        : isSelected
        ? theme.colorScheme.primary
        : theme.colorScheme.onSurface;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isSelected
                  ? theme.colorScheme.primary.withValues(alpha: 0.1)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
              border: isSelected
                  ? Border.all(
                      color: theme.colorScheme.primary.withValues(alpha: 0.3),
                      width: 1,
                    )
                  : null,
            ),
            child: Row(
              children: [
                Icon(icon, color: color, size: 22),
                const SizedBox(width: 16),
                Text(
                  title,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: color,
                    fontWeight: isSelected ? FontWeight.w500 : FontWeight.w300,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('About'),
        content: const Text(
          'Flutter Clean Architecture Demo\n\n'
          'Version 1.0.0\n\n'
          'Built with Flutter, BLoC, and Melos',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
