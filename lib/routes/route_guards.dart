import 'package:go_router/go_router.dart';
import '../features/auth/presentation/providers/custom_auth_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RouteGuards {
  static Future<String?> authGuard(GoRouterState state, ProviderRef ref) async {
    // Skip auth check for login page to avoid redirect loops
    if (state.matchedLocation == '/login') {
      print('🔓 Auth guard: Login page - allowing access');
      return null;
    }

    final authState = ref.read(customAuthStateProvider);

    return authState.when(
      data: (user) {
        if (user == null) {
          print('🔒 Auth guard: No user found, redirecting to login');
          return '/login';
        }
        print('✅ Auth guard: User authenticated: ${user.displayName}');
        return null;
      },
      loading: () {
        print('⏳ Auth guard: Loading auth state...');
        // Don't redirect while loading, let the AuthWrapper handle the loading screen
        return null;
      },
      error: (error, stack) {
        print('❌ Auth guard: Error: $error');
        return '/login';
      },
    );
  }

  static Future<String?> roleGuard(GoRouterState state, ProviderRef ref) async {
    final authState = ref.read(customAuthStateProvider);

    return authState.when(
      data: (user) {
        if (user == null) return '/login';

        // Check user role for specific routes
        final userRoleAsync = ref.read(customUserRoleProvider(user.id));

        return userRoleAsync.when(
          data: (role) {
            // Admin-only routes
            if (_isAdminOnlyRoute(state.matchedLocation) && role != 'admin') {
              return '/access-denied';
            }

            // Admin and Editor routes
            if (_isAdminEditorRoute(state.matchedLocation) &&
                role != 'admin' &&
                role != 'editor') {
              return '/access-denied';
            }

            // Admin, Editor, and Viewer routes (all authenticated users)
            if (_isAuthenticatedRoute(state.matchedLocation)) {
              return null; // All authenticated users can access
            }

            return null;
          },
          loading: () => null,
          error: (_, __) => '/access-denied',
        );
      },
      loading: () => null,
      error: (_, __) => '/login',
    );
  }

  // Admin-only routes
  static bool _isAdminOnlyRoute(String route) {
    final adminRoutes = [
      '/users',
      '/reports',
      '/system-settings',
    ];
    return adminRoutes.any((adminRoute) => route.startsWith(adminRoute));
  }

  // Admin and Editor routes
  static bool _isAdminEditorRoute(String route) {
    final adminEditorRoutes = [
      '/products',
      '/inventory',
      '/analytics',
    ];
    return adminEditorRoutes
        .any((adminEditorRoute) => route.startsWith(adminEditorRoute));
  }

  // All authenticated user routes
  static bool _isAuthenticatedRoute(String route) {
    final authenticatedRoutes = [
      '/',
      '/orders',
      '/settings',
    ];
    return authenticatedRoutes.any((authRoute) => route.startsWith(authRoute));
  }
}
