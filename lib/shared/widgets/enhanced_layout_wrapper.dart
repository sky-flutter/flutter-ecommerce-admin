import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'enhanced_sidebar_menu.dart';
import '../../core/constants/app_theme.dart';
import '../../core/infrastructure/firebase/logout_service.dart';

/// Enhanced layout wrapper that provides responsive layout with sidebar
class EnhancedLayoutWrapper extends ConsumerStatefulWidget {
  /// The main content widget
  final Widget child;

  /// The current route for highlighting active menu items
  final String currentRoute;

  const EnhancedLayoutWrapper({
    super.key,
    required this.child,
    required this.currentRoute,
  });

  @override
  ConsumerState<EnhancedLayoutWrapper> createState() =>
      _EnhancedLayoutWrapperState();
}

class _EnhancedLayoutWrapperState extends ConsumerState<EnhancedLayoutWrapper> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 800;

        if (isMobile) {
          return _buildMobileLayout();
        } else {
          return _buildDesktopLayout();
        }
      },
    );
  }

  /// Builds the mobile layout with drawer
  Widget _buildMobileLayout() {
    return Scaffold(
      key: _scaffoldKey,
      drawer: _buildSidebar(),
      appBar: _buildMobileAppBar(),
      body: widget.child,
    );
  }

  /// Builds the desktop layout with permanent sidebar
  Widget _buildDesktopLayout() {
    return Scaffold(
      body: Row(
        children: [
          _buildSidebar(),
          Expanded(
            child: _buildDesktopContent(),
          ),
        ],
      ),
    );
  }

  /// Builds the sidebar menu
  Widget _buildSidebar() {
    return EnhancedSidebarMenu(
      onNavigate: (route) => _handleNavigation(route),
      currentRoute: widget.currentRoute,
      onLogout: _handleLogout,
    );
  }

  /// Builds the mobile app bar
  PreferredSizeWidget _buildMobileAppBar() {
    return AppBar(
      title: Text(_getPageTitle(widget.currentRoute)),
      leading: IconButton(
        icon: const Icon(Icons.menu),
        onPressed: () => _scaffoldKey.currentState?.openDrawer(),
      ),
      actions: _buildAppBarActions(),
    );
  }

  /// Builds the desktop content area
  Widget _buildDesktopContent() {
    return Column(
      children: [
        _buildDesktopAppBar(),
        Expanded(child: widget.child),
      ],
    );
  }

  /// Builds the desktop app bar
  Widget _buildDesktopAppBar() {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: Border(
          bottom: BorderSide(
            color: AppTheme.neutral200,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Text(
            _getPageTitle(widget.currentRoute),
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          ..._buildAppBarActions(),
        ],
      ),
    );
  }

  /// Builds app bar actions
  List<Widget> _buildAppBarActions() {
    return [
      // Add any app bar actions here
    ];
  }

  /// Handles navigation to a route
  void _handleNavigation(String route) {
    context.go(route);
    _scaffoldKey.currentState?.closeDrawer();
  }

  /// Handles logout
  Future<void> _handleLogout() async {
    await LogoutService.performLogoutAndNavigate(context, ref);
  }

  /// Gets the page title based on the current route
  String _getPageTitle(String route) {
    switch (route) {
      case '/':
        return 'Dashboard';
      case '/users':
        return 'Users';
      case '/products':
        return 'Products';
      case '/orders':
        return 'Orders';
      case '/categories':
        return 'Categories';
      case '/settings':
        return 'Settings';
      case '/reports':
        return 'Reports';
      case '/analytics':
        return 'Analytics';
      case '/inventory':
        return 'Inventory';
      case '/shipping':
        return 'Shipping';
      case '/promotions':
        return 'Promotions';
      case '/reviews':
        return 'Reviews';
      case '/store-info':
        return 'Store Info';
      case '/email-settings':
        return 'Email Settings';
      case '/payment-settings':
        return 'Payment Settings';
      default:
        return 'Admin Panel';
    }
  }
}
