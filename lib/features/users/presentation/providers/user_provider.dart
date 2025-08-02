import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/infrastructure/firebase/firestore_service.dart';
import '../../../../shared/models/user_model.dart';

final firestoreServiceProvider =
    Provider<FirestoreService>((ref) => FirestoreService());

final usersStreamProvider = StreamProvider((ref) {
  final firestore = ref.watch(firestoreServiceProvider);
  return firestore.collectionStream('users');
});

// Add, update, delete user methods can be implemented in a Notifier if needed 