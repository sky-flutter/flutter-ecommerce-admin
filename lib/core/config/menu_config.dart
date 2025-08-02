import 'package:flutter/material.dart';

class MenuConfig {
  static const List<MenuGroupConfig> defaultMenu = [
    MenuGroupConfig(
      title: 'Core Operations',
      items: [
        MenuItemConfig(
          title: 'Dashboard',
          icon: Icons.dashboard,
          route: '/',
          roles: ['admin', 'editor', 'viewer'],
        ),
        MenuItemConfig(
          title: 'User Management',
          icon: Icons.people,
          route: '/users',
          roles: ['admin'],
        ),
        MenuItemConfig(
          title: 'Products',
          icon: Icons.shopping_bag,
          route: '/products',
          roles: ['admin', 'editor'],
        ),
        MenuItemConfig(
          title: 'Categories',
          icon: Icons.category,
          route: '/categories',
          roles: ['admin', 'editor'],
        ),
        MenuItemConfig(
          title: 'Orders',
          icon: Icons.receipt_long,
          route: '/orders',
          roles: ['admin', 'editor', 'viewer'],
        ),
        MenuItemConfig(
          title: 'Reviews',
          icon: Icons.star,
          route: '/reviews',
          roles: ['admin', 'editor'],
        ),
      ],
    ),
    MenuGroupConfig(
      title: 'Business Operations',
      items: [
        MenuItemConfig(
          title: 'Discounts & Promotions',
          icon: Icons.local_offer,
          route: '/promotions',
          roles: ['admin', 'editor'],
        ),
        MenuItemConfig(
          title: 'Order & Inventory Settings',
          icon: Icons.inventory_2,
          route: '/inventory-settings',
          roles: ['admin', 'editor'],
        ),
        MenuItemConfig(
          title: 'Shipping & Delivery',
          icon: Icons.local_shipping,
          route: '/shipping',
          roles: ['admin', 'editor'],
        ),
        MenuItemConfig(
          title: 'Payment Settings',
          icon: Icons.payment,
          route: '/payment-settings',
          roles: ['admin'],
        ),
      ],
    ),
    MenuGroupConfig(
      title: 'Platform Configuration',
      items: [
        MenuItemConfig(
          title: 'Store Information',
          icon: Icons.store,
          route: '/store-info',
          roles: ['admin'],
        ),
        MenuItemConfig(
          title: 'Email & Notifications',
          icon: Icons.email,
          route: '/email-settings',
          roles: ['admin'],
        ),
        MenuItemConfig(
          title: 'General Settings',
          icon: Icons.settings,
          route: '/settings',
          roles: ['admin', 'editor'],
        ),
      ],
    ),
    MenuGroupConfig(
      title: 'Analytics & Reports',
      items: [
        MenuItemConfig(
          title: 'Analytics',
          icon: Icons.analytics,
          route: '/analytics',
          roles: ['admin'],
        ),
        MenuItemConfig(
          title: 'Reports',
          icon: Icons.assessment,
          route: '/reports',
          roles: ['admin'],
        ),
      ],
    ),
  ];

  static List<MenuGroupConfig> getMenuForRole(String? userRole) {
    if (userRole == null) return [];

    return defaultMenu
        .map((group) {
          final filteredItems = group.items
              .where((item) => item.roles.contains(userRole))
              .toList();

          return MenuGroupConfig(
            title: group.title,
            items: filteredItems,
          );
        })
        .where((group) => group.items.isNotEmpty)
        .toList();
  }
}

class MenuGroupConfig {
  final String title;
  final List<MenuItemConfig> items;

  const MenuGroupConfig({
    required this.title,
    required this.items,
  });
}

class MenuItemConfig {
  final String title;
  final IconData icon;
  final String route;
  final List<String> roles;
  final Color? iconColor;

  const MenuItemConfig({
    required this.title,
    required this.icon,
    required this.route,
    required this.roles,
    this.iconColor,
  });
}
