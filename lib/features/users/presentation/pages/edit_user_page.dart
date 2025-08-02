import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/models/user_model.dart';
import '../../../../features/auth/presentation/providers/custom_auth_provider.dart';

class EditUserPage extends ConsumerStatefulWidget {
  final UserModel user;
  const EditUserPage({super.key, required this.user});

  @override
  ConsumerState<EditUserPage> createState() => _EditUserPageState();
}

class _EditUserPageState extends ConsumerState<EditUserPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _displayNameController;
  late String _selectedRole;
  bool _isLoading = false;

  final List<String> _roles = ['admin', 'editor', 'viewer'];

  @override
  void initState() {
    super.initState();
    _displayNameController =
        TextEditingController(text: widget.user.displayName);
    _selectedRole = widget.user.role;
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    super.dispose();
  }

  Future<void> _updateUser() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final authService = ref.read(customAuthServiceProvider);

      // Update user data using custom auth service
      final userData = {
        'displayName': _displayNameController.text.trim(),
        'role': _selectedRole,
        'updatedAt': DateTime.now(),
      };

      await authService.updateUserProfile(widget.user.id, userData);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('User updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating user: ${e.toString()}'),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit User: ${widget.user.displayName}'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _displayNameController,
                decoration: const InputDecoration(
                  labelText: 'Display Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a display name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedRole,
                decoration: const InputDecoration(
                  labelText: 'Role',
                  border: OutlineInputBorder(),
                ),
                items: _roles
                    .map((role) => DropdownMenuItem(
                          value: role,
                          child: Text(role.toUpperCase()),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() => _selectedRole = value!);
                },
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _isLoading ? null : _updateUser,
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : const Text('Update User'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
