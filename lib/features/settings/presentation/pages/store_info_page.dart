import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../features/auth/presentation/providers/custom_auth_provider.dart';
import '../../../../features/users/presentation/providers/user_provider.dart';
import '../../../../shared/widgets/enhanced_layout_wrapper.dart';
import '../../../../core/constants/app_theme.dart';

class StoreInfoPage extends ConsumerStatefulWidget {
  const StoreInfoPage({super.key});

  @override
  ConsumerState<StoreInfoPage> createState() => _StoreInfoPageState();
}

class _StoreInfoPageState extends ConsumerState<StoreInfoPage> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _isLoadingData = true;

  // Store Information
  final _storeNameController = TextEditingController();
  final _storeDescriptionController = TextEditingController();
  final _storeEmailController = TextEditingController();
  final _storePhoneController = TextEditingController();
  final _storeWebsiteController = TextEditingController();

  // Address Information
  final _addressLine1Controller = TextEditingController();
  final _addressLine2Controller = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _zipCodeController = TextEditingController();
  final _countryController = TextEditingController();

  // Business Information
  final _businessHoursController = TextEditingController();
  final _timezoneController = TextEditingController();
  final _currencyController = TextEditingController();
  final _taxRateController = TextEditingController();

  // Social Media
  final _facebookController = TextEditingController();
  final _twitterController = TextEditingController();
  final _instagramController = TextEditingController();
  final _linkedinController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadStoreInfo();
  }

  @override
  void dispose() {
    _storeNameController.dispose();
    _storeDescriptionController.dispose();
    _storeEmailController.dispose();
    _storePhoneController.dispose();
    _storeWebsiteController.dispose();
    _addressLine1Controller.dispose();
    _addressLine2Controller.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _zipCodeController.dispose();
    _countryController.dispose();
    _businessHoursController.dispose();
    _timezoneController.dispose();
    _currencyController.dispose();
    _taxRateController.dispose();
    _facebookController.dispose();
    _twitterController.dispose();
    _instagramController.dispose();
    _linkedinController.dispose();
    super.dispose();
  }

  Future<void> _loadStoreInfo() async {
    try {
      final firestore = ref.read(firestoreServiceProvider);
      final doc = await firestore.getDocument('store_info', 'main');

      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;

        setState(() {
          _storeNameController.text = data['storeName'] ?? '';
          _storeDescriptionController.text = data['storeDescription'] ?? '';
          _storeEmailController.text = data['storeEmail'] ?? '';
          _storePhoneController.text = data['storePhone'] ?? '';
          _storeWebsiteController.text = data['storeWebsite'] ?? '';
          _addressLine1Controller.text = data['addressLine1'] ?? '';
          _addressLine2Controller.text = data['addressLine2'] ?? '';
          _cityController.text = data['city'] ?? '';
          _stateController.text = data['state'] ?? '';
          _zipCodeController.text = data['zipCode'] ?? '';
          _countryController.text = data['country'] ?? '';
          _businessHoursController.text = data['businessHours'] ?? '';
          _timezoneController.text = data['timezone'] ?? '';
          _currencyController.text = data['currency'] ?? '';
          _taxRateController.text = data['taxRate']?.toString() ?? '';
          _facebookController.text = data['facebook'] ?? '';
          _twitterController.text = data['twitter'] ?? '';
          _instagramController.text = data['instagram'] ?? '';
          _linkedinController.text = data['linkedin'] ?? '';
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading store information: $e'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoadingData = false);
      }
    }
  }

  Future<void> _saveStoreInfo() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final firestore = ref.read(firestoreServiceProvider);

      final storeData = {
        'storeName': _storeNameController.text,
        'storeDescription': _storeDescriptionController.text,
        'storeEmail': _storeEmailController.text,
        'storePhone': _storePhoneController.text,
        'storeWebsite': _storeWebsiteController.text,
        'addressLine1': _addressLine1Controller.text,
        'addressLine2': _addressLine2Controller.text,
        'city': _cityController.text,
        'state': _stateController.text,
        'zipCode': _zipCodeController.text,
        'country': _countryController.text,
        'businessHours': _businessHoursController.text,
        'timezone': _timezoneController.text,
        'currency': _currencyController.text,
        'taxRate': double.tryParse(_taxRateController.text) ?? 0.0,
        'facebook': _facebookController.text,
        'twitter': _twitterController.text,
        'instagram': _instagramController.text,
        'linkedin': _linkedinController.text,
        'updatedAt': DateTime.now(),
      };

      final doc = await firestore.getDocument('store_info', 'main');
      if (doc.exists) {
        await firestore.updateDocument('store_info', 'main', storeData);
      } else {
        await firestore.addDocument('store_info', storeData, 'main');
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Store information saved successfully!'),
            backgroundColor: AppTheme.successColor,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving store information: $e'),
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
      currentRoute: '/store-info',
      child: Scaffold(
        body: userRoleAsync?.when(
              data: (role) {
                if (role != 'admin') {
                  return const Center(
                    child: Text('Access denied. You need admin permissions.'),
                  );
                }

                if (_isLoadingData) {
                  return const Center(child: CircularProgressIndicator());
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
                              Icons.store,
                              color: AppTheme.primaryColor,
                              size: 32,
                            ),
                            const SizedBox(width: 16),
                            const Text(
                              'Store Information',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Spacer(),
                            ElevatedButton.icon(
                              onPressed: _isLoading ? null : _saveStoreInfo,
                              icon: _isLoading
                                  ? const SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2),
                                    )
                                  : const Icon(Icons.save),
                              label: Text(_isLoading
                                  ? 'Saving...'
                                  : 'Save Information'),
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

                        // Store Information Section
                        _buildStoreInfoSection(),
                        const SizedBox(height: 32),

                        // Address Information Section
                        _buildAddressSection(),
                        const SizedBox(height: 32),

                        // Business Information Section
                        _buildBusinessSection(),
                        const SizedBox(height: 32),

                        // Social Media Section
                        _buildSocialMediaSection(),
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

  Widget _buildStoreInfoSection() {
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
                  Icons.business,
                  color: AppTheme.primaryColor,
                  size: 24,
                ),
                const SizedBox(width: 12),
                const Text(
                  'Store Information',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: _storeNameController,
              decoration: const InputDecoration(
                labelText: 'Store Name *',
                hintText: 'Enter your store name',
                prefixIcon: Icon(Icons.store),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Store name is required';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _storeDescriptionController,
              decoration: const InputDecoration(
                labelText: 'Store Description',
                hintText: 'Brief description of your store',
                prefixIcon: Icon(Icons.description),
                alignLabelWithHint: true,
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _storeEmailController,
                    decoration: const InputDecoration(
                      labelText: 'Store Email *',
                      hintText: 'contact@yourstore.com',
                      prefixIcon: Icon(Icons.email),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Store email is required';
                      }
                      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                          .hasMatch(value)) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _storePhoneController,
                    decoration: const InputDecoration(
                      labelText: 'Store Phone',
                      hintText: '+1 (555) 123-4567',
                      prefixIcon: Icon(Icons.phone),
                    ),
                    keyboardType: TextInputType.phone,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _storeWebsiteController,
              decoration: const InputDecoration(
                labelText: 'Store Website',
                hintText: 'https://yourstore.com',
                prefixIcon: Icon(Icons.language),
              ),
              keyboardType: TextInputType.url,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddressSection() {
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
                  Icons.location_on,
                  color: AppTheme.primaryColor,
                  size: 24,
                ),
                const SizedBox(width: 12),
                const Text(
                  'Address Information',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: _addressLine1Controller,
              decoration: const InputDecoration(
                labelText: 'Address Line 1 *',
                hintText: '123 Main Street',
                prefixIcon: Icon(Icons.home),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Address is required';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _addressLine2Controller,
              decoration: const InputDecoration(
                labelText: 'Address Line 2',
                hintText: 'Suite 100',
                prefixIcon: Icon(Icons.home_work),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _cityController,
                    decoration: const InputDecoration(
                      labelText: 'City *',
                      hintText: 'New York',
                      prefixIcon: Icon(Icons.location_city),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'City is required';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _stateController,
                    decoration: const InputDecoration(
                      labelText: 'State/Province *',
                      hintText: 'NY',
                      prefixIcon: Icon(Icons.map),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'State is required';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _zipCodeController,
                    decoration: const InputDecoration(
                      labelText: 'ZIP/Postal Code *',
                      hintText: '10001',
                      prefixIcon: Icon(Icons.pin_drop),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'ZIP code is required';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _countryController,
                    decoration: const InputDecoration(
                      labelText: 'Country *',
                      hintText: 'United States',
                      prefixIcon: Icon(Icons.public),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Country is required';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBusinessSection() {
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
                  color: AppTheme.primaryColor,
                  size: 24,
                ),
                const SizedBox(width: 12),
                const Text(
                  'Business Information',
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
                    controller: _businessHoursController,
                    decoration: const InputDecoration(
                      labelText: 'Business Hours',
                      hintText: 'Mon-Fri 9AM-6PM',
                      prefixIcon: Icon(Icons.access_time),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _timezoneController,
                    decoration: const InputDecoration(
                      labelText: 'Timezone',
                      hintText: 'America/New_York',
                      prefixIcon: Icon(Icons.timer),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _currencyController,
                    decoration: const InputDecoration(
                      labelText: 'Currency',
                      hintText: 'USD',
                      prefixIcon: Icon(Icons.attach_money),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _taxRateController,
                    decoration: const InputDecoration(
                      labelText: 'Tax Rate (%)',
                      hintText: '8.5',
                      prefixIcon: Icon(Icons.calculate),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSocialMediaSection() {
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
                  Icons.share,
                  color: AppTheme.primaryColor,
                  size: 24,
                ),
                const SizedBox(width: 12),
                const Text(
                  'Social Media',
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
                    controller: _facebookController,
                    decoration: const InputDecoration(
                      labelText: 'Facebook',
                      hintText: 'https://facebook.com/yourstore',
                      prefixIcon: Icon(Icons.facebook),
                    ),
                    keyboardType: TextInputType.url,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _twitterController,
                    decoration: const InputDecoration(
                      labelText: 'Twitter',
                      hintText: 'https://twitter.com/yourstore',
                      prefixIcon: Icon(Icons.flutter_dash),
                    ),
                    keyboardType: TextInputType.url,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _instagramController,
                    decoration: const InputDecoration(
                      labelText: 'Instagram',
                      hintText: 'https://instagram.com/yourstore',
                      prefixIcon: Icon(Icons.camera_alt),
                    ),
                    keyboardType: TextInputType.url,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _linkedinController,
                    decoration: const InputDecoration(
                      labelText: 'LinkedIn',
                      hintText: 'https://linkedin.com/company/yourstore',
                      prefixIcon: Icon(Icons.business),
                    ),
                    keyboardType: TextInputType.url,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
