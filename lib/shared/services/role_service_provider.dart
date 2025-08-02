import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/infrastructure/firebase/role_service.dart';

final roleServiceProvider = Provider<RoleService>((ref) => RoleService());
