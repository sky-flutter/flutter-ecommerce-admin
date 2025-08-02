import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

class AdminUserCreator {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Hash password for security
  static String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  // Create default admin user
  static Future<void> createDefaultAdmin() async {
    try {
      // Check if admin user already exists
      final existingUser = await _firestore
          .collection('users')
          .where('email', isEqualTo: 'admin@gmail.com')
          .get();

      if (existingUser.docs.isNotEmpty) {
        print('Admin user already exists');
        return;
      }

      // Create admin user
      final adminData = {
        'email': 'admin@gmail.com',
        'password': _hashPassword('admin123'),
        'displayName': 'Admin User',
        'role': 'admin',
        'createdAt': FieldValue.serverTimestamp(),
        'lastLoginAt': FieldValue.serverTimestamp(),
        'isActive': true,
      };

      await _firestore.collection('users').add(adminData);
      print('Admin user created successfully');
      print('Email: admin@gmail.com');
      print('Password: admin123');
    } catch (e) {
      print('Error creating admin user: $e');
    }
  }

  // Create test users with different roles
  static Future<void> createTestUsers() async {
    try {
      final testUsers = [
        {
          'email': 'editor@gmail.com',
          'password': _hashPassword('editor123'),
          'displayName': 'Editor User',
          'role': 'editor',
        },
        {
          'email': 'viewer@gmail.com',
          'password': _hashPassword('viewer123'),
          'displayName': 'Viewer User',
          'role': 'viewer',
        },
      ];

      for (final userData in testUsers) {
        // Check if user already exists
        final existingUser = await _firestore
            .collection('users')
            .where('email', isEqualTo: userData['email'])
            .get();

        if (existingUser.docs.isEmpty) {
          final userDoc = {
            ...userData,
            'createdAt': FieldValue.serverTimestamp(),
            'lastLoginAt': FieldValue.serverTimestamp(),
            'isActive': true,
          };

          await _firestore.collection('users').add(userDoc);
          print('Created user: ${userData['email']}');
        } else {
          print('User already exists: ${userData['email']}');
        }
      }
    } catch (e) {
      print('Error creating test users: $e');
    }
  }
}
