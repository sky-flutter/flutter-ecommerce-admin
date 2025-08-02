import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/widgets/enhanced_layout_wrapper.dart';
import '../../../../features/auth/presentation/providers/custom_auth_provider.dart';
import '../../../../shared/services/theme_provider.dart';
import '../../../../shared/models/user_model.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _displayNameController;
  late TextEditingController _emailController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _displayNameController = TextEditingController();
    _emailController = TextEditingController();
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.watch(customAuthStateProvider).value;
    final userRoleAsync = currentUser != null
        ? ref.watch(customUserRoleProvider(currentUser.id))
        : null;

    return EnhancedLayoutWrapper(
      currentRoute: '/settings',
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Section
            _buildSectionCard(
              title: 'Profile Settings',
              icon: Icons.person,
              child: _buildProfileSection(currentUser),
            ),
            const SizedBox(height: 24),

            // Theme Section
            _buildSectionCard(
              title: 'Appearance',
              icon: Icons.palette,
              child: _buildThemeSection(),
            ),
            const SizedBox(height: 24),

            // Language Section
            _buildSectionCard(
              title: 'Language & Region',
              icon: Icons.language,
              child: _buildLanguageSection(),
            ),
            const SizedBox(height: 24),

            // Firebase Config Section (Admin Only)
            if (userRoleAsync?.value == 'admin')
              _buildSectionCard(
                title: 'Firebase Configuration',
                icon: Icons.settings,
                child: _buildFirebaseConfigSection(),
              ),
            if (userRoleAsync?.value == 'admin') const SizedBox(height: 24),

            // Account Actions Section
            _buildSectionCard(
              title: 'Account Actions',
              icon: Icons.security,
              child: _buildAccountActionsSection(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.blue),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }

  Widget _buildProfileSection(UserModel? currentUser) {
    if (currentUser == null) {
      return const Text('User not authenticated');
    }

    // Update controllers with current values
    _displayNameController.text = currentUser.displayName;
    _emailController.text = currentUser.email;

    return Form(
      key: _formKey,
      child: Column(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: Colors.blue,
            child: Text(
              currentUser.displayName[0].toUpperCase(),
              style: const TextStyle(
                fontSize: 24,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _displayNameController,
            decoration: const InputDecoration(
              labelText: 'Display Name',
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter display name';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _emailController,
            decoration: const InputDecoration(
              labelText: 'Email',
              border: OutlineInputBorder(),
            ),
            enabled: false, // Email cannot be changed
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Chip(
                label: Text(currentUser.role.toUpperCase()),
                backgroundColor: _getRoleColor(currentUser.role),
                labelStyle: const TextStyle(color: Colors.white),
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: _isLoading ? null : _updateProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 16,
                        width: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Update Profile'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildThemeSection() {
    final themeMode = ref.watch(themeProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Choose your preferred theme:',
          style: TextStyle(fontSize: 16),
        ),
        const SizedBox(height: 16),
        ListTile(
          leading: const Icon(Icons.light_mode),
          title: const Text('Light Theme'),
          trailing: Radio<ThemeMode>(
            value: ThemeMode.light,
            groupValue: themeMode,
            onChanged: (value) {
              ref.read(themeProvider.notifier).toggleTheme();
            },
          ),
        ),
        ListTile(
          leading: const Icon(Icons.dark_mode),
          title: const Text('Dark Theme'),
          trailing: Radio<ThemeMode>(
            value: ThemeMode.dark,
            groupValue: themeMode,
            onChanged: (value) {
              ref.read(themeProvider.notifier).toggleTheme();
            },
          ),
        ),
        ListTile(
          leading: const Icon(Icons.brightness_auto),
          title: const Text('System Default'),
          trailing: Radio<ThemeMode>(
            value: ThemeMode.system,
            groupValue: themeMode,
            onChanged: (value) {
              ref.read(themeProvider.notifier).toggleTheme();
            },
          ),
        ),
      ],
    );
  }

  Widget _buildLanguageSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Select your preferred language:',
          style: TextStyle(fontSize: 16),
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          value: 'en',
          decoration: const InputDecoration(
            labelText: 'Language',
            border: OutlineInputBorder(),
          ),
          items: const [
            DropdownMenuItem(value: 'en', child: Text('English')),
            DropdownMenuItem(value: 'es', child: Text('Español')),
            DropdownMenuItem(value: 'fr', child: Text('Français')),
            DropdownMenuItem(value: 'de', child: Text('Deutsch')),
          ],
          onChanged: (value) {
            // TODO: Implement language change
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Language changed to $value')),
            );
          },
        ),
        const SizedBox(height: 16),
        const Text(
          'Note: Language changes will be applied after app restart.',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey,
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }

  Widget _buildFirebaseConfigSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Firebase Configuration Overview:',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        _buildConfigItem('Authentication', 'Enabled', Icons.verified_user),
        _buildConfigItem('Firestore Database', 'Enabled', Icons.storage),
        _buildConfigItem('Storage', 'Enabled', Icons.folder),
        _buildConfigItem('Hosting', 'Enabled', Icons.web),
        const SizedBox(height: 16),
        const Text(
          'Configuration details are read-only for security reasons.',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey,
            fontStyle: FontStyle.italic,
          ),
        ),
      ],
    );
  }

  Widget _buildConfigItem(String title, String status, IconData icon) {
    return ListTile(
      leading: Icon(icon, color: Colors.green),
      title: Text(title),
      trailing: Chip(
        label: Text(status),
        backgroundColor: Colors.green,
        labelStyle: const TextStyle(color: Colors.white),
      ),
    );
  }

  Widget _buildAccountActionsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Account Management:',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        ListTile(
          leading: const Icon(Icons.password, color: Colors.orange),
          title: const Text('Change Password'),
          subtitle: const Text('Update your account password'),
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text('Password change feature coming soon')),
            );
          },
        ),
        ListTile(
          leading: const Icon(Icons.notifications, color: Colors.blue),
          title: const Text('Notification Settings'),
          subtitle: const Text('Manage your notification preferences'),
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text('Notification settings coming soon')),
            );
          },
        ),
        ListTile(
          leading: const Icon(Icons.delete_forever, color: Colors.red),
          title: const Text('Delete Account'),
          subtitle: const Text('Permanently delete your account'),
          onTap: () {
            _showDeleteAccountDialog();
          },
        ),
      ],
    );
  }

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final currentUser = ref.read(customAuthStateProvider).value;
      if (currentUser == null) return;

      final authService = ref.read(customAuthServiceProvider);

      await authService.updateUserProfile(currentUser.id, {
        'displayName': _displayNameController.text.trim(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating profile: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Account'),
        content: const Text(
          'Are you sure you want to delete your account? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Account deletion feature coming soon')),
              );
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
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
