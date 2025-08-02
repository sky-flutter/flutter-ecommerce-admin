import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/infrastructure/firebase/custom_auth_service.dart';

final authServiceProvider =
    Provider<CustomAuthService>((ref) => CustomAuthService());

final authStateProvider = StreamProvider((ref) {
  final authService = ref.watch(authServiceProvider);
  return authService.authStateChanges;
});

final userRoleProvider =
    FutureProvider.family<String, String>((ref, uid) async {
  final authService = ref.watch(authServiceProvider);
  return await authService.getUserRole(uid);
});
