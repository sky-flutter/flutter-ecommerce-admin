import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_theme.dart';
import '../../../../shared/models/order_model.dart';
import '../../../../features/orders/presentation/providers/order_provider.dart';
import '../../../../shared/services/currency_provider.dart';
import '../../../../shared/widgets/enhanced_layout_wrapper.dart';
import '../../../../features/auth/presentation/providers/custom_auth_provider.dart';
import '../../../../features/users/presentation/providers/user_provider.dart';

class OrderDetailsPage extends ConsumerWidget {
  final String orderId;

  const OrderDetailsPage({
    super.key,
    required this.orderId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orderAsync = ref.watch(orderStreamProvider(orderId));
    final currentUser = ref.watch(customAuthStateProvider).value;
    final userRoleAsync = currentUser != null
        ? ref.watch(customUserRoleProvider(currentUser.id))
        : null;

    return EnhancedLayoutWrapper(
      currentRoute: '/orders',
      child: orderAsync.when(
        data: (order) {
          if (order == null) {
            return const Center(
              child: Text('Order not found'),
            );
          }
          return _buildOrderDetails(context, ref, order);
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
                'Error loading order: $error',
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

  Widget _buildOrderDetails(
      BuildContext context, WidgetRef ref, OrderModel order) {
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
                  'Order #${order.id.substring(0, 8)}',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              _buildStatusChip(order.status, _getStatusColor(order.status)),
            ],
          ),
          const SizedBox(height: 24),

          // Customer Information
          _buildSection(
            'Customer Information',
            Icons.person,
            [
              _buildInfoRow('Name', order.customerName),
              _buildInfoRow('Email', order.customerEmail),
              _buildInfoRow('Phone', order.customerPhone),
            ],
          ),
          const SizedBox(height: 16),

          // Order Items
          _buildSection(
            'Order Items',
            Icons.shopping_bag,
            [
              ...order.items.map((item) => _buildOrderItem(context, ref, item)),
            ],
          ),
          const SizedBox(height: 16),

          // Pricing Information
          _buildSection(
            'Pricing Information',
            Icons.attach_money,
            [
              _buildInfoRow(
                  'Subtotal',
                  ref
                      .watch(currencyFormatterProvider)
                      .formatPrice(order.subtotal)),
              _buildInfoRow('Tax',
                  ref.watch(currencyFormatterProvider).formatPrice(order.tax)),
              _buildInfoRow(
                  'Shipping',
                  ref
                      .watch(currencyFormatterProvider)
                      .formatPrice(order.shipping)),
              if (order.discountAmount != null && order.discountAmount! > 0)
                _buildInfoRow('Discount',
                    '-${ref.watch(currencyFormatterProvider).formatPrice(order.discountAmount!)}'),
              const Divider(),
              _buildInfoRow(
                'Total',
                ref.watch(currencyFormatterProvider).formatPrice(order.total),
                isTotal: true,
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Order Information
          _buildSection(
            'Order Information',
            Icons.receipt,
            [
              _buildInfoRow('Order Date',
                  DateFormat('MMM dd, yyyy HH:mm').format(order.createdAt)),
              if (order.updatedAt != null)
                _buildInfoRow('Last Updated',
                    DateFormat('MMM dd, yyyy HH:mm').format(order.updatedAt!)),
              _buildInfoRow('Status', order.status.toUpperCase()),
              _buildInfoRow(
                  'Payment Status', order.paymentStatus.toUpperCase()),
              _buildInfoRow('Payment Method', order.paymentMethod),
              if (order.couponCode != null)
                _buildInfoRow('Coupon Code', order.couponCode!),
            ],
          ),
          const SizedBox(height: 16),

          // Shipping Information
          _buildSection(
            'Shipping Information',
            Icons.local_shipping,
            [
              _buildInfoRow('Shipping Address', order.shippingAddress),
              _buildInfoRow('Billing Address', order.billingAddress),
              if (order.trackingNumber.isNotEmpty)
                _buildInfoRow('Tracking Number', order.trackingNumber),
              if (order.shippedAt != null)
                _buildInfoRow('Shipped Date',
                    DateFormat('MMM dd, yyyy').format(order.shippedAt!)),
              if (order.deliveredAt != null)
                _buildInfoRow('Delivered Date',
                    DateFormat('MMM dd, yyyy').format(order.deliveredAt!)),
            ],
          ),
          const SizedBox(height: 16),

          // Notes
          if (order.notes.isNotEmpty)
            _buildSection(
              'Notes',
              Icons.note,
              [
                _buildInfoRow('', order.notes),
              ],
            ),

          // Refund Information
          if (order.status == 'refunded')
            _buildSection(
              'Refund Information',
              Icons.money_off,
              [
                if (order.refundReason != null)
                  _buildInfoRow('Reason', order.refundReason!),
                if (order.refundedAt != null)
                  _buildInfoRow('Refunded Date',
                      DateFormat('MMM dd, yyyy').format(order.refundedAt!)),
              ],
            ),

          const SizedBox(height: 32),

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _updateOrderStatus(context, ref, order),
                  icon: const Icon(Icons.edit),
                  label: const Text('Update Status'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _addTrackingNumber(context, ref, order),
                  icon: const Icon(Icons.local_shipping),
                  label: const Text('Add Tracking'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.primaryColor,
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

  Widget _buildInfoRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: isTotal ? AppTheme.primaryColor : null,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
                color: isTotal ? AppTheme.primaryColor : null,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderItem(BuildContext context, WidgetRef ref, OrderItem item) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Product Image
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  item.productImage,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey.shade200,
                      child: const Icon(Icons.image),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Product Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.productName,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Qty: ${item.quantity}',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),

            // Price
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  ref.watch(currencyFormatterProvider).formatPrice(item.price),
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  ref.watch(currencyFormatterProvider).formatPrice(item.total),
                  style: TextStyle(
                    color: AppTheme.successColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
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

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'confirmed':
        return Colors.blue;
      case 'processing':
        return Colors.purple;
      case 'shipped':
        return Colors.indigo;
      case 'delivered':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      case 'refunded':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  void _updateOrderStatus(
      BuildContext context, WidgetRef ref, OrderModel order) {
    final statusOptions = [
      'pending',
      'confirmed',
      'processing',
      'shipped',
      'delivered',
      'cancelled',
      'refunded',
    ];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update Order Status'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Select new status:'),
            const SizedBox(height: 16),
            ...statusOptions.map((status) {
              return ListTile(
                title: Text(status),
                trailing:
                    order.status == status ? const Icon(Icons.check) : null,
                onTap: () {
                  Navigator.pop(context);
                  _performStatusUpdate(context, ref, order, status);
                },
              );
            }),
          ],
        ),
      ),
    );
  }

  void _addTrackingNumber(
      BuildContext context, WidgetRef ref, OrderModel order) {
    final trackingController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Tracking Number'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: trackingController,
              decoration: const InputDecoration(
                labelText: 'Tracking Number',
                hintText: 'Enter tracking number...',
              ),
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
              if (trackingController.text.trim().isNotEmpty) {
                Navigator.pop(context);
                _performAddTracking(
                    context, ref, order, trackingController.text.trim());
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  Future<void> _performStatusUpdate(BuildContext context, WidgetRef ref,
      OrderModel order, String newStatus) async {
    try {
      await ref
          .read(orderProvider.notifier)
          .updateOrderStatus(order.id, newStatus);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Order status updated to $newStatus'),
            backgroundColor: AppTheme.successColor,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating order status: $e'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  Future<void> _performAddTracking(BuildContext context, WidgetRef ref,
      OrderModel order, String trackingNumber) async {
    try {
      await ref
          .read(orderProvider.notifier)
          .addTrackingNumber(order.id, trackingNumber);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Tracking number added: $trackingNumber'),
            backgroundColor: AppTheme.successColor,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error adding tracking number: $e'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }
}
