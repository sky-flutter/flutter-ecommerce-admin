import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/widgets/enhanced_layout_wrapper.dart';

class InventoryPage extends ConsumerWidget {
  const InventoryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return EnhancedLayoutWrapper(
      currentRoute: '/inventory',
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Inventory Overview',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Manage your product inventory, track stock levels, and monitor inventory movements.',
                      style: TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        _buildInventoryCard(
                          'Total Items',
                          '1,234',
                          Icons.inventory,
                          Colors.blue,
                          context,
                        ),
                        const SizedBox(width: 16),
                        _buildInventoryCard(
                          'Low Stock',
                          '23',
                          Icons.warning,
                          Colors.orange,
                          context,
                        ),
                        const SizedBox(width: 16),
                        _buildInventoryCard(
                          'Out of Stock',
                          '5',
                          Icons.error,
                          Colors.red,
                          context,
                        ),
                        const SizedBox(width: 16),
                        _buildInventoryCard(
                          'Categories',
                          '12',
                          Icons.category,
                          Colors.green,
                          context,
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Quick Actions',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 16,
                      runSpacing: 16,
                      children: [
                        _buildActionCard(
                          'Add New Item',
                          'Add a new product to inventory',
                          Icons.add,
                          Colors.green,
                          context,
                        ),
                        _buildActionCard(
                          'Update Stock',
                          'Update stock levels for existing items',
                          Icons.edit,
                          Colors.blue,
                          context,
                        ),
                        _buildActionCard(
                          'Generate Report',
                          'Generate inventory reports',
                          Icons.assessment,
                          Colors.orange,
                          context,
                        ),
                        _buildActionCard(
                          'Export Data',
                          'Export inventory data',
                          Icons.download,
                          Colors.purple,
                          context,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInventoryCard(String title, String value, IconData icon,
      Color color, BuildContext context) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: color, size: 32),
              const SizedBox(height: 8),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionCard(String title, String description, IconData icon,
      Color color, BuildContext context) {
    return Card(
      child: Container(
        width: 200,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              description,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                // TODO: Implement action
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('$title action coming soon...')),
                );
              },
              child: const Text('Action'),
            ),
          ],
        ),
      ),
    );
  }
}
