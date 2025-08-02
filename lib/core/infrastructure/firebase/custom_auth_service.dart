import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import '../../../shared/models/user_model.dart';

class CustomAuthService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  UserModel? _currentUser;
  bool _isAuthenticated = false;

  // Getters
  UserModel? get currentUser => _currentUser;
  bool get isAuthenticated => _isAuthenticated;

  // Stream to listen to authentication state changes
  Stream<UserModel?> get authStateChanges {
    return _firestore
        .collection('sessions')
        .where('isActive', isEqualTo: true)
        .snapshots()
        .asyncMap((snapshot) async {
      print(
          '🔄 Auth state change detected: ${snapshot.docs.length} active sessions');

      if (snapshot.docs.isNotEmpty) {
        final sessionData = snapshot.docs.first.data();
        final userId = sessionData['userId'] as String;
        print('👤 Found active session for user: $userId');
        return await _getUserFromId(userId);
      } else {
        print('🚪 No active sessions found - user should be logged out');
        return null;
      }
    });
  }

  // Hash password for security
  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  // Sign in with email and password
  Future<UserModel?> signIn(String email, String password) async {
    try {
      // Check if user exists in Firestore
      final userQuery = await _firestore
          .collection('users')
          .where('email', isEqualTo: email.toLowerCase())
          .get();

      if (userQuery.docs.isEmpty) {
        throw Exception('User not found');
      }

      final userData = userQuery.docs.first.data();
      final hashedPassword = _hashPassword(password);
      if (userData['password'] != hashedPassword) {
        throw Exception('Invalid password');
      }

      // Create user model
      final user = UserModel.fromMap(userData, userQuery.docs.first.id);

      // Create or update session
      await _createSession(user.id);

      _currentUser = user;
      _isAuthenticated = true;

      return user;
    } catch (e) {
      print('Sign in error: $e');
      rethrow;
    }
  }

  // Create new user account
  Future<UserModel> createUser({
    required String email,
    required String password,
    required String displayName,
    String role = 'viewer',
  }) async {
    try {
      // Check if user already exists
      final existingUser = await _firestore
          .collection('users')
          .where('email', isEqualTo: email.toLowerCase())
          .get();

      if (existingUser.docs.isNotEmpty) {
        throw Exception('User already exists');
      }

      // Create user document
      final userData = {
        'email': email.toLowerCase(),
        'password': _hashPassword(password),
        'displayName': displayName,
        'role': role,
        'createdAt': FieldValue.serverTimestamp(),
        'lastLoginAt': FieldValue.serverTimestamp(),
        'isActive': true,
      };

      final docRef = await _firestore.collection('users').add(userData);

      // Create user model
      final user = UserModel.fromMap(userData, docRef.id);

      // Create session
      //await _createSession(user.id);

      //_currentUser = user;
      //_isAuthenticated = true;

      return user;
    } catch (e) {
      print('Create user error: $e');
      rethrow;
    }
  }

  // Create session in Firestore
  Future<void> _createSession(String userId) async {
    try {
      // Deactivate all existing sessions for this user
      await _firestore
          .collection('sessions')
          .where('userId', isEqualTo: userId)
          .get()
          .then((snapshot) {
        for (var doc in snapshot.docs) {
          doc.reference.update({'isActive': false});
        }
      });

      // Create new session
      await _firestore.collection('sessions').add({
        'userId': userId,
        'createdAt': FieldValue.serverTimestamp(),
        'lastActivity': FieldValue.serverTimestamp(),
        'isActive': true,
      });

      // Update user's last login
      await _firestore.collection('users').doc(userId).update({
        'lastLoginAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Create session error: $e');
      rethrow;
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      print('🔐 Starting sign out process...');

      if (_currentUser != null) {
        print('👤 Deactivating sessions for user: ${_currentUser!.id}');

        // Deactivate current session
        final sessionQuery = await _firestore
            .collection('sessions')
            .where('userId', isEqualTo: _currentUser!.id)
            .where('isActive', isEqualTo: true)
            .get();

        print(
            '📝 Found ${sessionQuery.docs.length} active sessions to deactivate');

        for (var doc in sessionQuery.docs) {
          await doc.reference.update({
            'isActive': false,
            'deactivatedAt': FieldValue.serverTimestamp(),
          });
          print('✅ Deactivated session: ${doc.id}');
        }
      }

      // Clear local state
      _currentUser = null;
      _isAuthenticated = false;

      print('✅ Sign out completed successfully');
    } catch (e) {
      print('❌ Sign out error: $e');
      rethrow;
    }
  }

  // Force refresh auth state (useful for debugging)
  Future<void> forceRefreshAuthState() async {
    try {
      print('🔄 Force refreshing auth state...');

      // Check current active sessions
      final sessionQuery = await _firestore
          .collection('sessions')
          .where('isActive', isEqualTo: true)
          .get();

      print('📊 Current active sessions: ${sessionQuery.docs.length}');

      if (sessionQuery.docs.isEmpty) {
        _currentUser = null;
        _isAuthenticated = false;
        print('🚪 No active sessions - user should be logged out');
      } else {
        final sessionData = sessionQuery.docs.first.data();
        final userId = sessionData['userId'] as String;
        _currentUser = await _getUserFromId(userId);
        _isAuthenticated = _currentUser != null;
        print('👤 Found active user: ${_currentUser?.displayName}');
      }
    } catch (e) {
      print('❌ Force refresh auth state error: $e');
    }
  }

  // Force logout by invalidating all sessions for current user
  Future<void> forceLogout() async {
    try {
      print('🚪 Force logout initiated...');

      if (_currentUser != null) {
        // Deactivate ALL sessions for this user (not just active ones)
        final sessionQuery = await _firestore
            .collection('sessions')
            .where('userId', isEqualTo: _currentUser!.id)
            .get();

        print('📝 Found ${sessionQuery.docs.length} sessions to deactivate');

        for (var doc in sessionQuery.docs) {
          await doc.reference.update({
            'isActive': false,
            'forceLoggedOutAt': FieldValue.serverTimestamp(),
          });
          print('✅ Force deactivated session: ${doc.id}');
        }
      }

      // Clear local state immediately
      _currentUser = null;
      _isAuthenticated = false;

      print('✅ Force logout completed successfully');
    } catch (e) {
      print('❌ Force logout error: $e');
      rethrow;
    }
  }

  // Get user by ID
  Future<UserModel?> _getUserFromId(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (doc.exists) {
        return UserModel.fromMap(doc.data()!, doc.id);
      }
      return null;
    } catch (e) {
      print('Get user error: $e');
      return null;
    }
  }

  // Get user role
  Future<String> getUserRole(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      return doc.data()?['role'] ?? 'viewer';
    } catch (e) {
      print('Get user role error: $e');
      return 'viewer';
    }
  }

  // Update user profile
  Future<void> updateUserProfile(
      String userId, Map<String, dynamic> updates) async {
    try {
      await _firestore.collection('users').doc(userId).update(updates);

      // Update current user if it's the same user
      if (_currentUser?.id == userId) {
        _currentUser = await _getUserFromId(userId);
      }
    } catch (e) {
      print('Update user profile error: $e');
      rethrow;
    }
  }

  // Change password
  Future<void> changePassword(
      String userId, String currentPassword, String newPassword) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      final userData = doc.data();

      if (userData == null) {
        throw Exception('User not found');
      }

      final currentHashedPassword = _hashPassword(currentPassword);
      if (userData['password'] != currentHashedPassword) {
        throw Exception('Current password is incorrect');
      }

      await _firestore.collection('users').doc(userId).update({
        'password': _hashPassword(newPassword),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Change password error: $e');
      rethrow;
    }
  }

  // Delete user account
  Future<void> deleteUser(String userId) async {
    try {
      // Deactivate all sessions
      final sessions = await _firestore
          .collection('sessions')
          .where('userId', isEqualTo: userId)
          .get();

      for (var doc in sessions.docs) {
        await doc.reference.update({'isActive': false});
      }

      // Delete user document
      await _firestore.collection('users').doc(userId).delete();

      // If it's the current user, sign out
      if (_currentUser?.id == userId) {
        _currentUser = null;
        _isAuthenticated = false;
      }
    } catch (e) {
      print('Delete user error: $e');
      rethrow;
    }
  }

  // Check if session is valid
  Future<bool> isSessionValid() async {
    try {
      if (_currentUser == null) return false;

      final sessionQuery = await _firestore
          .collection('sessions')
          .where('userId', isEqualTo: _currentUser!.id)
          .where('isActive', isEqualTo: true)
          .get();

      return sessionQuery.docs.isNotEmpty;
    } catch (e) {
      print('Check session validity error: $e');
      return false;
    }
  }

  // Initialize authentication state
  Future<void> initializeAuth() async {
    try {
      final sessionQuery = await _firestore
          .collection('sessions')
          .where('isActive', isEqualTo: true)
          .get();

      if (sessionQuery.docs.isNotEmpty) {
        final sessionData = sessionQuery.docs.first.data();
        final userId = sessionData['userId'] as String;
        _currentUser = await _getUserFromId(userId);
        _isAuthenticated = _currentUser != null;
      }
    } catch (e) {
      print('Initialize auth error: $e');
      _currentUser = null;
      _isAuthenticated = false;
    }
  }
}
