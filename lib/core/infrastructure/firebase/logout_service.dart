import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import 'dart:html' as html;
import 'package:go_router/go_router.dart';

import '../../../features/auth/presentation/providers/custom_auth_provider.dart';
import '../../../core/utils/logout_utils.dart';
import '../../../core/utils/logout_test.dart';

/// Service responsible for handling logout operations
class LogoutService {
  const LogoutService._();

  /// Performs logout without any UI interactions
  ///
  /// This method only handles the logout process without navigation.
  /// The caller is responsible for handling navigation.
  static Future<void> performLogout(
    BuildContext context,
    WidgetRef ref,
  ) async {
    try {
      print('🚪 LogoutService: Starting logout process...');

      final globalLogout = ref.read(globalLogoutProvider);
      await globalLogout();

      print('✅ LogoutService: User signed out successfully');
    } catch (e) {
      print('❌ LogoutService: Logout error: $e');
      rethrow;
    }
  }

  /// Performs logout and handles navigation to login page
  static Future<void> performLogoutAndNavigate(
    BuildContext context,
    WidgetRef ref,
  ) async {
    try {
      print('🚪 LogoutService: Starting logout and navigation process...');

      // Perform the actual logout
      final globalLogout = ref.read(globalLogoutProvider);
      await globalLogout();

      print('✅ Logout completed, navigating to login...');

      // Navigate to login page
      await LogoutUtils.navigateToLogin(context);

      print('✅ LogoutService: Logout and navigation completed');
    } catch (e) {
      print('❌ LogoutService: Logout and navigation error: $e');

      _handleLogoutError(context, e);
    }
  }

  /// Shows confirmation dialog and performs logout with loading indicator
  static Future<void> performLogoutWithConfirmation(
    BuildContext context,
    WidgetRef ref,
  ) async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => _buildConfirmationDialog(context, ref),
    );
  }

  /// Simple logout method for testing purposes
  static Future<void> performSimpleLogout(
    BuildContext context,
    WidgetRef ref,
  ) async {
    try {
      print('🚪 Simple logout test...');

      final globalLogout = ref.read(globalLogoutProvider);
      await globalLogout();

      print('✅ Simple logout completed');

      _navigateToLogin(context);
    } catch (e) {
      print('❌ Simple logout error: $e');
      rethrow;
    }
  }

  /// Builds the confirmation dialog
  static Widget _buildConfirmationDialog(
    BuildContext context,
    WidgetRef ref,
  ) {
    return AlertDialog(
      title: _buildDialogTitle(),
      content: _buildDialogContent(),
      actions: _buildDialogActions(context, ref),
    );
  }

  /// Builds the dialog title with logout icon
  static Widget _buildDialogTitle() {
    return Row(
      children: [
        Icon(
          Icons.logout,
          color: Colors.red,
          size: 24,
        ),
        const SizedBox(width: 8),
        const Text('Confirm Logout'),
      ],
    );
  }

  /// Builds the dialog content with information
  static Widget _buildDialogContent() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Are you sure you want to logout?',
          style: TextStyle(fontSize: 16),
        ),
        const SizedBox(height: 8),
        Text(
          'You will be redirected to the login page.',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 8),
        _buildInfoBox(),
      ],
    );
  }

  /// Builds the information box
  static Widget _buildInfoBox() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.blue.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            size: 14,
            color: Colors.blue,
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              'This will end your current session and redirect you to the login page.',
              style: TextStyle(
                fontSize: 11,
                color: Colors.blue[700],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the dialog actions
  static List<Widget> _buildDialogActions(
    BuildContext context,
    WidgetRef ref,
  ) {
    return [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Cancel'),
      ),
      ElevatedButton(
        onPressed: () => _handleLogoutConfirmation(context, ref),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
        ),
        child: const Text('Logout'),
      ),
    ];
  }

  /// Handles the logout confirmation button press
  static Future<void> _handleLogoutConfirmation(
    BuildContext context,
    WidgetRef ref,
  ) async {
    // Close confirmation dialog
    Navigator.pop(context);

    // Show loading indicator
    _showLoadingDialog(context);

    try {
      // Perform logout and navigation
      await performLogoutAndNavigate(context, ref);

      // Close loading dialog after successful logout
      if (context.mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      print('❌ Logout error in confirmation: $e');

      _handleLogoutError(context, e);
    }
  }

  /// Shows the loading dialog
  static void _showLoadingDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const CircularProgressIndicator(),
            const SizedBox(width: 12),
            const Text('Logging Out'),
          ],
        ),
        content: const Text(
          'Please wait while we log you out...',
          style: TextStyle(fontSize: 14),
        ),
      ),
    );
  }

  /// Handles logout errors
  static Future<void> _handleLogoutError(
    BuildContext context,
    Object error,
  ) async {
    // Close loading dialog
    if (context.mounted) {
      Navigator.pop(context);
    }

    // Show error and try navigation
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Logout failed: $error'),
          backgroundColor: Colors.red,
        ),
      );

      // Try navigation anyway
      await LogoutUtils.navigateToLogin(context);
    } else {
      // If context is not mounted, try direct navigation
      print('🔄 Context not mounted after error, using direct navigation...');
      _navigateToLoginDirectly();
    }
  }

  /// Navigates to login page using GoRouter
  static void _navigateToLogin(BuildContext context) {
    if (context.mounted) {
      context.go('/login');
    } else {
      _navigateToLoginDirectly();
    }
  }

  /// Navigates to login page directly (fallback)
  static void _navigateToLoginDirectly() {
    if (kIsWeb) {
      html.window.location.href = '/login';
    }
  }
}
