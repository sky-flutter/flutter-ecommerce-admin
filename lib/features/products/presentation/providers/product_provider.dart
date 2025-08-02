import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../features/users/presentation/providers/user_provider.dart';

final productsStreamProvider = StreamProvider((ref) {
  final firestore = ref.watch(firestoreServiceProvider);
  return firestore.collectionStream('products');
});

// Add, update, delete product methods can be implemented in a Notifier if needed 