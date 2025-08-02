import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/auth/presentation/providers/custom_auth_provider.dart';
import '../../core/infrastructure/firebase/role_service.dart';

class SidebarMenu extends ConsumerWidget {
  final Function(String) onNavigate;
  const SidebarMenu({super.key, required this.onNavigate});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(customAuthStateProvider).value;
    final userRoleAsync = currentUser != null
        ? ref.watch(customUserRoleProvider(currentUser.id))
        : null;

    return LayoutBuilder(
      builder: (context, constraints) {
        final items = _getMenuItems(userRoleAsync?.value);

        if (constraints.maxWidth < 800) {
          // Drawer for mobile
          return Drawer(
            child: Column(
              children: [
                // User info header
                if (currentUser != null) ...[
                  UserAccountsDrawerHeader(
                    accountName: Text(currentUser.displayName),
                    accountEmail: Text(currentUser.email),
                    currentAccountPicture: CircleAvatar(
                      backgroundColor: Colors.white,
                      child: Text(
                        currentUser.displayName[0].toUpperCase(),
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ],
                // Menu items
                Expanded(
                  child: ListView(
                    children: items
                        .map((item) => ListTile(
                              leading: Icon(item.icon, color: item.iconColor),
                              title: Text(
                                item.title,
                                style: TextStyle(
                                  fontWeight: item.isActive
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  color: item.isActive
                                      ? Theme.of(context).primaryColor
                                      : null,
                                ),
                              ),
                              onTap: () {
                                item.setActive(true);
                                onNavigate(item.route);
                              },
                              selected: item.isActive,
                            ))
                        .toList(),
                  ),
                ),
                // Role indicator
                if (userRoleAsync?.value != null)
                  Container(
                    padding: const EdgeInsets.all(16),
                    child: Chip(
                      label: Text(
                        userRoleAsync!.value!.toUpperCase(),
                        style: const TextStyle(color: Colors.white),
                      ),
                      backgroundColor: _getRoleColor(userRoleAsync.value!),
                    ),
                  ),
              ],
            ),
          );
        } else {
          // Permanent sidebar for web/tablet
          return Container(
            width: 250,
            color: Theme.of(context).cardColor,
            child: Column(
              children: [
                // User info header
                if (currentUser != null) ...[
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color:
                          Theme.of(context).primaryColor.withValues(alpha: 0.1),
                      border: Border(
                        bottom: BorderSide(
                          color: Colors.grey.withValues(alpha: 0.2),
                          width: 1,
                        ),
                      ),
                    ),
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundColor: Theme.of(context).primaryColor,
                          child: Text(
                            currentUser.displayName[0].toUpperCase(),
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          currentUser.displayName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        Text(
                          currentUser.email,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        if (userRoleAsync?.value != null)
                          Chip(
                            label: Text(
                              userRoleAsync!.value!.toUpperCase(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            backgroundColor:
                                _getRoleColor(userRoleAsync.value!),
                          ),
                      ],
                    ),
                  ),
                ],
                // Menu items
                Expanded(
                  child: ListView(
                    children: items
                        .map((item) => ListTile(
                              leading: Icon(item.icon, color: item.iconColor),
                              title: Text(
                                item.title,
                                style: TextStyle(
                                  fontWeight: item.isActive
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  color: item.isActive
                                      ? Theme.of(context).primaryColor
                                      : null,
                                ),
                              ),
                              onTap: () {
                                item.setActive(true);
                                onNavigate(item.route);
                              },
                              selected: item.isActive,
                            ))
                        .toList(),
                  ),
                ),
              ],
            ),
          );
        }
      },
    );
  }

  List<_SidebarItem> _getMenuItems(String? userRole) {
    final items = <_SidebarItem>[];

    // Dashboard - All roles
    items.add(_SidebarItem('Dashboard', Icons.dashboard, '/'));

    // Admin only items
    if (userRole == 'admin') {
      items.add(_SidebarItem('User Management', Icons.people, '/users'));
    }

    // Admin and Editor items
    if (userRole == 'admin' || userRole == 'editor') {
      items.add(_SidebarItem('Products', Icons.shopping_bag, '/products'));
      items.add(_SidebarItem('Categories', Icons.category, '/categories'));
      // items.add(_SidebarItem('Inventory', Icons.inventory, '/inventory'));
    }

    // All roles can view orders
    items.add(_SidebarItem('Orders', Icons.receipt_long, '/orders'));

    // Analytics - Admin and Editor
    // if (userRole == 'admin' || userRole == 'editor') {
    //   items.add(_SidebarItem('Analytics', Icons.analytics, '/analytics'));
    // }

    // Reports - Admin only
    // if (userRole == 'admin') {
    //   items.add(_SidebarItem('Reports', Icons.assessment, '/reports'));
    // }

    // Settings - All roles (but different access levels)

    items.add(_SidebarItem('Settings', Icons.settings, '/settings'));

    return items;
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

class _SidebarItem {
  final String title;
  final IconData icon;
  final String route;
  final Color? iconColor;
  bool isActive;

  _SidebarItem(
    this.title,
    this.icon,
    this.route, {
    this.iconColor,
    this.isActive = false,
  });

  void setActive(bool value) {
    isActive = value;
  }
}
