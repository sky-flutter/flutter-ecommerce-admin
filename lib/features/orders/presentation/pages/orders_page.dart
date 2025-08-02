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

class OrdersPage extends ConsumerStatefulWidget {
  const OrdersPage({super.key});

  @override
  ConsumerState<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends ConsumerState<OrdersPage> {
  String _selectedStatus = 'All';
  String _selectedPaymentStatus = 'All';
  String _searchQuery = '';
  DateTime? _startDate;
  DateTime? _endDate;

  final List<String> _statusOptions = [
    'All',
    'pending',
    'confirmed',
    'processing',
    'shipped',
    'delivered',
    'cancelled',
    'refunded',
  ];

  final List<String> _paymentStatusOptions = [
    'All',
    'pending',
    'paid',
    'failed',
    'refunded',
  ];

  @override
  Widget build(BuildContext context) {
    final ordersAsync = ref.watch(orderProvider);
    final currentUser = ref.watch(customAuthStateProvider).value;
    final userRoleAsync = currentUser != null
        ? ref.watch(customUserRoleProvider(currentUser.id))
        : null;

    return EnhancedLayoutWrapper(
      currentRoute: '/orders',
      child: Column(
        children: [
          // Header Section
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            margin: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.shopping_bag,
                      color: AppTheme.primaryColor,
                      size: 32,
                    ),
                    const SizedBox(width: 16),
                    const Text(
                      'Orders Management',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Filters Row
                Row(
                  children: [
                    // Search
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Search orders...',
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onChanged: (value) {
                          setState(() {
                            _searchQuery = value;
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 16),

                    // Status Filter
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: DropdownButton<String>(
                        value: _selectedStatus,
                        items: _statusOptions.map((status) {
                          return DropdownMenuItem(
                            value: status,
                            child: Text(status),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedStatus = value!;
                          });
                        },
                        underline: Container(),
                      ),
                    ),
                    const SizedBox(width: 16),

                    // Payment Status Filter
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: DropdownButton<String>(
                        value: _selectedPaymentStatus,
                        items: _paymentStatusOptions.map((status) {
                          return DropdownMenuItem(
                            value: status,
                            child: Text(status),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedPaymentStatus = value!;
                          });
                        },
                        underline: Container(),
                      ),
                    ),
                    const SizedBox(width: 16),

                    // Date Range Picker
                    ElevatedButton.icon(
                      onPressed: _showDateRangePicker,
                      icon: const Icon(Icons.date_range),
                      label: const Text('Date Range'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Orders List
          Expanded(
            child: ordersAsync.when(
              data: (orders) {
                final filteredOrders = _filterOrders(orders);

                if (filteredOrders.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.shopping_bag_outlined,
                          size: 64,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'No orders found',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredOrders.length,
                  itemBuilder: (context, index) {
                    final order = filteredOrders[index];
                    return _buildOrderCard(order);
                  },
                );
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
                      'Error loading orders: $error',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<OrderModel> _filterOrders(List<OrderModel> orders) {
    return orders.where((order) {
      // Status filter
      if (_selectedStatus != 'All' && order.status != _selectedStatus) {
        return false;
      }

      // Payment status filter
      if (_selectedPaymentStatus != 'All' &&
          order.paymentStatus != _selectedPaymentStatus) {
        return false;
      }

      // Search filter
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        final matchesSearch =
            order.customerName.toLowerCase().contains(query) ||
                order.customerEmail.toLowerCase().contains(query) ||
                order.id.toLowerCase().contains(query) ||
                order.trackingNumber.toLowerCase().contains(query);

        if (!matchesSearch) {
          return false;
        }
      }

      // Date range filter
      if (_startDate != null && order.createdAt.isBefore(_startDate!)) {
        return false;
      }
      if (_endDate != null && order.createdAt.isAfter(_endDate!)) {
        return false;
      }

      return true;
    }).toList();
  }

  Widget _buildOrderCard(OrderModel order) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Order #${order.id.substring(0, 8)}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Customer: ${order.customerName}',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      ref
                          .watch(currencyFormatterProvider)
                          .formatPrice(order.total),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.successColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      DateFormat('MMM dd, yyyy').format(order.createdAt),
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Status and Payment Status
            Row(
              children: [
                _buildStatusChip(order.status, _getStatusColor(order.status)),
                const SizedBox(width: 8),
                _buildStatusChip(order.paymentStatus,
                    _getPaymentStatusColor(order.paymentStatus)),
                const Spacer(),
                Text(
                  '${order.items.length} items',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Order Items Preview
            if (order.items.isNotEmpty) ...[
              Text(
                'Items:',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 8),
              ...order.items.take(3).map((item) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      children: [
                        Text(
                          '• ${item.productName}',
                          style: const TextStyle(fontSize: 14),
                        ),
                        const Spacer(),
                        Text(
                          '${item.quantity}x ${ref.watch(currencyFormatterProvider).formatPrice(item.price)}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  )),
              if (order.items.length > 3)
                Text(
                  '... and ${order.items.length - 3} more items',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[500],
                    fontStyle: FontStyle.italic,
                  ),
                ),
              const SizedBox(height: 16),
            ],

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _viewOrderDetails(order),
                    icon: const Icon(Icons.visibility),
                    label: const Text('View Details'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.primaryColor,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _updateOrderStatus(order),
                    icon: const Icon(Icons.edit),
                    label: const Text('Update Status'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: Colors.white,
                    ),
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

  Color _getPaymentStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'paid':
        return Colors.green;
      case 'failed':
        return Colors.red;
      case 'refunded':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  void _showDateRangePicker() {
    showDateRangePicker(
      context: context,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
      initialDateRange: _startDate != null && _endDate != null
          ? DateTimeRange(start: _startDate!, end: _endDate!)
          : null,
    ).then((dateRange) {
      if (dateRange != null) {
        setState(() {
          _startDate = dateRange.start;
          _endDate = dateRange.end;
        });
      }
    });
  }

  void _viewOrderDetails(OrderModel order) {
    // Navigate to order details page
    context.push('/orders/${order.id}');
  }

  void _updateOrderStatus(OrderModel order) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update Order Status'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Select new status:'),
            const SizedBox(height: 16),
            ..._statusOptions.where((status) => status != 'All').map((status) {
              return ListTile(
                title: Text(status),
                onTap: () {
                  Navigator.pop(context);
                  _confirmStatusUpdate(order, status);
                },
              );
            }),
          ],
        ),
      ),
    );
  }

  void _confirmStatusUpdate(OrderModel order, String newStatus) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Status Update'),
        content: Text(
            'Are you sure you want to update order #${order.id.substring(0, 8)} to $newStatus?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _performStatusUpdate(order, newStatus);
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  Future<void> _performStatusUpdate(OrderModel order, String newStatus) async {
    try {
      await ref
          .read(orderProvider.notifier)
          .updateOrderStatus(order.id, newStatus);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Order status updated to $newStatus'),
            backgroundColor: AppTheme.successColor,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating order status: $e'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }
}
