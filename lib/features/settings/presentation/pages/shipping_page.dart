import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../features/auth/presentation/providers/custom_auth_provider.dart';
import '../../../../features/users/presentation/providers/user_provider.dart';
import '../../../../shared/widgets/enhanced_layout_wrapper.dart';
import '../../../../core/constants/app_theme.dart';

class ShippingPage extends ConsumerStatefulWidget {
  const ShippingPage({super.key});

  @override
  ConsumerState<ShippingPage> createState() => _ShippingPageState();
}

class _ShippingPageState extends ConsumerState<ShippingPage> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  // Shipping Zones
  final List<ShippingZone> _shippingZones = [
    ShippingZone(
      name: 'Domestic',
      countries: ['US', 'CA'],
      states: ['All'],
      isActive: true,
    ),
    ShippingZone(
      name: 'International',
      countries: ['All'],
      states: ['All'],
      isActive: true,
    ),
  ];

  // Shipping Methods
  final List<ShippingMethod> _shippingMethods = [
    ShippingMethod(
      name: 'Standard Shipping',
      description: '5-7 business days',
      price: 5.99,
      isActive: true,
    ),
    ShippingMethod(
      name: 'Express Shipping',
      description: '2-3 business days',
      price: 12.99,
      isActive: true,
    ),
    ShippingMethod(
      name: 'Overnight Shipping',
      description: 'Next business day',
      price: 24.99,
      isActive: true,
    ),
  ];

  // Delivery Settings
  bool _enableFreeShipping = false;
  double _freeShippingThreshold = 50.0;
  bool _enableLocalPickup = false;
  bool _enableSameDayDelivery = false;
  double _sameDayDeliveryFee = 15.0;

  // Package Settings
  double _defaultPackageWeight = 1.0;
  String _defaultPackageUnit = 'lbs';
  double _maxPackageWeight = 50.0;

  // Delivery Times
  Map<String, String> _deliveryTimes = {
    'Standard': '5-7 business days',
    'Express': '2-3 business days',
    'Overnight': 'Next business day',
    'Same Day': 'Same day (if ordered before 2 PM)',
  };

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(customAuthStateProvider).value;
    final userRoleAsync = currentUser != null
        ? ref.watch(customUserRoleProvider(currentUser.id))
        : null;

    return EnhancedLayoutWrapper(
      currentRoute: '/shipping',
      child: Scaffold(
        body: userRoleAsync?.when(
              data: (role) {
                if (role != 'admin' && role != 'editor') {
                  return const Center(
                    child: Text(
                        'Access denied. You need admin or editor permissions.'),
                  );
                }

                return Form(
                  key: _formKey,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header
                        Row(
                          children: [
                            Icon(
                              Icons.local_shipping,
                              color: AppTheme.primaryColor,
                              size: 32,
                            ),
                            const SizedBox(width: 16),
                            const Text(
                              'Shipping & Delivery Settings',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Spacer(),
                            ElevatedButton.icon(
                              onPressed: _isLoading ? null : _saveSettings,
                              icon: _isLoading
                                  ? const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2),
                                    )
                                  : const Icon(Icons.save),
                              label: Text(
                                  _isLoading ? 'Saving...' : 'Save Settings'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.primaryColor,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),

                        // Shipping Zones Section
                        _buildShippingZonesSection(),
                        const SizedBox(height: 32),

                        // Shipping Methods Section
                        _buildShippingMethodsSection(),
                        const SizedBox(height: 32),

                        // Delivery Settings Section
                        _buildDeliverySettingsSection(),
                        const SizedBox(height: 32),

                        // Package Settings Section
                        _buildPackageSettingsSection(),
                        const SizedBox(height: 32),

                        // Delivery Times Section
                        _buildDeliveryTimesSection(),
                        const SizedBox(height: 32),
                      ],
                    ),
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

  Widget _buildShippingZonesSection() {
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
                  Icons.public,
                  color: Theme.of(context).primaryColor,
                  size: 24,
                ),
                const SizedBox(width: 12),
                const Text(
                  'Shipping Zones',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                ElevatedButton.icon(
                  onPressed: _addShippingZone,
                  icon: const Icon(Icons.add),
                  label: const Text('Add Zone'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Define shipping zones to set different rates for different regions',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 16),
            ..._shippingZones
                .map((zone) => _buildShippingZoneTile(zone))
                .toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildShippingZoneTile(ShippingZone zone) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(
          zone.isActive ? Icons.check_circle : Icons.cancel,
          color: zone.isActive ? Colors.green : Colors.red,
        ),
        title: Text(
          zone.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          'Countries: ${zone.countries.join(', ')}\nStates: ${zone.states.join(', ')}',
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Switch(
              value: zone.isActive,
              onChanged: (value) => _toggleZoneActive(zone, value),
            ),
            IconButton(
              onPressed: () => _editShippingZone(zone),
              icon: const Icon(Icons.edit),
            ),
            IconButton(
              onPressed: () => _deleteShippingZone(zone),
              icon: const Icon(Icons.delete),
              color: Colors.red,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShippingMethodsSection() {
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
                  Icons.delivery_dining,
                  color: Theme.of(context).primaryColor,
                  size: 24,
                ),
                const SizedBox(width: 12),
                const Text(
                  'Shipping Methods',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                ElevatedButton.icon(
                  onPressed: _addShippingMethod,
                  icon: const Icon(Icons.add),
                  label: const Text('Add Method'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Configure shipping methods and their rates',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 16),
            ..._shippingMethods
                .map((method) => _buildShippingMethodTile(method))
                .toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildShippingMethodTile(ShippingMethod method) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(
          method.isActive ? Icons.check_circle : Icons.cancel,
          color: method.isActive ? Colors.green : Colors.red,
        ),
        title: Text(
          method.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          '${method.description} - \$${method.price.toStringAsFixed(2)}',
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Switch(
              value: method.isActive,
              onChanged: (value) => _toggleMethodActive(method, value),
            ),
            IconButton(
              onPressed: () => _editShippingMethod(method),
              icon: const Icon(Icons.edit),
            ),
            IconButton(
              onPressed: () => _deleteShippingMethod(method),
              icon: const Icon(Icons.delete),
              color: Colors.red,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeliverySettingsSection() {
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
                  Icons.settings,
                  color: Theme.of(context).primaryColor,
                  size: 24,
                ),
                const SizedBox(width: 12),
                const Text(
                  'Delivery Settings',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Free Shipping
            SwitchListTile(
              title: const Text('Enable Free Shipping'),
              subtitle: const Text(
                  'Offer free shipping for orders above a certain amount'),
              value: _enableFreeShipping,
              onChanged: (value) => setState(() => _enableFreeShipping = value),
            ),
            if (_enableFreeShipping) ...[
              const SizedBox(height: 16),
              TextFormField(
                initialValue: _freeShippingThreshold.toString(),
                decoration: const InputDecoration(
                  labelText: 'Free Shipping Threshold (\$)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.attach_money),
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  final threshold = double.tryParse(value);
                  if (threshold != null) {
                    setState(() => _freeShippingThreshold = threshold);
                  }
                },
              ),
            ],

            const SizedBox(height: 24),

            // Local Pickup
            SwitchListTile(
              title: const Text('Enable Local Pickup'),
              subtitle: const Text(
                  'Allow customers to pick up orders from your store'),
              value: _enableLocalPickup,
              onChanged: (value) => setState(() => _enableLocalPickup = value),
            ),

            const SizedBox(height: 24),

            // Same Day Delivery
            SwitchListTile(
              title: const Text('Enable Same Day Delivery'),
              subtitle: const Text(
                  'Offer same day delivery for orders placed before cutoff time'),
              value: _enableSameDayDelivery,
              onChanged: (value) =>
                  setState(() => _enableSameDayDelivery = value),
            ),
            if (_enableSameDayDelivery) ...[
              const SizedBox(height: 16),
              TextFormField(
                initialValue: _sameDayDeliveryFee.toString(),
                decoration: const InputDecoration(
                  labelText: 'Same Day Delivery Fee (\$)',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.attach_money),
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  final fee = double.tryParse(value);
                  if (fee != null) {
                    setState(() => _sameDayDeliveryFee = fee);
                  }
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPackageSettingsSection() {
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
                  Icons.inventory_2,
                  color: Theme.of(context).primaryColor,
                  size: 24,
                ),
                const SizedBox(width: 12),
                const Text(
                  'Package Settings',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    initialValue: _defaultPackageWeight.toString(),
                    decoration: const InputDecoration(
                      labelText: 'Default Package Weight',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.scale),
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      final weight = double.tryParse(value);
                      if (weight != null) {
                        setState(() => _defaultPackageWeight = weight);
                      }
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _defaultPackageUnit,
                    decoration: const InputDecoration(
                      labelText: 'Weight Unit',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(
                          value: 'lbs', child: Text('Pounds (lbs)')),
                      DropdownMenuItem(
                          value: 'kg', child: Text('Kilograms (kg)')),
                      DropdownMenuItem(value: 'oz', child: Text('Ounces (oz)')),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _defaultPackageUnit = value);
                      }
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              initialValue: _maxPackageWeight.toString(),
              decoration: const InputDecoration(
                labelText: 'Maximum Package Weight',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.scale),
                helperText:
                    'Orders exceeding this weight will require special handling',
              ),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                final weight = double.tryParse(value);
                if (weight != null) {
                  setState(() => _maxPackageWeight = weight);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeliveryTimesSection() {
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
                  Icons.schedule,
                  color: Theme.of(context).primaryColor,
                  size: 24,
                ),
                const SizedBox(width: 12),
                const Text(
                  'Delivery Times',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Configure estimated delivery times for different shipping methods',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 16),
            ..._deliveryTimes.entries
                .map((entry) => _buildDeliveryTimeTile(entry.key, entry.value))
                .toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildDeliveryTimeTile(String method, String time) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        title: Text(method),
        subtitle: Text(time),
        trailing: IconButton(
          onPressed: () => _editDeliveryTime(method, time),
          icon: const Icon(Icons.edit),
        ),
      ),
    );
  }

  // Action Methods
  void _addShippingZone() {
    // TODO: Implement add shipping zone dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text('Add shipping zone functionality coming soon')),
    );
  }

  void _editShippingZone(ShippingZone zone) {
    // TODO: Implement edit shipping zone dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text('Edit shipping zone functionality coming soon')),
    );
  }

  void _deleteShippingZone(ShippingZone zone) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Shipping Zone'),
        content: Text(
            'Are you sure you want to delete the "${zone.name}" shipping zone?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() => _shippingZones.remove(zone));
              Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _toggleZoneActive(ShippingZone zone, bool value) {
    setState(() => zone.isActive = value);
  }

  void _addShippingMethod() {
    // TODO: Implement add shipping method dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text('Add shipping method functionality coming soon')),
    );
  }

  void _editShippingMethod(ShippingMethod method) {
    // TODO: Implement edit shipping method dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text('Edit shipping method functionality coming soon')),
    );
  }

  void _deleteShippingMethod(ShippingMethod method) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Shipping Method'),
        content: Text(
            'Are you sure you want to delete the "${method.name}" shipping method?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() => _shippingMethods.remove(method));
              Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _toggleMethodActive(ShippingMethod method, bool value) {
    setState(() => method.isActive = value);
  }

  void _editDeliveryTime(String method, String time) {
    // TODO: Implement edit delivery time dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text('Edit delivery time functionality coming soon')),
    );
  }

  Future<void> _saveSettings() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // TODO: Implement save to database
      await Future.delayed(const Duration(seconds: 1)); // Simulate API call

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Shipping settings saved successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving settings: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}

class ShippingZone {
  String name;
  List<String> countries;
  List<String> states;
  bool isActive;

  ShippingZone({
    required this.name,
    required this.countries,
    required this.states,
    required this.isActive,
  });
}

class ShippingMethod {
  String name;
  String description;
  double price;
  bool isActive;

  ShippingMethod({
    required this.name,
    required this.description,
    required this.price,
    required this.isActive,
  });
}
