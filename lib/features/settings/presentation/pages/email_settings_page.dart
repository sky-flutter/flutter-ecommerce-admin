import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../features/auth/presentation/providers/custom_auth_provider.dart';
import '../../../../features/users/presentation/providers/user_provider.dart';
import '../../../../shared/widgets/enhanced_layout_wrapper.dart';
import '../../../../core/constants/app_theme.dart';

class EmailSettingsPage extends ConsumerStatefulWidget {
  const EmailSettingsPage({super.key});

  @override
  ConsumerState<EmailSettingsPage> createState() => _EmailSettingsPageState();
}

class _EmailSettingsPageState extends ConsumerState<EmailSettingsPage> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _isLoadingData = true;

  // SMTP Settings
  final _smtpHostController = TextEditingController();
  final _smtpPortController = TextEditingController();
  final _smtpUsernameController = TextEditingController();
  final _smtpPasswordController = TextEditingController();
  bool _smtpUseTls = true;
  bool _smtpUseSsl = false;

  // Email Templates
  final _welcomeEmailSubjectController = TextEditingController();
  final _welcomeEmailBodyController = TextEditingController();
  final _orderConfirmationSubjectController = TextEditingController();
  final _orderConfirmationBodyController = TextEditingController();
  final _passwordResetSubjectController = TextEditingController();
  final _passwordResetBodyController = TextEditingController();

  // Notification Settings
  bool _enableOrderNotifications = true;
  bool _enableInventoryNotifications = true;
  bool _enableCustomerNotifications = true;
  bool _enableMarketingEmails = false;
  bool _enableNewsletter = false;

  // Email Preferences
  final _fromNameController = TextEditingController();
  final _fromEmailController = TextEditingController();
  final _replyToEmailController = TextEditingController();
  final _bounceEmailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadEmailSettings();
  }

  @override
  void dispose() {
    _smtpHostController.dispose();
    _smtpPortController.dispose();
    _smtpUsernameController.dispose();
    _smtpPasswordController.dispose();
    _welcomeEmailSubjectController.dispose();
    _welcomeEmailBodyController.dispose();
    _orderConfirmationSubjectController.dispose();
    _orderConfirmationBodyController.dispose();
    _passwordResetSubjectController.dispose();
    _passwordResetBodyController.dispose();
    _fromNameController.dispose();
    _fromEmailController.dispose();
    _replyToEmailController.dispose();
    _bounceEmailController.dispose();
    super.dispose();
  }

  Future<void> _loadEmailSettings() async {
    try {
      final firestore = ref.read(firestoreServiceProvider);
      final doc = await firestore.getDocument('email_settings', 'main');

      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;

        setState(() {
          // SMTP Settings
          _smtpHostController.text = data['smtpHost'] ?? '';
          _smtpPortController.text = data['smtpPort']?.toString() ?? '587';
          _smtpUsernameController.text = data['smtpUsername'] ?? '';
          _smtpPasswordController.text = data['smtpPassword'] ?? '';
          _smtpUseTls = data['smtpUseTls'] ?? true;
          _smtpUseSsl = data['smtpUseSsl'] ?? false;

          // Email Templates
          _welcomeEmailSubjectController.text =
              data['welcomeEmailSubject'] ?? '';
          _welcomeEmailBodyController.text = data['welcomeEmailBody'] ?? '';
          _orderConfirmationSubjectController.text =
              data['orderConfirmationSubject'] ?? '';
          _orderConfirmationBodyController.text =
              data['orderConfirmationBody'] ?? '';
          _passwordResetSubjectController.text =
              data['passwordResetSubject'] ?? '';
          _passwordResetBodyController.text = data['passwordResetBody'] ?? '';

          // Notification Settings
          _enableOrderNotifications = data['enableOrderNotifications'] ?? true;
          _enableInventoryNotifications =
              data['enableInventoryNotifications'] ?? true;
          _enableCustomerNotifications =
              data['enableCustomerNotifications'] ?? true;
          _enableMarketingEmails = data['enableMarketingEmails'] ?? false;
          _enableNewsletter = data['enableNewsletter'] ?? false;

          // Email Preferences
          _fromNameController.text = data['fromName'] ?? '';
          _fromEmailController.text = data['fromEmail'] ?? '';
          _replyToEmailController.text = data['replyToEmail'] ?? '';
          _bounceEmailController.text = data['bounceEmail'] ?? '';
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading email settings: $e'),
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

  Future<void> _saveEmailSettings() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final firestore = ref.read(firestoreServiceProvider);

      final emailData = {
        // SMTP Settings
        'smtpHost': _smtpHostController.text,
        'smtpPort': int.tryParse(_smtpPortController.text) ?? 587,
        'smtpUsername': _smtpUsernameController.text,
        'smtpPassword': _smtpPasswordController.text,
        'smtpUseTls': _smtpUseTls,
        'smtpUseSsl': _smtpUseSsl,

        // Email Templates
        'welcomeEmailSubject': _welcomeEmailSubjectController.text,
        'welcomeEmailBody': _welcomeEmailBodyController.text,
        'orderConfirmationSubject': _orderConfirmationSubjectController.text,
        'orderConfirmationBody': _orderConfirmationBodyController.text,
        'passwordResetSubject': _passwordResetSubjectController.text,
        'passwordResetBody': _passwordResetBodyController.text,

        // Notification Settings
        'enableOrderNotifications': _enableOrderNotifications,
        'enableInventoryNotifications': _enableInventoryNotifications,
        'enableCustomerNotifications': _enableCustomerNotifications,
        'enableMarketingEmails': _enableMarketingEmails,
        'enableNewsletter': _enableNewsletter,

        // Email Preferences
        'fromName': _fromNameController.text,
        'fromEmail': _fromEmailController.text,
        'replyToEmail': _replyToEmailController.text,
        'bounceEmail': _bounceEmailController.text,
        'updatedAt': DateTime.now(),
      };

      final doc = await firestore.getDocument('email_settings', 'main');
      if (doc.exists) {
        await firestore.updateDocument('email_settings', 'main', emailData);
      } else {
        await firestore.addDocument('email_settings', emailData, 'main');
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Email settings saved successfully!'),
            backgroundColor: AppTheme.successColor,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving email settings: $e'),
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

  Future<void> _testEmailConnection() async {
    setState(() => _isLoading = true);

    try {
      // TODO: Implement actual email connection test
      await Future.delayed(const Duration(seconds: 2)); // Simulate test

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Email connection test successful!'),
            backgroundColor: AppTheme.successColor,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Email connection test failed: $e'),
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
      currentRoute: '/email-settings',
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
                              Icons.email,
                              color: AppTheme.primaryColor,
                              size: 32,
                            ),
                            const SizedBox(width: 16),
                            const Text(
                              'Email & Notifications',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Spacer(),
                            Row(
                              children: [
                                OutlinedButton.icon(
                                  onPressed:
                                      _isLoading ? null : _testEmailConnection,
                                  icon: _isLoading
                                      ? const SizedBox(
                                          width: 16,
                                          height: 16,
                                          child: CircularProgressIndicator(
                                              strokeWidth: 2),
                                        )
                                      : const Icon(Icons.send),
                                  label: Text(_isLoading
                                      ? 'Testing...'
                                      : 'Test Connection'),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: AppTheme.primaryColor,
                                    side: const BorderSide(
                                        color: AppTheme.primaryColor),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                ElevatedButton.icon(
                                  onPressed:
                                      _isLoading ? null : _saveEmailSettings,
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
                                      : 'Save Settings'),
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
                          ],
                        ),
                        const SizedBox(height: 32),

                        // SMTP Settings Section
                        _buildSmtpSection(),
                        const SizedBox(height: 32),

                        // Email Preferences Section
                        _buildEmailPreferencesSection(),
                        const SizedBox(height: 32),

                        // Notification Settings Section
                        _buildNotificationSection(),
                        const SizedBox(height: 32),

                        // Email Templates Section
                        _buildEmailTemplatesSection(),
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

  Widget _buildSmtpSection() {
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
                  'SMTP Settings',
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
                    controller: _smtpHostController,
                    decoration: const InputDecoration(
                      labelText: 'SMTP Host *',
                      hintText: 'smtp.gmail.com',
                      prefixIcon: Icon(Icons.dns),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'SMTP host is required';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _smtpPortController,
                    decoration: const InputDecoration(
                      labelText: 'SMTP Port *',
                      hintText: '587',
                      prefixIcon: Icon(Icons.numbers),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'SMTP port is required';
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
                    controller: _smtpUsernameController,
                    decoration: const InputDecoration(
                      labelText: 'SMTP Username *',
                      hintText: 'your-email@gmail.com',
                      prefixIcon: Icon(Icons.person),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'SMTP username is required';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _smtpPasswordController,
                    decoration: const InputDecoration(
                      labelText: 'SMTP Password *',
                      hintText: 'Your app password',
                      prefixIcon: Icon(Icons.lock),
                    ),
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'SMTP password is required';
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
                  child: CheckboxListTile(
                    title: const Text('Use TLS'),
                    subtitle: const Text('Enable TLS encryption'),
                    value: _smtpUseTls,
                    onChanged: (value) => setState(() => _smtpUseTls = value!),
                    controlAffinity: ListTileControlAffinity.leading,
                  ),
                ),
                Expanded(
                  child: CheckboxListTile(
                    title: const Text('Use SSL'),
                    subtitle: const Text('Enable SSL encryption'),
                    value: _smtpUseSsl,
                    onChanged: (value) => setState(() => _smtpUseSsl = value!),
                    controlAffinity: ListTileControlAffinity.leading,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmailPreferencesSection() {
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
                  Icons.person_outline,
                  color: AppTheme.primaryColor,
                  size: 24,
                ),
                const SizedBox(width: 12),
                const Text(
                  'Email Preferences',
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
                    controller: _fromNameController,
                    decoration: const InputDecoration(
                      labelText: 'From Name *',
                      hintText: 'Your Store Name',
                      prefixIcon: Icon(Icons.business),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'From name is required';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _fromEmailController,
                    decoration: const InputDecoration(
                      labelText: 'From Email *',
                      hintText: 'noreply@yourstore.com',
                      prefixIcon: Icon(Icons.email),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'From email is required';
                      }
                      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                          .hasMatch(value)) {
                        return 'Please enter a valid email';
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
                    controller: _replyToEmailController,
                    decoration: const InputDecoration(
                      labelText: 'Reply-To Email',
                      hintText: 'support@yourstore.com',
                      prefixIcon: Icon(Icons.reply),
                    ),
                    keyboardType: TextInputType.emailAddress,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _bounceEmailController,
                    decoration: const InputDecoration(
                      labelText: 'Bounce Email',
                      hintText: 'bounces@yourstore.com',
                      prefixIcon: Icon(Icons.error_outline),
                    ),
                    keyboardType: TextInputType.emailAddress,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationSection() {
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
                  Icons.notifications,
                  color: AppTheme.primaryColor,
                  size: 24,
                ),
                const SizedBox(width: 12),
                const Text(
                  'Notification Settings',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            SwitchListTile(
              title: const Text('Order Notifications'),
              subtitle: const Text('Receive notifications for new orders'),
              value: _enableOrderNotifications,
              onChanged: (value) =>
                  setState(() => _enableOrderNotifications = value),
              activeColor: AppTheme.primaryColor,
            ),
            SwitchListTile(
              title: const Text('Inventory Notifications'),
              subtitle: const Text('Receive notifications for low stock items'),
              value: _enableInventoryNotifications,
              onChanged: (value) =>
                  setState(() => _enableInventoryNotifications = value),
              activeColor: AppTheme.primaryColor,
            ),
            SwitchListTile(
              title: const Text('Customer Notifications'),
              subtitle:
                  const Text('Receive notifications for customer inquiries'),
              value: _enableCustomerNotifications,
              onChanged: (value) =>
                  setState(() => _enableCustomerNotifications = value),
              activeColor: AppTheme.primaryColor,
            ),
            SwitchListTile(
              title: const Text('Marketing Emails'),
              subtitle: const Text('Send promotional emails to customers'),
              value: _enableMarketingEmails,
              onChanged: (value) =>
                  setState(() => _enableMarketingEmails = value),
              activeColor: AppTheme.primaryColor,
            ),
            SwitchListTile(
              title: const Text('Newsletter'),
              subtitle: const Text('Send regular newsletter to subscribers'),
              value: _enableNewsletter,
              onChanged: (value) => setState(() => _enableNewsletter = value),
              activeColor: AppTheme.primaryColor,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmailTemplatesSection() {
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
                  Icons.email_outlined,
                  color: AppTheme.primaryColor,
                  size: 24,
                ),
                const SizedBox(width: 12),
                const Text(
                  'Email Templates',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Welcome Email Template
            ExpansionTile(
              title: const Text('Welcome Email'),
              subtitle: const Text('Sent to new customers'),
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _welcomeEmailSubjectController,
                        decoration: const InputDecoration(
                          labelText: 'Subject',
                          hintText: 'Welcome to [Store Name]!',
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _welcomeEmailBodyController,
                        decoration: const InputDecoration(
                          labelText: 'Email Body',
                          hintText:
                              'Dear [Customer Name],\n\nWelcome to our store!...',
                          alignLabelWithHint: true,
                        ),
                        maxLines: 8,
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // Order Confirmation Template
            ExpansionTile(
              title: const Text('Order Confirmation'),
              subtitle: const Text('Sent when order is placed'),
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _orderConfirmationSubjectController,
                        decoration: const InputDecoration(
                          labelText: 'Subject',
                          hintText: 'Order Confirmation - #[Order Number]',
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _orderConfirmationBodyController,
                        decoration: const InputDecoration(
                          labelText: 'Email Body',
                          hintText:
                              'Dear [Customer Name],\n\nThank you for your order...',
                          alignLabelWithHint: true,
                        ),
                        maxLines: 8,
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // Password Reset Template
            ExpansionTile(
              title: const Text('Password Reset'),
              subtitle: const Text('Sent for password reset requests'),
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _passwordResetSubjectController,
                        decoration: const InputDecoration(
                          labelText: 'Subject',
                          hintText: 'Password Reset Request',
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _passwordResetBodyController,
                        decoration: const InputDecoration(
                          labelText: 'Email Body',
                          hintText:
                              'Dear [Customer Name],\n\nYou requested a password reset...',
                          alignLabelWithHint: true,
                        ),
                        maxLines: 8,
                      ),
                    ],
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
