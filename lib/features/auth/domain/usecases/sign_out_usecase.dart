import '../repositories/auth_repository.dart';

/// Use case for signing out a user
class SignOutUseCase {
  final AuthRepository _repository;

  const SignOutUseCase(this._repository);

  /// Executes the sign out use case
  ///
  /// Signs out the current user and invalidates their session
  /// Throws an exception if sign out fails
  Future<void> execute() async {
    try {
      await _repository.signOut();
    } catch (e) {
      throw _handleSignOutError(e);
    }
  }

  /// Forces logout by invalidating all sessions
  ///
  /// This method is used when normal logout fails or when
  /// we need to ensure all sessions are cleared
  Future<void> forceExecute() async {
    try {
      await _repository.forceLogout();
    } catch (e) {
      throw _handleSignOutError(e);
    }
  }

  /// Handles sign out errors
  Exception _handleSignOutError(dynamic error) {
    if (error is SignOutException) {
      return error;
    }

    return SignOutException('Sign out failed: ${error.toString()}');
  }
}

/// Exception thrown during sign out process
class SignOutException implements Exception {
  final String message;

  const SignOutException(this.message);

  @override
  String toString() => 'SignOutException: $message';
}
