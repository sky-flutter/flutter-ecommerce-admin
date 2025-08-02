import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/infrastructure/firebase/custom_auth_service.dart';
import '../../../../shared/models/user_model.dart';

final customAuthServiceProvider =
    Provider<CustomAuthService>((ref) => CustomAuthService());

final customAuthStateProvider = StreamProvider<UserModel?>((ref) {
  final authService = ref.watch(customAuthServiceProvider);
  return authService.authStateChanges;
});

final customUserRoleProvider =
    FutureProvider.family<String, String>((ref, uid) async {
  final authService = ref.watch(customAuthServiceProvider);
  return await authService.getUserRole(uid);
});

final customCurrentUserProvider = Provider<UserModel?>((ref) {
  final authService = ref.watch(customAuthServiceProvider);
  return authService.currentUser;
});

final customIsAuthenticatedProvider = Provider<bool>((ref) {
  final authService = ref.watch(customAuthServiceProvider);
  return authService.isAuthenticated;
});

// Provider to manually trigger auth state refresh
final authStateRefreshProvider = Provider<Future<void> Function()>((ref) {
  final authService = ref.read(customAuthServiceProvider);
  return () async {
    await authService.forceRefreshAuthState();
  };
});

// Global logout provider
final globalLogoutProvider = Provider<Future<void> Function()>((ref) {
  final authService = ref.read(customAuthServiceProvider);
  return () async {
    try {
      print('🚪 Global logout initiated...');

      // Force logout
      await authService.forceLogout();

      // Invalidate auth state
      ref.invalidate(customAuthStateProvider);

      print('✅ Global logout completed');
    } catch (e) {
      print('❌ Global logout error: $e');
      rethrow;
    }
  };
});
