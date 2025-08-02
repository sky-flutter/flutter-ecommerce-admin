import '../entities/auth_user.dart';
import '../repositories/auth_repository.dart';

/// Use case for signing in a user
class SignInUseCase {
  final AuthRepository _repository;

  const SignInUseCase(this._repository);

  /// Executes the sign in use case
  ///
  /// [email] - User's email address
  /// [password] - User's password
  ///
  /// Returns an [AuthUser] if successful
  /// Throws an exception if sign in fails
  Future<AuthUser> execute(String email, String password) async {
    // Validate input
    _validateInput(email, password);

    // Attempt to sign in
    try {
      final authUser = await _repository.signIn(email, password);

      // Validate the authenticated user
      _validateAuthenticatedUser(authUser);

      return authUser;
    } catch (e) {
      throw _handleSignInError(e);
    }
  }

  /// Validates the input parameters
  void _validateInput(String email, String password) {
    if (email.isEmpty) {
      throw const SignInException('Email cannot be empty');
    }

    if (password.isEmpty) {
      throw const SignInException('Password cannot be empty');
    }

    if (!_isValidEmail(email)) {
      throw const SignInException('Invalid email format');
    }

    if (password.length < 8) {
      throw const SignInException('Password must be at least 8 characters');
    }
  }

  /// Validates the authenticated user
  void _validateAuthenticatedUser(AuthUser authUser) {
    if (!authUser.isAuthenticated) {
      throw const SignInException('Authentication failed');
    }

    // if (!authUser.user.isActive) {
    //   throw const SignInException('User account is deactivated');
    // }
  }

  /// Checks if email format is valid
  bool _isValidEmail(String email) {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email);
  }

  /// Handles sign in errors
  Exception _handleSignInError(dynamic error) {
    if (error is SignInException) {
      return error;
    }

    if (error.toString().contains('User not found')) {
      return const SignInException('User not found');
    }

    if (error.toString().contains('Invalid password')) {
      return const SignInException('Invalid password');
    }

    return SignInException('Sign in failed: ${error.toString()}');
  }
}

/// Exception thrown during sign in process
class SignInException implements Exception {
  final String message;

  const SignInException(this.message);

  @override
  String toString() => 'SignInException: $message';
}
