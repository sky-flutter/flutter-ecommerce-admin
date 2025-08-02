import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/auth/presentation/providers/custom_auth_provider.dart';
import '../../core/config/menu_config.dart';
import '../../core/constants/app_theme.dart';
import '../../core/infrastructure/firebase/logout_service.dart';
import '../../shared/models/user_model.dart';

/// Enhanced sidebar menu widget with responsive design
class EnhancedSidebarMenu extends ConsumerWidget {
  /// Callback function for navigation
  final Function(String) onNavigate;

  /// The current route for highlighting active menu items
  final String currentRoute;

  /// Optional callback for logout functionality
  final VoidCallback? onLogout;

  const EnhancedSidebarMenu({
    super.key,
    required this.onNavigate,
    required this.currentRoute,
    this.onLogout,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(customAuthStateProvider).value;
    final userRoleAsync = currentUser != null
        ? ref.watch(customUserRoleProvider(currentUser.id))
        : null;

    return LayoutBuilder(
      builder: (context, constraints) {
        final menuConfig = _getMenuConfiguration(userRoleAsync?.value);

        if (constraints.maxWidth < 800) {
          return _buildMobileDrawer(
              context, ref, currentUser, userRoleAsync, menuConfig);
        } else {
          return _buildDesktopSidebar(
              context, ref, currentUser, userRoleAsync, menuConfig);
        }
      },
    );
  }

  /// Builds the mobile drawer
  Widget _buildMobileDrawer(
    BuildContext context,
    WidgetRef ref,
    UserModel? currentUser,
    AsyncValue<String>? userRoleAsync,
    List<MenuGroup> menuConfig,
  ) {
    return Drawer(
      child: Column(
        children: [
          if (currentUser != null) _buildUserHeader(currentUser, userRoleAsync),
          Expanded(
            child: ListView(
              children: _buildMenuItems(context, menuConfig, true),
            ),
          ),
          if (userRoleAsync?.value != null)
            _buildRoleIndicator(userRoleAsync!.value!),
          _buildLogoutButton(context, ref),
        ],
      ),
    );
  }

  /// Builds the desktop sidebar
  Widget _buildDesktopSidebar(
    BuildContext context,
    WidgetRef ref,
    UserModel? currentUser,
    AsyncValue<String>? userRoleAsync,
    List<MenuGroup> menuConfig,
  ) {
    return Container(
      width: 280,
      color: Theme.of(context).cardColor,
      child: Column(
        children: [
          if (currentUser != null) _buildUserHeader(currentUser, userRoleAsync),
          Expanded(
            child: ListView(
              children: _buildMenuItems(context, menuConfig, false),
            ),
          ),
          _buildLogoutButton(context, ref),
        ],
      ),
    );
  }

  /// Builds the user header section
  Widget _buildUserHeader(
    UserModel currentUser,
    AsyncValue<String>? userRoleAsync,
  ) {
    return UserAccountsDrawerHeader(
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
        color: AppTheme.primaryColor,
      ),
    );
  }

  /// Builds the role indicator chip
  Widget _buildRoleIndicator(String role) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Chip(
        label: Text(
          role.toUpperCase(),
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: _getRoleColor(role),
      ),
    );
  }

  /// Builds the logout button
  Widget _buildLogoutButton(BuildContext context, WidgetRef ref) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: ListTile(
        leading: const Icon(Icons.logout, color: Colors.red),
        title: const Text(
          'Logout',
          style: TextStyle(color: Colors.red),
        ),
        onTap: () => _handleLogout(context, ref),
      ),
    );
  }

  /// Builds menu items for the sidebar
  List<Widget> _buildMenuItems(
    BuildContext context,
    List<MenuGroup> menuConfig,
    bool isMobile,
  ) {
    final widgets = <Widget>[];

    for (final group in menuConfig) {
      if (!isMobile) {
        widgets.add(_buildGroupHeader(group.title));
      }

      for (final item in group.items) {
        widgets.add(_buildMenuItem(context, item));
      }

      if (group != menuConfig.last && !isMobile) {
        widgets.add(_buildGroupDivider());
      }
    }

    return widgets;
  }

  /// Builds a group header
  Widget _buildGroupHeader(String title) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: AppTheme.neutral600,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  /// Builds a menu item
  Widget _buildMenuItem(BuildContext context, MenuItem item) {
    final isActive = currentRoute == item.route;

    return ListTile(
      leading: Icon(
        item.icon,
        color: isActive
            ? AppTheme.primaryColor
            : item.iconColor ?? AppTheme.neutral600,
      ),
      title: Text(
        item.title,
        style: TextStyle(
          fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          color: isActive ? AppTheme.primaryColor : null,
        ),
      ),
      onTap: () => onNavigate(item.route),
      selected: isActive,
      selectedTileColor: AppTheme.primaryColor.withValues(alpha: 0.1),
    );
  }

  /// Builds a group divider
  Widget _buildGroupDivider() {
    return Divider(
      height: 1,
      color: AppTheme.neutral200,
      indent: 16,
      endIndent: 16,
    );
  }

  /// Gets the menu configuration based on user role
  List<MenuGroup> _getMenuConfiguration(String? userRole) {
    final configGroups = MenuConfig.getMenuForRole(userRole);
    final groups = <MenuGroup>[];

    for (final configGroup in configGroups) {
      final items = configGroup.items
          .map((configItem) => MenuItem(
                configItem.title,
                configItem.icon,
                configItem.route,
                iconColor: configItem.iconColor,
              ))
          .toList();

      groups.add(MenuGroup(configGroup.title, items));
    }

    return groups;
  }

  /// Gets the color for a user role
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

  /// Handles logout functionality
  void _handleLogout(BuildContext context, WidgetRef ref) {
    if (onLogout != null) {
      onLogout!();
    } else {
      LogoutService.performLogoutWithConfirmation(context, ref);
    }
  }
}

/// Represents a group of menu items
class MenuGroup {
  /// The title of the menu group
  final String title;

  /// The list of menu items in this group
  final List<MenuItem> items;

  const MenuGroup(this.title, this.items);
}

/// Represents a single menu item
class MenuItem {
  /// The title of the menu item
  final String title;

  /// The icon for the menu item
  final IconData icon;

  /// The route for the menu item
  final String route;

  /// Optional custom color for the icon
  final Color? iconColor;

  const MenuItem(
    this.title,
    this.icon,
    this.route, {
    this.iconColor,
  });
}
