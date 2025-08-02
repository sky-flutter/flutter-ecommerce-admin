import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../shared/models/category_model.dart';
import '../../../../core/infrastructure/firebase/firestore_service.dart';
import '../../../../features/users/presentation/providers/user_provider.dart';

class CategoryNotifier extends StateNotifier<AsyncValue<List<CategoryModel>>> {
  final FirestoreService _firestore;

  CategoryNotifier(this._firestore) : super(const AsyncValue.loading()) {
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    try {
      state = const AsyncValue.loading();
      final snapshot =
          await FirebaseFirestore.instance.collection('categories').get();
      final categories = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return CategoryModel.fromMap(data, doc.id);
      }).toList();
      state = AsyncValue.data(categories);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> addCategory(CategoryModel category) async {
    try {
      await _firestore.addDocument('categories', category.toMap());
      await _loadCategories();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> updateCategory(String id, CategoryModel category) async {
    try {
      await _firestore.updateDocument('categories', id, category.toMap());
      await _loadCategories();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> deleteCategory(String id) async {
    try {
      await _firestore.deleteDocument('categories', id);
      await _loadCategories();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> toggleCategoryStatus(String id, bool isActive) async {
    try {
      await _firestore.updateDocument('categories', id, {'isActive': isActive});
      await _loadCategories();
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
}

final categoryNotifierProvider =
    StateNotifierProvider<CategoryNotifier, AsyncValue<List<CategoryModel>>>(
        (ref) {
  final firestore = ref.watch(firestoreServiceProvider);
  return CategoryNotifier(firestore);
});
