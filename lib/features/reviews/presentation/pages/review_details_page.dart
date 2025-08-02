import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../shared/models/review_model.dart';
import '../providers/review_provider.dart';
import '../../../../features/auth/presentation/providers/custom_auth_provider.dart';
import '../../../../features/users/presentation/providers/user_provider.dart';
import '../../../../shared/widgets/enhanced_layout_wrapper.dart';
import '../../../../core/constants/app_theme.dart';

class ReviewDetailsPage extends ConsumerWidget {
  final String reviewId;

  const ReviewDetailsPage({
    super.key,
    required this.reviewId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reviewAsync = ref.watch(reviewStreamProvider(reviewId));
    final currentUser = ref.watch(customAuthStateProvider).value;
    final userRoleAsync = currentUser != null
        ? ref.watch(customUserRoleProvider(currentUser.id))
        : null;

    return EnhancedLayoutWrapper(
      currentRoute: '/reviews',
      child: reviewAsync.when(
        data: (review) {
          if (review == null) {
            return const Center(
              child: Text('Review not found'),
            );
          }
          return _buildReviewDetails(context, ref, review);
        },
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red,
              ),
              const SizedBox(height: 16),
              Text(
                'Error loading review: $error',
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.red,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReviewDetails(
      BuildContext context, WidgetRef ref, ReviewModel review) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              IconButton(
                onPressed: () => context.pop(),
                icon: const Icon(Icons.arrow_back),
              ),
              Expanded(
                child: Text(
                  'Review #${review.id.substring(0, 8)}',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              _buildStatusChip(review.status, review.statusColor),
            ],
          ),
          const SizedBox(height: 24),

          // Review Information
          _buildSection(
            'Review Information',
            Icons.star,
            [
              _buildInfoRow('Product', review.productName),
              _buildInfoRow(
                  'Rating', '${review.rating}/5 ${review.starRating}'),
              _buildInfoRow('Title', review.title),
              _buildInfoRow('Comment', review.comment),
              _buildInfoRow('Order ID', review.orderId),
              _buildInfoRow(
                  'Verified Purchase', review.isVerified ? 'Yes' : 'No'),
              _buildInfoRow('Anonymous', review.isAnonymous ? 'Yes' : 'No'),
              _buildInfoRow('Helpful Count', review.helpfulCount.toString()),
            ],
          ),
          const SizedBox(height: 16),

          // Customer Information
          _buildSection(
            'Customer Information',
            Icons.person,
            [
              _buildInfoRow('Name', review.customerName),
              _buildInfoRow('Email', review.customerEmail),
              _buildInfoRow('Customer ID', review.customerId),
            ],
          ),
          const SizedBox(height: 16),

          // Review Images
          if (review.images.isNotEmpty)
            _buildSection(
              'Review Images',
              Icons.image,
              [
                SizedBox(
                  height: 120,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: review.images.length,
                    itemBuilder: (context, index) {
                      return Container(
                        margin: const EdgeInsets.only(right: 12),
                        width: 120,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            review.images[index],
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: Colors.grey.shade200,
                                child: const Icon(Icons.image),
                              );
                            },
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          const SizedBox(height: 16),

          // Timestamps
          _buildSection(
            'Timestamps',
            Icons.schedule,
            [
              _buildInfoRow('Created',
                  DateFormat('MMM dd, yyyy HH:mm').format(review.createdAt)),
              if (review.updatedAt != null)
                _buildInfoRow('Updated',
                    DateFormat('MMM dd, yyyy HH:mm').format(review.updatedAt!)),
              if (review.approvedAt != null)
                _buildInfoRow(
                    'Approved',
                    DateFormat('MMM dd, yyyy HH:mm')
                        .format(review.approvedAt!)),
              if (review.repliedAt != null)
                _buildInfoRow('Replied',
                    DateFormat('MMM dd, yyyy HH:mm').format(review.repliedAt!)),
            ],
          ),
          const SizedBox(height: 16),

          // Admin Reply
          if (review.reply != null)
            _buildSection(
              'Admin Reply',
              Icons.reply,
              [
                _buildInfoRow('Reply', review.reply!),
              ],
            ),

          // Admin Notes
          if (review.adminNotes != null)
            _buildSection(
              'Admin Notes',
              Icons.note,
              [
                _buildInfoRow('Notes', review.adminNotes!),
              ],
            ),

          const SizedBox(height: 32),

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _approveReview(context, ref, review),
                  icon: const Icon(Icons.check),
                  label: const Text('Approve'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.successColor,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _rejectReview(context, ref, review),
                  icon: const Icon(Icons.close),
                  label: const Text('Reject'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.errorColor,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _replyToReview(context, ref, review),
                  icon: const Icon(Icons.reply),
                  label: const Text('Reply'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.primaryColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _markAsSpam(context, ref, review),
                  icon: const Icon(Icons.block),
                  label: const Text('Mark as Spam'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.orange,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _addAdminNotes(context, ref, review),
                  icon: const Icon(Icons.edit_note),
                  label: const Text('Add Notes'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.secondaryColor,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, IconData icon, List<Widget> children) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: AppTheme.primaryColor),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String status, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
        ),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  void _approveReview(BuildContext context, WidgetRef ref, ReviewModel review) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Approve Review'),
        content: const Text('Are you sure you want to approve this review?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _performApproveReview(context, ref, review);
            },
            child: const Text('Approve'),
          ),
        ],
      ),
    );
  }

  void _rejectReview(BuildContext context, WidgetRef ref, ReviewModel review) {
    final reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reject Review'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Are you sure you want to reject this review?'),
            const SizedBox(height: 16),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                labelText: 'Reason (Optional)',
                hintText: 'Enter rejection reason...',
              ),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _performRejectReview(
                  context, ref, review, reasonController.text.trim());
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorColor,
            ),
            child: const Text('Reject'),
          ),
        ],
      ),
    );
  }

  void _replyToReview(BuildContext context, WidgetRef ref, ReviewModel review) {
    final replyController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reply to Review'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: replyController,
              decoration: const InputDecoration(
                labelText: 'Reply',
                hintText: 'Enter your reply...',
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (replyController.text.trim().isNotEmpty) {
                Navigator.pop(context);
                _performReplyToReview(
                    context, ref, review, replyController.text.trim());
              }
            },
            child: const Text('Send Reply'),
          ),
        ],
      ),
    );
  }

  void _markAsSpam(BuildContext context, WidgetRef ref, ReviewModel review) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Mark as Spam'),
        content:
            const Text('Are you sure you want to mark this review as spam?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _performMarkAsSpam(context, ref, review);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
            ),
            child: const Text('Mark as Spam'),
          ),
        ],
      ),
    );
  }

  void _addAdminNotes(BuildContext context, WidgetRef ref, ReviewModel review) {
    final notesController =
        TextEditingController(text: review.adminNotes ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Admin Notes'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: notesController,
              decoration: const InputDecoration(
                labelText: 'Notes',
                hintText: 'Enter admin notes...',
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _performAddAdminNotes(
                  context, ref, review, notesController.text.trim());
            },
            child: const Text('Save Notes'),
          ),
        ],
      ),
    );
  }

  Future<void> _performApproveReview(
      BuildContext context, WidgetRef ref, ReviewModel review) async {
    try {
      await ref.read(reviewProvider.notifier).approveReview(review.id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Review approved successfully'),
            backgroundColor: AppTheme.successColor,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error approving review: $e'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  Future<void> _performRejectReview(BuildContext context, WidgetRef ref,
      ReviewModel review, String reason) async {
    try {
      await ref.read(reviewProvider.notifier).rejectReview(review.id, reason);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Review rejected successfully'),
            backgroundColor: AppTheme.successColor,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error rejecting review: $e'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  Future<void> _performReplyToReview(BuildContext context, WidgetRef ref,
      ReviewModel review, String reply) async {
    try {
      await ref.read(reviewProvider.notifier).replyToReview(review.id, reply);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Reply sent successfully'),
            backgroundColor: AppTheme.successColor,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error sending reply: $e'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  Future<void> _performMarkAsSpam(
      BuildContext context, WidgetRef ref, ReviewModel review) async {
    try {
      await ref.read(reviewProvider.notifier).markAsSpam(review.id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Review marked as spam'),
            backgroundColor: AppTheme.successColor,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error marking as spam: $e'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  Future<void> _performAddAdminNotes(BuildContext context, WidgetRef ref,
      ReviewModel review, String notes) async {
    try {
      await ref.read(reviewProvider.notifier).addAdminNotes(review.id, notes);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Admin notes saved'),
            backgroundColor: AppTheme.successColor,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving notes: $e'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }
}
