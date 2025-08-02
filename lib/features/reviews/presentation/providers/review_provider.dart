import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../shared/models/review_model.dart';
import '../../../../core/infrastructure/firebase/firestore_service.dart';
import '../../../../features/users/presentation/providers/user_provider.dart';

class ReviewNotifier extends StateNotifier<AsyncValue<List<ReviewModel>>> {
  final FirestoreService _firestore;

  ReviewNotifier(this._firestore) : super(const AsyncValue.loading()) {
    _loadReviews();
  }

  Future<void> _loadReviews() async {
    try {
      state = const AsyncValue.loading();
      final reviews = await _firestore
          .collectionStream('reviews')
          .map((q) => q.docs
              .map((doc) => ReviewModel.fromMap(
                  doc.data() as Map<String, dynamic>, doc.id))
              .toList())
          .first;

      // Sort by creation date (newest first)
      reviews.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      state = AsyncValue.data(reviews);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> addReview(ReviewModel review) async {
    try {
      await _firestore.addDocument('reviews', review.toMap());
      await _loadReviews(); // Reload the list
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateReview(
      String reviewId, Map<String, dynamic> updates) async {
    try {
      updates['updatedAt'] = DateTime.now();
      await _firestore.updateDocument('reviews', reviewId, updates);
      await _loadReviews(); // Reload the list
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteReview(String reviewId) async {
    try {
      await _firestore.deleteDocument('reviews', reviewId);
      await _loadReviews(); // Reload the list
    } catch (e) {
      rethrow;
    }
  }

  Future<void> approveReview(String reviewId) async {
    try {
      await _firestore.updateDocument('reviews', reviewId, {
        'status': 'approved',
        'approvedAt': DateTime.now(),
        'updatedAt': DateTime.now(),
      });
      await _loadReviews(); // Reload the list
    } catch (e) {
      rethrow;
    }
  }

  Future<void> rejectReview(String reviewId, String reason) async {
    try {
      await _firestore.updateDocument('reviews', reviewId, {
        'status': 'rejected',
        'adminNotes': reason,
        'updatedAt': DateTime.now(),
      });
      await _loadReviews(); // Reload the list
    } catch (e) {
      rethrow;
    }
  }

  Future<void> markAsSpam(String reviewId) async {
    try {
      await _firestore.updateDocument('reviews', reviewId, {
        'status': 'spam',
        'updatedAt': DateTime.now(),
      });
      await _loadReviews(); // Reload the list
    } catch (e) {
      rethrow;
    }
  }

  Future<void> addAdminNotes(String reviewId, String notes) async {
    try {
      await _firestore.updateDocument('reviews', reviewId, {
        'adminNotes': notes,
        'updatedAt': DateTime.now(),
      });
      await _loadReviews(); // Reload the list
    } catch (e) {
      rethrow;
    }
  }

  Future<void> replyToReview(String reviewId, String reply) async {
    try {
      await _firestore.updateDocument('reviews', reviewId, {
        'reply': reply,
        'repliedAt': DateTime.now(),
        'updatedAt': DateTime.now(),
      });
      await _loadReviews(); // Reload the list
    } catch (e) {
      rethrow;
    }
  }

  Future<void> markAsHelpful(String reviewId) async {
    try {
      await _firestore.updateDocument('reviews', reviewId, {
        'isHelpful': true,
        'helpfulCount': FieldValue.increment(1),
        'updatedAt': DateTime.now(),
      });
      await _loadReviews(); // Reload the list
    } catch (e) {
      rethrow;
    }
  }

  // Get reviews by status
  List<ReviewModel> getReviewsByStatus(String status) {
    return state.when(
      data: (reviews) =>
          reviews.where((review) => review.status == status).toList(),
      loading: () => [],
      error: (_, __) => [],
    );
  }

  // Get reviews by product
  List<ReviewModel> getReviewsByProduct(String productId) {
    return state.when(
      data: (reviews) =>
          reviews.where((review) => review.productId == productId).toList(),
      loading: () => [],
      error: (_, __) => [],
    );
  }

  // Get reviews by rating
  List<ReviewModel> getReviewsByRating(int rating) {
    return state.when(
      data: (reviews) =>
          reviews.where((review) => review.rating == rating).toList(),
      loading: () => [],
      error: (_, __) => [],
    );
  }

  // Get verified reviews only
  List<ReviewModel> getVerifiedReviews() {
    return state.when(
      data: (reviews) => reviews.where((review) => review.isVerified).toList(),
      loading: () => [],
      error: (_, __) => [],
    );
  }

  // Get helpful reviews
  List<ReviewModel> getHelpfulReviews() {
    return state.when(
      data: (reviews) => reviews.where((review) => review.isHelpful).toList(),
      loading: () => [],
      error: (_, __) => [],
    );
  }

  // Get average rating for a product
  double getAverageRatingForProduct(String productId) {
    final productReviews = getReviewsByProduct(productId);
    if (productReviews.isEmpty) return 0.0;

    final totalRating =
        productReviews.fold(0, (sum, review) => sum + review.rating);
    return totalRating / productReviews.length;
  }

  // Get total reviews count
  int getTotalReviews() {
    return state.when(
      data: (reviews) => reviews.length,
      loading: () => 0,
      error: (_, __) => 0,
    );
  }

  // Get pending reviews count
  int getPendingReviews() {
    return state.when(
      data: (reviews) =>
          reviews.where((review) => review.status == 'pending').length,
      loading: () => 0,
      error: (_, __) => 0,
    );
  }

  // Get reviews that need moderation
  List<ReviewModel> getReviewsNeedingModeration() {
    return state.when(
      data: (reviews) =>
          reviews.where((review) => review.status == 'pending').toList(),
      loading: () => [],
      error: (_, __) => [],
    );
  }

  // Refresh reviews
  Future<void> refresh() async {
    await _loadReviews();
  }
}

final reviewProvider =
    StateNotifierProvider<ReviewNotifier, AsyncValue<List<ReviewModel>>>((ref) {
  final firestore = ref.watch(firestoreServiceProvider);
  return ReviewNotifier(firestore);
});

// Individual review provider
final reviewStreamProvider =
    FutureProvider.family<ReviewModel?, String>((ref, reviewId) async {
  final firestore = ref.watch(firestoreServiceProvider);
  try {
    final doc = await firestore.getDocument('reviews', reviewId);
    if (doc.exists) {
      return ReviewModel.fromMap(
        doc.data() as Map<String, dynamic>,
        doc.id,
      );
    }
    return null;
  } catch (e) {
    return null;
  }
});
