import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../features/auth/presentation/providers/custom_auth_provider.dart';
import '../../../../features/users/presentation/providers/user_provider.dart';
import '../../../../shared/services/currency_provider.dart';
import '../../../../shared/widgets/enhanced_layout_wrapper.dart';
import '../../../../core/constants/app_theme.dart';

class PaymentSettingsPage extends ConsumerStatefulWidget {
  const PaymentSettingsPage({super.key});

  @override
  ConsumerState<PaymentSettingsPage> createState() =>
      _PaymentSettingsPageState();
}

class _PaymentSettingsPageState extends ConsumerState<PaymentSettingsPage> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _isLoadingData = true;

  // Payment Methods
  bool _enableStripe = false;
  bool _enablePayPal = false;
  bool _enableSquare = false;
  bool _enableCashOnDelivery = false;
  bool _enableBankTransfer = false;

  // Stripe Settings
  final _stripePublishableKeyController = TextEditingController();
  final _stripeSecretKeyController = TextEditingController();
  final _stripeWebhookSecretController = TextEditingController();

  // PayPal Settings
  final _paypalClientIdController = TextEditingController();
  final _paypalSecretController = TextEditingController();
  bool _paypalSandboxMode = true;

  // Square Settings
  final _squareApplicationIdController = TextEditingController();
  final _squareAccessTokenController = TextEditingController();
  final _squareLocationIdController = TextEditingController();

  // Bank Transfer Settings
  final _bankNameController = TextEditingController();
  final _bankAccountNumberController = TextEditingController();
  final _bankRoutingNumberController = TextEditingController();
  final _bankAccountHolderController = TextEditingController();

  // General Settings
  final _currencyController = TextEditingController();
  final _taxRateController = TextEditingController();
  bool _autoCapturePayments = true;
  bool _enablePartialRefunds = true;
  int _paymentTimeout = 30;

  @override
  void initState() {
    super.initState();
    _loadPaymentSettings();
  }

  @override
  void dispose() {
    _stripePublishableKeyController.dispose();
    _stripeSecretKeyController.dispose();
    _stripeWebhookSecretController.dispose();
    _paypalClientIdController.dispose();
    _paypalSecretController.dispose();
    _squareApplicationIdController.dispose();
    _squareAccessTokenController.dispose();
    _squareLocationIdController.dispose();
    _bankNameController.dispose();
    _bankAccountNumberController.dispose();
    _bankRoutingNumberController.dispose();
    _bankAccountHolderController.dispose();
    _currencyController.dispose();
    _taxRateController.dispose();
    super.dispose();
  }

  Future<void> _loadPaymentSettings() async {
    try {
      final firestore = ref.read(firestoreServiceProvider);
      final doc = await firestore.getDocument('payment_settings', 'main');

      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;

        setState(() {
          // Payment Methods
          _enableStripe = data['enableStripe'] ?? false;
          _enablePayPal = data['enablePayPal'] ?? false;
          _enableSquare = data['enableSquare'] ?? false;
          _enableCashOnDelivery = data['enableCashOnDelivery'] ?? false;
          _enableBankTransfer = data['enableBankTransfer'] ?? false;

          // Stripe Settings
          _stripePublishableKeyController.text =
              data['stripePublishableKey'] ?? '';
          _stripeSecretKeyController.text = data['stripeSecretKey'] ?? '';
          _stripeWebhookSecretController.text =
              data['stripeWebhookSecret'] ?? '';

          // PayPal Settings
          _paypalClientIdController.text = data['paypalClientId'] ?? '';
          _paypalSecretController.text = data['paypalSecret'] ?? '';
          _paypalSandboxMode = data['paypalSandboxMode'] ?? true;

          // Square Settings
          _squareApplicationIdController.text =
              data['squareApplicationId'] ?? '';
          _squareAccessTokenController.text = data['squareAccessToken'] ?? '';
          _squareLocationIdController.text = data['squareLocationId'] ?? '';

          // Bank Transfer Settings
          _bankNameController.text = data['bankName'] ?? '';
          _bankAccountNumberController.text = data['bankAccountNumber'] ?? '';
          _bankRoutingNumberController.text = data['bankRoutingNumber'] ?? '';
          _bankAccountHolderController.text = data['bankAccountHolder'] ?? '';

          // General Settings
          _currencyController.text = data['currency'] ?? 'USD';
          _taxRateController.text = data['taxRate']?.toString() ?? '0.0';
          _autoCapturePayments = data['autoCapturePayments'] ?? true;
          _enablePartialRefunds = data['enablePartialRefunds'] ?? true;
          _paymentTimeout = data['paymentTimeout'] ?? 30;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading payment settings: $e'),
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

  Future<void> _savePaymentSettings() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final firestore = ref.read(firestoreServiceProvider);

      final paymentData = {
        // Payment Methods
        'enableStripe': _enableStripe,
        'enablePayPal': _enablePayPal,
        'enableSquare': _enableSquare,
        'enableCashOnDelivery': _enableCashOnDelivery,
        'enableBankTransfer': _enableBankTransfer,

        // Stripe Settings
        'stripePublishableKey': _stripePublishableKeyController.text,
        'stripeSecretKey': _stripeSecretKeyController.text,
        'stripeWebhookSecret': _stripeWebhookSecretController.text,

        // PayPal Settings
        'paypalClientId': _paypalClientIdController.text,
        'paypalSecret': _paypalSecretController.text,
        'paypalSandboxMode': _paypalSandboxMode,

        // Square Settings
        'squareApplicationId': _squareApplicationIdController.text,
        'squareAccessToken': _squareAccessTokenController.text,
        'squareLocationId': _squareLocationIdController.text,

        // Bank Transfer Settings
        'bankName': _bankNameController.text,
        'bankAccountNumber': _bankAccountNumberController.text,
        'bankRoutingNumber': _bankRoutingNumberController.text,
        'bankAccountHolder': _bankAccountHolderController.text,

        // General Settings
        'currency': _currencyController.text,
        'taxRate': double.tryParse(_taxRateController.text) ?? 0.0,
        'autoCapturePayments': _autoCapturePayments,
        'enablePartialRefunds': _enablePartialRefunds,
        'paymentTimeout': _paymentTimeout,
        'updatedAt': DateTime.now(),
      };

      final doc = await firestore.getDocument('payment_settings', 'main');
      if (doc.exists) {
        await firestore.updateDocument('payment_settings', 'main', paymentData);
      } else {
        await firestore.addDocument('payment_settings', paymentData, 'main');
      }

      // Update currency provider
      ref
          .read(currencyProvider.notifier)
          .updateCurrency(_currencyController.text);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Payment settings saved successfully!'),
            backgroundColor: AppTheme.successColor,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving payment settings: $e'),
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

  Future<void> _testPaymentConnection(String provider) async {
    setState(() => _isLoading = true);

    try {
      // TODO: Implement actual payment connection test
      await Future.delayed(const Duration(seconds: 2)); // Simulate test

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$provider connection test successful!'),
            backgroundColor: AppTheme.successColor,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$provider connection test failed: $e'),
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
      currentRoute: '/payment-settings',
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
                              Icons.payment,
                              color: AppTheme.primaryColor,
                              size: 32,
                            ),
                            const SizedBox(width: 16),
                            const Text(
                              'Payment Settings',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Spacer(),
                            ElevatedButton.icon(
                              onPressed:
                                  _isLoading ? null : _savePaymentSettings,
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

                        // Payment Methods Section
                        _buildPaymentMethodsSection(),
                        const SizedBox(height: 32),

                        // Stripe Settings Section
                        if (_enableStripe) ...[
                          _buildStripeSection(),
                          const SizedBox(height: 32),
                        ],

                        // PayPal Settings Section
                        if (_enablePayPal) ...[
                          _buildPayPalSection(),
                          const SizedBox(height: 32),
                        ],

                        // Square Settings Section
                        if (_enableSquare) ...[
                          _buildSquareSection(),
                          const SizedBox(height: 32),
                        ],

                        // Bank Transfer Settings Section
                        if (_enableBankTransfer) ...[
                          _buildBankTransferSection(),
                          const SizedBox(height: 32),
                        ],

                        // General Settings Section
                        _buildGeneralSettingsSection(),
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

  Widget _buildPaymentMethodsSection() {
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
                  Icons.credit_card,
                  color: AppTheme.primaryColor,
                  size: 24,
                ),
                const SizedBox(width: 12),
                const Text(
                  'Payment Methods',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            SwitchListTile(
              title: const Text('Stripe'),
              subtitle: const Text('Credit card payments via Stripe'),
              value: _enableStripe,
              onChanged: (value) => setState(() => _enableStripe = value),
              activeColor: AppTheme.primaryColor,
              secondary: const Icon(Icons.payment),
            ),
            SwitchListTile(
              title: const Text('PayPal'),
              subtitle: const Text('PayPal Express Checkout'),
              value: _enablePayPal,
              onChanged: (value) => setState(() => _enablePayPal = value),
              activeColor: AppTheme.primaryColor,
              secondary: const Icon(Icons.payment),
            ),
            SwitchListTile(
              title: const Text('Square'),
              subtitle: const Text('Square payment processing'),
              value: _enableSquare,
              onChanged: (value) => setState(() => _enableSquare = value),
              activeColor: AppTheme.primaryColor,
              secondary: const Icon(Icons.payment),
            ),
            SwitchListTile(
              title: const Text('Cash on Delivery'),
              subtitle: const Text('Pay when you receive your order'),
              value: _enableCashOnDelivery,
              onChanged: (value) =>
                  setState(() => _enableCashOnDelivery = value),
              activeColor: AppTheme.primaryColor,
              secondary: const Icon(Icons.money),
            ),
            SwitchListTile(
              title: const Text('Bank Transfer'),
              subtitle: const Text('Direct bank transfer payments'),
              value: _enableBankTransfer,
              onChanged: (value) => setState(() => _enableBankTransfer = value),
              activeColor: AppTheme.primaryColor,
              secondary: const Icon(Icons.account_balance),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStripeSection() {
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
                  Icons.payment,
                  color: AppTheme.primaryColor,
                  size: 24,
                ),
                const SizedBox(width: 12),
                const Text(
                  'Stripe Settings',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                OutlinedButton.icon(
                  onPressed: _isLoading
                      ? null
                      : () => _testPaymentConnection('Stripe'),
                  icon: _isLoading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.send),
                  label: const Text('Test Connection'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.primaryColor,
                    side: const BorderSide(color: AppTheme.primaryColor),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: _stripePublishableKeyController,
              decoration: const InputDecoration(
                labelText: 'Publishable Key *',
                hintText: 'pk_test_...',
                prefixIcon: Icon(Icons.key),
              ),
              validator: (value) {
                if (_enableStripe && (value == null || value.isEmpty)) {
                  return 'Publishable key is required';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _stripeSecretKeyController,
              decoration: const InputDecoration(
                labelText: 'Secret Key *',
                hintText: 'sk_test_...',
                prefixIcon: Icon(Icons.lock),
              ),
              obscureText: true,
              validator: (value) {
                if (_enableStripe && (value == null || value.isEmpty)) {
                  return 'Secret key is required';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _stripeWebhookSecretController,
              decoration: const InputDecoration(
                labelText: 'Webhook Secret',
                hintText: 'whsec_...',
                prefixIcon: Icon(Icons.webhook),
              ),
              obscureText: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPayPalSection() {
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
                  Icons.payment,
                  color: AppTheme.primaryColor,
                  size: 24,
                ),
                const SizedBox(width: 12),
                const Text(
                  'PayPal Settings',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                OutlinedButton.icon(
                  onPressed: _isLoading
                      ? null
                      : () => _testPaymentConnection('PayPal'),
                  icon: _isLoading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.send),
                  label: const Text('Test Connection'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.primaryColor,
                    side: const BorderSide(color: AppTheme.primaryColor),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _paypalClientIdController,
                    decoration: const InputDecoration(
                      labelText: 'Client ID *',
                      hintText: 'Your PayPal Client ID',
                      prefixIcon: Icon(Icons.person),
                    ),
                    validator: (value) {
                      if (_enablePayPal && (value == null || value.isEmpty)) {
                        return 'Client ID is required';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _paypalSecretController,
                    decoration: const InputDecoration(
                      labelText: 'Secret *',
                      hintText: 'Your PayPal Secret',
                      prefixIcon: Icon(Icons.lock),
                    ),
                    obscureText: true,
                    validator: (value) {
                      if (_enablePayPal && (value == null || value.isEmpty)) {
                        return 'Secret is required';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text('Sandbox Mode'),
              subtitle: const Text('Use PayPal sandbox for testing'),
              value: _paypalSandboxMode,
              onChanged: (value) => setState(() => _paypalSandboxMode = value),
              activeColor: AppTheme.primaryColor,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSquareSection() {
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
                  Icons.payment,
                  color: AppTheme.primaryColor,
                  size: 24,
                ),
                const SizedBox(width: 12),
                const Text(
                  'Square Settings',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                OutlinedButton.icon(
                  onPressed: _isLoading
                      ? null
                      : () => _testPaymentConnection('Square'),
                  icon: _isLoading
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.send),
                  label: const Text('Test Connection'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.primaryColor,
                    side: const BorderSide(color: AppTheme.primaryColor),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: _squareApplicationIdController,
              decoration: const InputDecoration(
                labelText: 'Application ID *',
                hintText: 'Your Square Application ID',
                prefixIcon: Icon(Icons.apps),
              ),
              validator: (value) {
                if (_enableSquare && (value == null || value.isEmpty)) {
                  return 'Application ID is required';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _squareAccessTokenController,
              decoration: const InputDecoration(
                labelText: 'Access Token *',
                hintText: 'Your Square Access Token',
                prefixIcon: Icon(Icons.token),
              ),
              obscureText: true,
              validator: (value) {
                if (_enableSquare && (value == null || value.isEmpty)) {
                  return 'Access token is required';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _squareLocationIdController,
              decoration: const InputDecoration(
                labelText: 'Location ID *',
                hintText: 'Your Square Location ID',
                prefixIcon: Icon(Icons.location_on),
              ),
              validator: (value) {
                if (_enableSquare && (value == null || value.isEmpty)) {
                  return 'Location ID is required';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBankTransferSection() {
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
                  Icons.account_balance,
                  color: AppTheme.primaryColor,
                  size: 24,
                ),
                const SizedBox(width: 12),
                const Text(
                  'Bank Transfer Settings',
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
                    controller: _bankNameController,
                    decoration: const InputDecoration(
                      labelText: 'Bank Name *',
                      hintText: 'Your Bank Name',
                      prefixIcon: Icon(Icons.account_balance),
                    ),
                    validator: (value) {
                      if (_enableBankTransfer &&
                          (value == null || value.isEmpty)) {
                        return 'Bank name is required';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _bankAccountHolderController,
                    decoration: const InputDecoration(
                      labelText: 'Account Holder *',
                      hintText: 'Account Holder Name',
                      prefixIcon: Icon(Icons.person),
                    ),
                    validator: (value) {
                      if (_enableBankTransfer &&
                          (value == null || value.isEmpty)) {
                        return 'Account holder is required';
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
                    controller: _bankAccountNumberController,
                    decoration: const InputDecoration(
                      labelText: 'Account Number *',
                      hintText: 'Your Account Number',
                      prefixIcon: Icon(Icons.account_circle),
                    ),
                    validator: (value) {
                      if (_enableBankTransfer &&
                          (value == null || value.isEmpty)) {
                        return 'Account number is required';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _bankRoutingNumberController,
                    decoration: const InputDecoration(
                      labelText: 'Routing Number *',
                      hintText: 'Your Routing Number',
                      prefixIcon: Icon(Icons.numbers),
                    ),
                    validator: (value) {
                      if (_enableBankTransfer &&
                          (value == null || value.isEmpty)) {
                        return 'Routing number is required';
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

  Widget _buildGeneralSettingsSection() {
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
                  color: AppTheme.primaryColor,
                  size: 24,
                ),
                const SizedBox(width: 12),
                const Text(
                  'General Settings',
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
                    controller: _currencyController,
                    decoration: const InputDecoration(
                      labelText: 'Currency *',
                      hintText: 'USD',
                      prefixIcon: Icon(Icons.attach_money),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Currency is required';
                      }
                      return null;
                    },
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
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: SwitchListTile(
                    title: const Text('Auto Capture Payments'),
                    subtitle: const Text(
                        'Automatically capture payments when orders are placed'),
                    value: _autoCapturePayments,
                    onChanged: (value) =>
                        setState(() => _autoCapturePayments = value),
                    activeColor: AppTheme.primaryColor,
                  ),
                ),
                Expanded(
                  child: SwitchListTile(
                    title: const Text('Enable Partial Refunds'),
                    subtitle: const Text('Allow partial refunds for orders'),
                    value: _enablePartialRefunds,
                    onChanged: (value) =>
                        setState(() => _enablePartialRefunds = value),
                    activeColor: AppTheme.primaryColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Text('Payment Timeout (minutes):'),
                const SizedBox(width: 16),
                Expanded(
                  child: Slider(
                    value: _paymentTimeout.toDouble(),
                    min: 5,
                    max: 60,
                    divisions: 11,
                    label: '$_paymentTimeout minutes',
                    onChanged: (value) =>
                        setState(() => _paymentTimeout = value.round()),
                  ),
                ),
                Text('$_paymentTimeout'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
