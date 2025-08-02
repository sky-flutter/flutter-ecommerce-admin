import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import 'dart:html' as html;
import '../../features/auth/presentation/providers/custom_auth_provider.dart';
import '../../core/constants/app_theme.dart';

class AuthWrapper extends ConsumerWidget {
  final Widget child;

  const AuthWrapper({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(customAuthStateProvider);

    return authState.when(
      data: (user) {
        // User authentication state is determined
        return child;
      },
      loading: () {
        // Show loading screen while checking authentication
        return _buildLoadingScreen(context);
      },
      error: (error, stack) {
        // Show error screen or redirect to login
        print('❌ Authentication error: $error');
        return _buildErrorScreen(context, error.toString());
      },
    );
  }

  Widget _buildLoadingScreen(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.primaryColor.withValues(alpha: 0.1),
              AppTheme.secondaryColor.withValues(alpha: 0.1),
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo
              Icon(
                Icons.admin_panel_settings,
                size: 80,
                color: AppTheme.primaryColor,
              ),
              const SizedBox(height: 24),

              // App title
              Text(
                'Admin Panel',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor,
                ),
              ),
              const SizedBox(height: 8),

              // Subtitle
              Text(
                'Loading...',
                style: TextStyle(
                  fontSize: 16,
                  color: AppTheme.neutral600,
                ),
              ),
              const SizedBox(height: 32),

              // Loading indicator
              SizedBox(
                width: 40,
                height: 40,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AppTheme.primaryColor,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Loading text
              Text(
                'Checking authentication...',
                style: TextStyle(
                  fontSize: 14,
                  color: AppTheme.neutral500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorScreen(BuildContext context, String error) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.primaryColor.withValues(alpha: 0.1),
              AppTheme.secondaryColor.withValues(alpha: 0.1),
            ],
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Error icon
                Icon(
                  Icons.error_outline,
                  size: 80,
                  color: AppTheme.errorColor,
                ),
                const SizedBox(height: 24),

                // Error title
                Text(
                  'Connection Error',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.errorColor,
                  ),
                ),
                const SizedBox(height: 16),

                // Error message
                Text(
                  'Unable to connect to the server. Please check your internet connection and try again.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: AppTheme.neutral600,
                  ),
                ),
                const SizedBox(height: 24),

                // Retry button
                ElevatedButton.icon(
                  onPressed: () {
                    // Refresh the page to retry
                    if (kIsWeb) {
                      html.window.location.reload();
                    }
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Debug info (only in debug mode)
                if (kDebugMode) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.neutral100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Debug Info:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.neutral700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          error,
                          style: TextStyle(
                            fontSize: 12,
                            color: AppTheme.neutral600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
