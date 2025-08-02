import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/infrastructure/firebase/firestore_service.dart';
import '../../../../shared/models/category_model.dart';
import '../../../../features/users/presentation/providers/user_provider.dart';

// Stream provider for all categories
final categoriesStreamProvider = StreamProvider((ref) {
  final firestore = ref.watch(firestoreServiceProvider);
  return firestore.collectionStream('categories');
});

// Provider for main categories only
final mainCategoriesProvider = Provider<AsyncValue<List<CategoryModel>>>((ref) {
  final categoriesAsync = ref.watch(categoriesStreamProvider);

  return categoriesAsync.when(
    data: (categoriesSnapshot) {
      final categories = categoriesSnapshot?.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return CategoryModel.fromMap(data, doc.id);
          }).toList() ??
          [];

      // Filter only main categories (parentId is null)
      final mainCategories =
          categories.where((category) => category.isMainCategory).toList();

      // Sort by sortOrder
      mainCategories.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

      return AsyncValue.data(mainCategories);
    },
    loading: () => const AsyncValue.loading(),
    error: (error, stack) => AsyncValue.error(error, stack),
  );
});

// Provider for subcategories of a specific category
final subcategoriesProvider =
    Provider.family<AsyncValue<List<CategoryModel>>, String>((ref, parentId) {
  final categoriesAsync = ref.watch(categoriesStreamProvider);

  return categoriesAsync.when(
    data: (categoriesSnapshot) {
      final categories = categoriesSnapshot?.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return CategoryModel.fromMap(data, doc.id);
          }).toList() ??
          [];

      // Filter subcategories for the given parent
      final subcategories = categories
          .where((category) => category.parentId == parentId)
          .toList();

      // Sort by sortOrder
      subcategories.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

      return AsyncValue.data(subcategories);
    },
    loading: () => const AsyncValue.loading(),
    error: (error, stack) => AsyncValue.error(error, stack),
  );
});

// Provider for all categories with hierarchy
final categoriesHierarchyProvider =
    Provider<AsyncValue<Map<String, List<CategoryModel>>>>((ref) {
  final categoriesAsync = ref.watch(categoriesStreamProvider);

  return categoriesAsync.when(
    data: (categoriesSnapshot) {
      final categories = categoriesSnapshot?.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return CategoryModel.fromMap(data, doc.id);
          }).toList() ??
          [];

      // Group categories by parentId
      final hierarchy = <String, List<CategoryModel>>{};

      for (final category in categories) {
        final parentId = category.parentId ?? 'main';
        if (!hierarchy.containsKey(parentId)) {
          hierarchy[parentId] = [];
        }
        hierarchy[parentId]!.add(category);
      }

      // Sort each group by sortOrder
      for (final key in hierarchy.keys) {
        hierarchy[key]!.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
      }

      return AsyncValue.data(hierarchy);
    },
    loading: () => const AsyncValue.loading(),
    error: (error, stack) => AsyncValue.error(error, stack),
  );
});

// Notifier for category operations
class CategoryNotifier extends StateNotifier<AsyncValue<void>> {
  final FirestoreService _firestore;

  CategoryNotifier(this._firestore) : super(const AsyncValue.data(null));

  Future<void> addCategory(CategoryModel category) async {
    state = const AsyncValue.loading();
    try {
      await _firestore.addDocument('categories', category.toMap());
      state = const AsyncValue.data(null);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> updateCategory(String id, Map<String, dynamic> data) async {
    state = const AsyncValue.loading();
    try {
      data['updatedAt'] = DateTime.now();
      await _firestore.updateDocument('categories', id, data);
      state = const AsyncValue.data(null);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> deleteCategory(String id) async {
    state = const AsyncValue.loading();
    try {
      await _firestore.deleteDocument('categories', id);
      state = const AsyncValue.data(null);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }

  Future<void> toggleCategoryStatus(String id, bool isActive) async {
    state = const AsyncValue.loading();
    try {
      await _firestore.updateDocument('categories', id, {
        'isActive': isActive,
        'updatedAt': DateTime.now(),
      });
      state = const AsyncValue.data(null);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
    }
  }
}

