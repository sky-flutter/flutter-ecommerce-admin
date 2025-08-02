import '../../../../shared/models/user_model.dart';

/// Domain entity representing an authenticated user
class AuthUser {
  /// The user model
  final UserModel user;

  /// Whether the user is currently authenticated
  final bool isAuthenticated;

  /// When the user was authenticated
  final DateTime? authenticatedAt;

  /// Session token
  final String? sessionToken;

  /// Session expiration time
  final DateTime? sessionExpiresAt;

  const AuthUser({
    required this.user,
    required this.isAuthenticated,
    this.authenticatedAt,
    this.sessionToken,
    this.sessionExpiresAt,
  });

  /// Creates an AuthUser from a UserModel
  factory AuthUser.fromUser(UserModel user) {
    return AuthUser(
      user: user,
      isAuthenticated: true,
      authenticatedAt: DateTime.now(),
    );
  }

  /// Creates an unauthenticated user
  factory AuthUser.unauthenticated() {
    return AuthUser(
      user: UserModel(
        id: '',
        displayName: '',
        email: '',
        role: '',
        createdAt: DateTime.now(),
      ),
      isAuthenticated: false,
    );
  }

  /// Checks if the session is still valid
  bool get isSessionValid {
    if (!isAuthenticated || sessionExpiresAt == null) return false;
    return DateTime.now().isBefore(sessionExpiresAt!);
  }

  /// Gets the user's role
  String get role => user.role;

  /// Checks if user has admin privileges
  bool get isAdmin => user.role == 'admin';

  /// Checks if user has editor privileges
  bool get isEditor => user.role == 'editor';

  /// Checks if user has viewer privileges
  bool get isViewer => user.role == 'viewer';

  /// Gets the user's display name
  String get displayName => user.displayName;

  /// Gets the user's email
  String get email => user.email;

  /// Gets the user's ID
  String get id => user.id;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AuthUser && other.user.id == user.id;
  }

  @override
  int get hashCode => user.id.hashCode;

  @override
  String toString() {
    return 'AuthUser(user: $user, isAuthenticated: $isAuthenticated)';
  }
}
