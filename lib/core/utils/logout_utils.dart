import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'dart:html' as html;
import 'package:go_router/go_router.dart';

/// Utility class for handling logout navigation
class LogoutUtils {
  const LogoutUtils._();

  /// Navigates to the login page with proper error handling
  ///
  /// This method handles navigation to the login page with fallback
  /// mechanisms for different platforms and error scenarios.
  static Future<void> navigateToLogin(BuildContext context) async {
    try {
      print('🔄 Navigating to login page...');

      // Wait a moment to ensure any pending operations complete
      await Future.delayed(const Duration(milliseconds: 300));

      if (kIsWeb) {
        _navigateToLoginWeb();
      } else {
        _navigateToLoginMobile(context);
      }
    } catch (e) {
      print('❌ Navigation error: $e');
      _handleNavigationError();
    }
  }

  /// Navigates to login page on web platform
  static void _navigateToLoginWeb() {
    print('🌐 Using window.location for web navigation');
    html.window.location.href = '/login';
  }

  /// Navigates to login page on mobile platform
  static void _navigateToLoginMobile(BuildContext context) {
    print('📱 Using GoRouter for navigation');
    if (context.mounted) {
      context.go('/login');
    }
  }

  /// Handles navigation errors with fallback mechanisms
  static void _handleNavigationError() {
    // Final fallback for web
    if (kIsWeb) {
      try {
        print('🔄 Attempting page reload as fallback...');
        html.window.location.reload();
      } catch (reloadError) {
        print('❌ Reload error: $reloadError');
      }
    }
  }
}
