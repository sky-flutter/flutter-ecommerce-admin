import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:responsive_builder/responsive_builder.dart';
import '../../../../shared/widgets/enhanced_layout_wrapper.dart';
import '../../../../shared/widgets/custom_card.dart';
import '../../../../core/utils/seed_data_loader.dart';
import '../../../../features/users/presentation/providers/user_provider.dart';
import '../../../../features/products/presentation/providers/product_provider.dart';
import '../../../../features/orders/presentation/providers/order_provider.dart';
import '../../../../shared/models/user_model.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return EnhancedLayoutWrapper(
      currentRoute: '/',
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Overview',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                ElevatedButton.icon(
                  onPressed: () =>
                      SeedDataLoader.showSeedDataDialog(context, ref),
                  icon: const Icon(Icons.data_usage),
                  label: const Text('Load Seed Data'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildKPICards(ref),
            const SizedBox(height: 32),
            const Text(
              'Recent Activity',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildRecentActivity(ref),
          ],
        ),
      ),
    );
  }

  Widget _buildKPICards(WidgetRef ref) {
    return ScreenTypeLayout(
      mobile: _buildKPICardsMobile(ref),
      tablet: _buildKPICardsTablet(ref),
      desktop: _buildKPICardsDesktop(ref),
    );
  }

  Widget _buildKPICardsMobile(WidgetRef ref) {
    return Column(
      children: [
        _buildKPICard(ref, 'Total Users', Icons.people, Colors.blue),
        const SizedBox(height: 16),
        _buildKPICard(ref, 'Total Products', Icons.shopping_bag, Colors.green),
        const SizedBox(height: 16),
        _buildKPICard(ref, 'Total Orders', Icons.receipt_long, Colors.orange),
        const SizedBox(height: 16),
        _buildKPICard(ref, 'Total Revenue', Icons.attach_money, Colors.purple),
      ],
    );
  }

  Widget _buildKPICardsTablet(WidgetRef ref) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 2.5,
      children: [
        _buildKPICard(ref, 'Total Users', Icons.people, Colors.blue),
        _buildKPICard(ref, 'Total Products', Icons.shopping_bag, Colors.green),
        _buildKPICard(ref, 'Total Orders', Icons.receipt_long, Colors.orange),
        _buildKPICard(ref, 'Total Revenue', Icons.attach_money, Colors.purple),
      ],
    );
  }

  Widget _buildKPICardsDesktop(WidgetRef ref) {
    return GridView.count(
      crossAxisCount: 4,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 2.5,
      children: [
        _buildKPICard(ref, 'Total Users', Icons.people, Colors.blue),
        _buildKPICard(ref, 'Total Products', Icons.shopping_bag, Colors.green),
        _buildKPICard(ref, 'Total Orders', Icons.receipt_long, Colors.orange),
        _buildKPICard(ref, 'Total Revenue', Icons.attach_money, Colors.purple),
      ],
    );
  }

  Widget _buildKPICard(
      WidgetRef ref, String title, IconData icon, Color color) {
    switch (title) {
      case 'Total Users':
        return _buildUserCard(ref, title, icon, color);
      case 'Total Products':
        return _buildProductCard(ref, title, icon, color);
      case 'Total Orders':
        return _buildOrderCard(ref, title, icon, color);
      case 'Total Revenue':
        return _buildRevenueCard(ref, title, icon, color);
      default:
        return CustomCard(title: title, value: '0', icon: icon, color: color);
    }
  }

  Widget _buildUserCard(
      WidgetRef ref, String title, IconData icon, Color color) {
    final usersAsync = ref.watch(usersStreamProvider);
    return usersAsync.when(
      data: (usersSnapshot) {
        final count = usersSnapshot.docs.length.toString();
        return CustomCard(title: title, value: count, icon: icon, color: color);
      },
      loading: () =>
          CustomCard(title: title, value: '...', icon: icon, color: color),
      error: (_, __) =>
          CustomCard(title: title, value: 'Error', icon: icon, color: color),
    );
  }

  Widget _buildProductCard(
      WidgetRef ref, String title, IconData icon, Color color) {
    final productsAsync = ref.watch(productsStreamProvider);
    return productsAsync.when(
      data: (productsSnapshot) {
        final count = productsSnapshot.docs.length.toString();
        return CustomCard(title: title, value: count, icon: icon, color: color);
      },
      loading: () =>
          CustomCard(title: title, value: '...', icon: icon, color: color),
      error: (_, __) =>
          CustomCard(title: title, value: 'Error', icon: icon, color: color),
    );
  }

  Widget _buildOrderCard(
      WidgetRef ref, String title, IconData icon, Color color) {
    final ordersAsync = ref.watch(orderProvider);
    return ordersAsync.when(
      data: (orders) {
        final count = orders.length.toString();
        return CustomCard(title: title, value: count, icon: icon, color: color);
      },
      loading: () =>
          CustomCard(title: title, value: '...', icon: icon, color: color),
      error: (_, __) =>
          CustomCard(title: title, value: 'Error', icon: icon, color: color),
    );
  }

  Widget _buildRevenueCard(
      WidgetRef ref, String title, IconData icon, Color color) {
    final ordersAsync = ref.watch(orderProvider);
    return ordersAsync.when(
      data: (orders) {
        double totalRevenue = 0;
        for (var order in orders) {
          totalRevenue += order.total;
        }
        return CustomCard(
            title: title,
            value: '\$${totalRevenue.toStringAsFixed(2)}',
            icon: icon,
            color: color);
      },
      loading: () =>
          CustomCard(title: title, value: '...', icon: icon, color: color),
      error: (_, __) =>
          CustomCard(title: title, value: 'Error', icon: icon, color: color),
    );
  }

  Widget _buildRecentActivity(WidgetRef ref) {
    return ScreenTypeLayout(
      mobile: _buildRecentActivityMobile(ref),
      tablet: _buildRecentActivityTablet(ref),
      desktop: _buildRecentActivityDesktop(ref),
    );
  }

  Widget _buildRecentActivityMobile(WidgetRef ref) {
    return Column(
      children: [
        _buildRecentOrders(ref),
        const SizedBox(height: 16),
        _buildRecentUsers(ref),
      ],
    );
  }

  Widget _buildRecentActivityTablet(WidgetRef ref) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: _buildRecentOrders(ref)),
        const SizedBox(width: 16),
        Expanded(child: _buildRecentUsers(ref)),
      ],
    );
  }

  Widget _buildRecentActivityDesktop(WidgetRef ref) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: _buildRecentOrders(ref)),
        const SizedBox(width: 16),
        Expanded(child: _buildRecentUsers(ref)),
      ],
    );
  }

  Widget _buildRecentOrders(WidgetRef ref) {
    final ordersAsync = ref.watch(orderProvider);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Recent Orders',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ordersAsync.when(
              data: (orders) {
                final recentOrders = orders.take(5).toList();

                return Column(
                  children: recentOrders
                      .map((order) => ListTile(
                            leading: const Icon(Icons.receipt),
                            title: Text('Order #${order.id.substring(0, 8)}'),
                            subtitle:
                                Text('\$${order.total.toStringAsFixed(2)}'),
                            trailing: Chip(
                              label: Text(order?.status ?? ''),
                              backgroundColor: _getStatusColor(order?.status ?? ''),
                            ),
                          ))
                      .toList(),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, __) => const Text('Error loading orders'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentUsers(WidgetRef ref) {
    final usersAsync = ref.watch(usersStreamProvider);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Recent Users',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            usersAsync.when(
              data: (usersSnapshot) {
                final recentUsers = usersSnapshot.docs.take(5).map((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  return UserModel.fromMap(data, doc.id);
                }).toList();

                return Column(
                  children: recentUsers
                      .map((user) => ListTile(
                            leading: CircleAvatar(
                              child: Text(user.displayName[0].toUpperCase()),
                            ),
                            title: Text(user.displayName),
                            subtitle: Text(user.email),
                            trailing: Chip(
                              label: Text(user.role),
                              backgroundColor: _getRoleColor(user.role),
                            ),
                          ))
                      .toList(),
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, __) => const Text('Error loading users'),
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Color _getRoleColor(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
        return Colors.red;
      case 'editor':
        return Colors.orange;
      case 'viewer':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }
}
