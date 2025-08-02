import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/infrastructure/firebase/storage_service.dart';

final storageServiceProvider =
    Provider<StorageService>((ref) => StorageService());
