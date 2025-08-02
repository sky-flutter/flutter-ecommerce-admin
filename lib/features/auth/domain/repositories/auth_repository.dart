import '../entities/auth_user.dart';

/// Repository interface for authentication operations
abstract class AuthRepository {
  /// Signs in a user with email and password
  Future<AuthUser> signIn(String email, String password);

  /// Signs out the current user
  Future<void> signOut();

  /// Gets the current authenticated user
  Future<AuthUser?> getCurrentUser();

  /// Creates a new user account
  Future<AuthUser> createUser({
    required String email,
    required String password,
    required String displayName,
    String role = 'viewer',
  });

  /// Updates user profile
  Future<void> updateUserProfile(String userId, Map<String, dynamic> updates);

  /// Changes user password
  Future<void> changePassword(
    String userId,
    String currentPassword,
    String newPassword,
  );

  /// Deletes user account
  Future<void> deleteUser(String userId);

  /// Gets user role
  Future<String> getUserRole(String userId);

  /// Checks if session is valid
  Future<bool> isSessionValid();

  /// Stream of authentication state changes
  Stream<AuthUser?> get authStateChanges;

  /// Forces logout by invalidating all sessions
  Future<void> forceLogout();

  /// Refreshes authentication state
  Future<void> refreshAuthState();
}
