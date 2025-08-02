import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/widgets/enhanced_layout_wrapper.dart';

class ReportsPage extends ConsumerWidget {
  const ReportsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return EnhancedLayoutWrapper(
      currentRoute: '/reports',
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
                      'Reports Dashboard',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Generate and view detailed reports about your business performance.',
                      style: TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 20),
                    Wrap(
                      spacing: 16,
                      runSpacing: 16,
                      children: [
                        _buildReportCard(
                          'Sales Report',
                          'Monthly sales analysis',
                          Icons.bar_chart,
                          Colors.blue,
                          context,
                        ),
                        _buildReportCard(
                          'Inventory Report',
                          'Stock levels and alerts',
                          Icons.inventory,
                          Colors.orange,
                          context,
                        ),
                        _buildReportCard(
                          'Customer Report',
                          'Customer behavior analysis',
                          Icons.people,
                          Colors.green,
                          context,
                        ),
                        _buildReportCard(
                          'Revenue Report',
                          'Revenue trends and projections',
                          Icons.trending_up,
                          Colors.purple,
                          context,
                        ),
                        _buildReportCard(
                          'Order Report',
                          'Order processing statistics',
                          Icons.shopping_cart,
                          Colors.red,
                          context,
                        ),
                        _buildReportCard(
                          'Product Report',
                          'Product performance metrics',
                          Icons.analytics,
                          Colors.teal,
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

  Widget _buildReportCard(String title, String description, IconData icon,
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
                // TODO: Implement report generation
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Generating $title...')),
                );
              },
              child: const Text('Generate'),
            ),
          ],
        ),
      ),
    );
  }
}
