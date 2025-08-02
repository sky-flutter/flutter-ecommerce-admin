import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/providers/custom_auth_provider.dart';
import 'sidebar_menu.dart';
import 'header_bar.dart';
import 'footer.dart';

class LayoutWrapper extends ConsumerWidget {
  final Widget child;
  final String title;

  const LayoutWrapper({
    super.key,
    required this.child,
    required this.title,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authService = ref.read(customAuthServiceProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await authService.signOut();
              if (context.mounted) {
                context.go('/login');
              }
            },
          ),
        ],
      ),
      drawer: MediaQuery.of(context).size.width < 800
          ? SidebarMenu(onNavigate: (route) => context.go(route))
          : null,
      body: Row(
        children: [
          // Sidebar for web/tablet
          if (MediaQuery.of(context).size.width >= 800)
            SidebarMenu(onNavigate: (route) => context.go(route)),
          // Main content
          Expanded(
            child: Column(
              children: [
                Expanded(child: child),
                const Footer(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
