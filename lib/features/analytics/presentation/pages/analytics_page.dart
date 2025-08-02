import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/widgets/enhanced_layout_wrapper.dart';
import '../../../../core/constants/app_theme.dart';
import '../../../../features/auth/presentation/providers/custom_auth_provider.dart';
import '../../../../shared/services/currency_provider.dart';

class AnalyticsPage extends ConsumerStatefulWidget {
  const AnalyticsPage({super.key});

  @override
  ConsumerState<AnalyticsPage> createState() => _AnalyticsPageState();
}

class _AnalyticsPageState extends ConsumerState<AnalyticsPage> {
  bool _isLoading = true;
  String _selectedPeriod = 'Last 30 Days';

  // Mock data for analytics
  final Map<String, double> _revenueData = {
    'Jan': 12500,
    'Feb': 15800,
    'Mar': 14200,
    'Apr': 18900,
    'May': 22100,
    'Jun': 19800,
  };

  final Map<String, int> _orderData = {
    'Jan': 45,
    'Feb': 52,
    'Mar': 48,
    'Apr': 67,
    'May': 78,
    'Jun': 71,
  };

  final Map<String, int> _customerData = {
    'Jan': 120,
    'Feb': 145,
    'Mar': 138,
    'Apr': 167,
    'May': 189,
    'Jun': 175,
  };

  @override
  void initState() {
    super.initState();
    _loadAnalytics();
  }

  Future<void> _loadAnalytics() async {
    try {
      // TODO: Load actual analytics data from Firebase
      await Future.delayed(const Duration(seconds: 1)); // Simulate loading
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading analytics: $e'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(customAuthStateProvider).value;
    final userRoleAsync = currentUser != null
        ? ref.watch(customUserRoleProvider(currentUser.id))
        : null;

    return EnhancedLayoutWrapper(
      currentRoute: '/analytics',
      child: Scaffold(
        body: userRoleAsync?.when(
              data: (role) {
                if (role != 'admin') {
                  return const Center(
                    child: Text('Access denied. You need admin permissions.'),
                  );
                }

                if (_isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                return SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Row(
                        children: [
                          Icon(
                            Icons.analytics,
                            color: AppTheme.primaryColor,
                            size: 32,
                          ),
                          const SizedBox(width: 16),
                          const Text(
                            'Analytics & Reports',
                            style: TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Spacer(),
                          DropdownButton<String>(
                            value: _selectedPeriod,
                            items: const [
                              DropdownMenuItem(
                                  value: 'Last 7 Days',
                                  child: Text('Last 7 Days')),
                              DropdownMenuItem(
                                  value: 'Last 30 Days',
                                  child: Text('Last 30 Days')),
                              DropdownMenuItem(
                                  value: 'Last 90 Days',
                                  child: Text('Last 90 Days')),
                              DropdownMenuItem(
                                  value: 'Last Year', child: Text('Last Year')),
                            ],
                            onChanged: (value) {
                              if (value != null) {
                                setState(() => _selectedPeriod = value);
                                _loadAnalytics();
                              }
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),

                      // Key Metrics
                      _buildKeyMetricsSection(),
                      const SizedBox(height: 32),

                      // Revenue Chart
                      _buildRevenueChart(),
                      const SizedBox(height: 32),

                      // Orders Chart
                      _buildOrdersChart(),
                      const SizedBox(height: 32),

                      // Customer Growth
                      _buildCustomerGrowthChart(),
                      const SizedBox(height: 32),

                      // Top Products
                      _buildTopProductsSection(),
                      const SizedBox(height: 32),

                      // Recent Activity
                      _buildRecentActivitySection(),
                      const SizedBox(height: 32),
                    ],
                  ),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Center(child: Text('Error: $error')),
            ) ??
            const Center(child: CircularProgressIndicator()),
      ),
    );
  }

  Widget _buildKeyMetricsSection() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 4,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.5,
      children: [
        _buildMetricCard(
          'Total Revenue',
          ref
              .watch(currencyFormatterProvider)
              .formatPriceWithoutDecimal(_calculateTotalRevenue()),
          Icons.attach_money,
          AppTheme.successColor,
          '+12.5%',
          true,
        ),
        _buildMetricCard(
          'Total Orders',
          _calculateTotalOrders().toString(),
          Icons.shopping_cart,
          AppTheme.primaryColor,
          '+8.3%',
          true,
        ),
        _buildMetricCard(
          'Total Customers',
          _calculateTotalCustomers().toString(),
          Icons.people,
          AppTheme.secondaryColor,
          '+15.2%',
          true,
        ),
        _buildMetricCard(
          'Average Order Value',
          ref
              .watch(currencyFormatterProvider)
              .formatPrice(_calculateAverageOrderValue()),
          Icons.analytics,
          AppTheme.secondaryColor,
          '+5.7%',
          true,
        ),
      ],
    );
  }

  Widget _buildMetricCard(String title, String value, IconData icon,
      Color color, String change, bool isPositive) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 24),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isPositive
                        ? AppTheme.successColor.withValues(alpha: 0.1)
                        : AppTheme.errorColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    change,
                    style: TextStyle(
                      color: isPositive
                          ? AppTheme.successColor
                          : AppTheme.errorColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.neutral600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRevenueChart() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.trending_up,
                  color: AppTheme.primaryColor,
                  size: 24,
                ),
                const SizedBox(width: 12),
                const Text(
                  'Revenue Trend',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 200,
              child: _buildBarChart(_revenueData, AppTheme.primaryColor),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrdersChart() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.shopping_bag,
                  color: AppTheme.secondaryColor,
                  size: 24,
                ),
                const SizedBox(width: 12),
                const Text(
                  'Orders Trend',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 200,
              child: _buildBarChart(_orderData, AppTheme.secondaryColor),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomerGrowthChart() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.people_outline,
                  color: AppTheme.secondaryColor,
                  size: 24,
                ),
                const SizedBox(width: 12),
                const Text(
                  'Customer Growth',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 200,
              child: _buildBarChart(_customerData, AppTheme.secondaryColor),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBarChart(Map<String, dynamic> data, Color color) {
    final maxValue = data.values
        .map((value) => (value as num).toDouble())
        .reduce((a, b) => a > b ? a : b);
    final entries = data.entries.toList();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: entries.map((entry) {
        final height = ((entry.value as num) / maxValue) * 160;
        return Expanded(
          child: Column(
            children: [
              Container(
                width: 30,
                height: height,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                entry.key,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildTopProductsSection() {
    final topProducts = [
      {'name': 'Wireless Headphones', 'sales': 156, 'revenue': 23400},
      {'name': 'Smart Watch', 'sales': 89, 'revenue': 17800},
      {'name': 'Laptop Stand', 'sales': 234, 'revenue': 11700},
      {'name': 'Phone Case', 'sales': 445, 'revenue': 8900},
      {'name': 'USB Cable', 'sales': 567, 'revenue': 5670},
    ];

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.inventory,
                  color: AppTheme.primaryColor,
                  size: 24,
                ),
                const SizedBox(width: 12),
                const Text(
                  'Top Products',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            ...topProducts.map((product) => _buildProductRow(product)).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildProductRow(Map<String, dynamic> product) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              product['name'],
              style: const TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              '${product['sales']}',
              style: const TextStyle(
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: Text(
              ref
                  .watch(currencyFormatterProvider)
                  .formatPriceWithoutDecimal(product['revenue'].toDouble()),
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: AppTheme.successColor,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivitySection() {
    final activities = [
      {
        'type': 'Order',
        'message': 'New order #1234 received',
        'time': '2 minutes ago',
        'color': AppTheme.primaryColor
      },
      {
        'type': 'Customer',
        'message': 'New customer registered',
        'time': '5 minutes ago',
        'color': AppTheme.secondaryColor
      },
      {
        'type': 'Product',
        'message': 'Product stock updated',
        'time': '10 minutes ago',
        'color': AppTheme.secondaryColor
      },
      {
        'type': 'Order',
        'message': 'Order #1233 shipped',
        'time': '15 minutes ago',
        'color': AppTheme.primaryColor
      },
      {
        'type': 'Customer',
        'message': 'Customer feedback received',
        'time': '20 minutes ago',
        'color': AppTheme.secondaryColor
      },
    ];

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.history,
                  color: AppTheme.primaryColor,
                  size: 24,
                ),
                const SizedBox(width: 12),
                const Text(
                  'Recent Activity',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            ...activities
                .map((activity) => _buildActivityRow(activity))
                .toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityRow(Map<String, dynamic> activity) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: activity['color'],
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity['message'],
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  activity['time'],
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.neutral600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper methods for calculations
  double _calculateTotalRevenue() {
    return _revenueData.values
        .map((value) => value as double)
        .reduce((a, b) => a + b);
  }

  int _calculateTotalOrders() {
    return _orderData.values
        .map((value) => value as int)
        .reduce((a, b) => a + b);
  }

  int _calculateTotalCustomers() {
    return _customerData.values
        .map((value) => value as int)
        .reduce((a, b) => a + b);
  }

  double _calculateAverageOrderValue() {
    return _calculateTotalRevenue() / _calculateTotalOrders();
  }
}
