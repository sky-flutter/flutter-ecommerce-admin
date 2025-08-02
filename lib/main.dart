import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'firebase_options.dart';
import 'routes/app_router.dart';
import 'shared/services/theme_provider.dart';
import 'features/auth/presentation/providers/custom_auth_provider.dart';
import 'core/constants/app_theme.dart';
import 'core/utils/create_admin_user.dart';
import 'shared/widgets/auth_wrapper.dart';
import 'shared/widgets/splash_screen.dart';

/// Main entry point of the application
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await _initializeFirebase();
  await _createDefaultUsers();

  runApp(const ProviderScope(child: AdminPanelApp()));
}

/// Initializes Firebase and tests connectivity
Future<void> _initializeFirebase() async {
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    print('Testing Firebase connectivity...');
    await _testFirebaseConnection();
  } catch (e) {
    print('❌ Firebase initialization failed: $e');
  }
}

/// Tests Firebase connection and reports status
Future<void> _testFirebaseConnection() async {
  try {
    await FirebaseFirestore.instance.collection('_health').doc('test').get();
    print('✅ Firebase connection successful');
  } catch (e) {
    print('❌ Firebase connection failed: $e');
    print('Please check your Firebase configuration and security rules.');
  }
}

/// Creates default admin user and test users
Future<void> _createDefaultUsers() async {
  try {
    await AdminUserCreator.createDefaultAdmin();
    await AdminUserCreator.createTestUsers();
  } catch (e) {
    print('❌ Failed to create default users: $e');
  }
}

/// Main application widget
class AdminPanelApp extends ConsumerStatefulWidget {
  const AdminPanelApp({super.key});

  @override
  ConsumerState<AdminPanelApp> createState() => _AdminPanelAppState();
}

class _AdminPanelAppState extends ConsumerState<AdminPanelApp> {
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  /// Initializes the app with a splash screen
  Future<void> _initializeApp() async {
    // Simulate initialization time for better UX
    await Future.delayed(const Duration(milliseconds: 2000));

    if (mounted) {
      setState(() {
        _isInitialized = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return _buildSplashApp();
    }

    return _buildMainApp();
  }

  /// Builds the splash screen app
  Widget _buildSplashApp() {
    return MaterialApp(
      title: 'Ecommerce Admin Panel',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.lightTheme,
      themeMode: ref.watch(themeProvider),
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(),
    );
  }

  /// Builds the main application
  Widget _buildMainApp() {
    final router = ref.watch(appRouter);
    final themeMode = ref.watch(themeProvider);

    _initializeCustomAuth();

    return MaterialApp.router(
      title: 'Ecommerce Admin Panel',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
      builder: (context, child) {
        return AuthWrapper(child: child!);
      },
    );
  }

  /// Initializes custom authentication service
  void _initializeCustomAuth() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authService = ref.read(customAuthServiceProvider);
      authService.initializeAuth();
    });
  }
}
