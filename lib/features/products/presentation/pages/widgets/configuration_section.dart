import 'package:flutter/material.dart';

class ConfigurationSection extends StatelessWidget {
  final bool isActive;
  final bool isFeatured;
  final bool isNewArrival;
  final Function(bool?) onActiveChanged;
  final Function(bool?) onFeaturedChanged;
  final Function(bool?) onNewArrivalChanged;

  const ConfigurationSection({
    super.key,
    required this.isActive,
    required this.isFeatured,
    required this.isNewArrival,
    required this.onActiveChanged,
    required this.onFeaturedChanged,
    required this.onNewArrivalChanged,
  });

  @override
  Widget build(BuildContext context) {
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
                  Icons.settings_outlined,
                  color: Theme.of(context).iconTheme.color,
                  size: 24,
                ),
                const SizedBox(width: 12),
                const Text(
                  'Configuration',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Status Toggles
            Column(
              children: [
                _buildToggleTile(
                  context,
                  title: 'Active Status',
                  subtitle: 'Make this product visible to customers',
                  value: isActive,
                  onChanged: onActiveChanged,
                  icon: Icons.visibility,
                  activeColor: Colors.green,
                ),
                const SizedBox(height: 16),
                _buildToggleTile(
                  context,
                  title: 'Featured Product',
                  subtitle: 'Highlight this product on the homepage',
                  value: isFeatured,
                  onChanged: onFeaturedChanged,
                  icon: Icons.star,
                  activeColor: Colors.orange,
                ),
                const SizedBox(height: 16),
                _buildToggleTile(
                  context,
                  title: 'New Arrival',
                  subtitle: 'Mark this as a new product',
                  value: isNewArrival,
                  onChanged: onNewArrivalChanged,
                  icon: Icons.new_releases,
                  activeColor: Colors.blue,
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Status Summary
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Product Status Summary',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildStatusItem(
                    'Active',
                    isActive,
                    Colors.green,
                  ),
                  _buildStatusItem(
                    'Featured',
                    isFeatured,
                    Colors.orange,
                  ),
                  _buildStatusItem(
                    'New Arrival',
                    isNewArrival,
                    Colors.blue,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToggleTile(
    BuildContext context, {
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool?) onChanged,
    required IconData icon,
    required Color activeColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(
          color: value ? activeColor : Colors.grey.shade300,
          width: value ? 2 : 1,
        ),
        borderRadius: BorderRadius.circular(8),
        color: value ? activeColor.withValues(alpha: 0.05) : Colors.transparent,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: value ? activeColor : Colors.grey.shade300,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(
              icon,
              color: value ? Colors.white : Colors.grey.shade600,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: value
                        ? activeColor
                        : Theme.of(context).textTheme.bodyMedium?.color,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: activeColor,
          ),
        ],
      ),
    );
  }

  Widget _buildStatusItem(String label, bool isActive, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            isActive ? Icons.check_circle : Icons.cancel,
            color: isActive ? color : Colors.grey,
            size: 16,
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: isActive ? color : Colors.grey,
              fontWeight: isActive ? FontWeight.w500 : FontWeight.normal,
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: isActive ? color : Colors.grey.shade300,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              isActive ? 'Enabled' : 'Disabled',
              style: TextStyle(
                color: isActive ? Colors.white : Colors.grey.shade600,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
