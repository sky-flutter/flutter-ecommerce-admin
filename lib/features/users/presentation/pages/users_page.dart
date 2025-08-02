import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/models/user_model.dart';
import '../providers/user_provider.dart';
import '../../../../features/auth/presentation/providers/custom_auth_provider.dart';
import '../../../../shared/widgets/search_bar.dart' as custom;
import '../../../../shared/widgets/custom_data_table.dart';
import '../pages/edit_user_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../shared/widgets/enhanced_layout_wrapper.dart';

class UsersPage extends ConsumerStatefulWidget {
  const UsersPage({super.key});

  @override
  ConsumerState<UsersPage> createState() => _UsersPageState();
}

class _UsersPageState extends ConsumerState<UsersPage> {
  String _searchQuery = '';
  List<UserModel> _filteredUsers = [];

  @override
  Widget build(BuildContext context) {
    final usersAsync = ref.watch(usersStreamProvider);
    final currentUser = ref.watch(customAuthStateProvider).value;
    final userRoleAsync = currentUser != null
        ? ref.watch(customUserRoleProvider(currentUser.id))
        : null;

    return EnhancedLayoutWrapper(
      currentRoute: '/users',
      child: usersAsync.when(
        data: (usersSnapshot) {
          final users = usersSnapshot.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return UserModel.fromMap(data, doc.id);
          }).toList();

          // Filter users based on search query
          _filteredUsers = users.where((user) {
            return user.email
                    .toLowerCase()
                    .contains(_searchQuery.toLowerCase()) ||
                user.displayName
                    .toLowerCase()
                    .contains(_searchQuery.toLowerCase()) ||
                user.role.toLowerCase().contains(_searchQuery.toLowerCase());
          }).toList();

          return Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: custom.SearchBar(
                      hintText: 'Search users...',
                      onChanged: (query) =>
                          setState(() => _searchQuery = query),
                    ),
                  ),
                  if (userRoleAsync?.value == 'admin' ||
                      userRoleAsync?.value == 'editor')
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: () => context.push('/users/add'),
                    ),
                ],
              ),
              Expanded(
                child: _buildUsersTable(),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }

  Widget _buildUsersTable() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: const [
          DataColumn(label: Text('Name')),
          DataColumn(label: Text('Email')),
          DataColumn(label: Text('Role')),
          DataColumn(label: Text('Created')),
          DataColumn(label: Text('Actions')),
        ],
        rows: _filteredUsers
            .map((user) => DataRow(
                  cells: [
                    DataCell(Text(user.displayName)),
                    DataCell(Text(user.email)),
                    DataCell(
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _getRoleColor(user.role),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          user.role.toUpperCase(),
                          style: const TextStyle(
                              color: Colors.white, fontSize: 12),
                        ),
                      ),
                    ),
                    DataCell(Text(_formatDate(user.createdAt))),
                    DataCell(
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, size: 20),
                            onPressed: () => _editUser(user),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete,
                                size: 20, color: Colors.red),
                            onPressed: () => _deleteUser(user),
                          ),
                        ],
                      ),
                    ),
                  ],
                ))
            .toList(),
      ),
    );
  }

  Color _getRoleColor(String role) {
    switch (role) {
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

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _editUser(UserModel user) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditUserPage(user: user),
      ),
    );
  }

  void _deleteUser(UserModel user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete User'),
        content: Text('Are you sure you want to delete ${user.displayName}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _confirmDeleteUser(user);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDeleteUser(UserModel user) async {
    try {
      final firestore = ref.read(firestoreServiceProvider);
      await firestore.deleteDocument('users', user.id);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('User ${user.displayName} deleted successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting user: $e')),
        );
      }
    }
  }
}
