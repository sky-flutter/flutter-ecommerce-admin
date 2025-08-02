import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import 'dart:html' as html;
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/providers/custom_auth_provider.dart';

/// Utility class for testing logout functionality
class LogoutTest {
  const LogoutTest._();

  /// Performs a comprehensive logout test with detailed logging
  ///
  /// This method tests each step of the logout process and provides
  /// detailed debugging information.
  static Future<void> testLogout(
    BuildContext context,
    WidgetRef ref,
  ) async {
    try {
      print('🧪 Starting logout test...');

      await _testAuthStateBeforeLogout(ref);
      await _testLogoutProcess(ref);
      await _testAuthStateAfterLogout(ref);
      await _testNavigation(context);

      print('✅ Logout test completed successfully');
    } catch (e) {
      print('❌ Logout test failed: $e');
      rethrow;
    }
  }

  /// Tests the auth state before logout
  static Future<void> _testAuthStateBeforeLogout(WidgetRef ref) async {
    print('📊 Testing auth state before logout...');

    final authState = ref.read(customAuthStateProvider);
    print('📊 Current auth state: $authState');
  }

  /// Tests the logout process
  static Future<void> _testLogoutProcess(WidgetRef ref) async {
    print('🚪 Testing logout process...');

    final authService = ref.read(customAuthServiceProvider);
    await authService.forceLogout();

    print('✅ Force logout completed');
  }

  /// Tests the auth state after logout
  static Future<void> _testAuthStateAfterLogout(WidgetRef ref) async {
    print('📊 Testing auth state after logout...');

    // Wait for auth state to update
    await Future.delayed(const Duration(milliseconds: 500));

    final newAuthState = ref.read(customAuthStateProvider);
    print('📊 Auth state after logout: $newAuthState');
  }

  /// Tests navigation to login page
  static Future<void> _testNavigation(BuildContext context) async {
    print('🔄 Testing navigation...');

    if (context.mounted) {
      context.go('/login');
      print('✅ Navigation via GoRouter completed');
    } else {
      print('❌ Context not mounted, trying direct navigation');
      _testDirectNavigation();
    }
  }

  /// Tests direct navigation (fallback)
  static void _testDirectNavigation() {
    if (kIsWeb) {
      html.window.location.href = '/login';
      print('✅ Direct navigation completed');
    } else {
      print('❌ Direct navigation not available on this platform');
    }
  }
}
