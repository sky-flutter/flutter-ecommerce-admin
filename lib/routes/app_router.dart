import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../features/analytics/presentation/pages/analytics_page.dart';
import '../features/inventory/presentation/pages/inventory_page.dart';
import '../features/auth/presentation/pages/login_page.dart';
import '../features/dashboard/presentation/pages/dashboard_page.dart';
import '../features/reports/presentation/pages/reports_page.dart';
import '../features/users/presentation/pages/users_page.dart';
import '../features/users/presentation/pages/add_user_page.dart';
import '../features/products/presentation/pages/products_page.dart';
import '../features/products/presentation/pages/add_product_page.dart';
import '../features/products/presentation/pages/product_details_page_new.dart';
import '../features/products/presentation/pages/product_details_page.dart';
import '../features/orders/presentation/pages/orders_page.dart';
import '../features/settings/presentation/pages/settings_page.dart';
import '../features/settings/presentation/pages/shipping_page.dart';
import '../features/categories/presentation/pages/categories_page.dart';
import '../features/settings/presentation/pages/store_info_page.dart';
import '../features/settings/presentation/pages/email_settings_page.dart';
import '../features/settings/presentation/pages/payment_settings_page.dart';
import '../features/promotions/presentation/pages/promotions_page.dart';
import '../features/orders/presentation/pages/orders_page.dart';
import '../features/orders/presentation/pages/order_details_page.dart';
import '../features/reviews/presentation/pages/review_details_page.dart';
import '../features/reviews/presentation/pages/reviews_page.dart';
import '../shared/widgets/access_denied_page.dart';
import '../shared/widgets/not_found_page.dart';
import 'route_guards.dart';

final appRouter = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    debugLogDiagnostics: true,
    redirect: (context, state) async {
      return await RouteGuards.authGuard(state, ref);
    },
    routes: [
      GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
      GoRoute(path: '/', builder: (context, state) => const DashboardPage()),
      GoRoute(
          path: '/new-dashboard',
          builder: (context, state) => const DashboardPage()),
      GoRoute(path: '/users', builder: (context, state) => const UsersPage()),
      GoRoute(
          path: '/users/add', builder: (context, state) => const AddUserPage()),
      // Edit user route handled by Navigator.push in UsersPage
      GoRoute(
          path: '/products/add',
          builder: (context, state) => const AddProductPage()),
      GoRoute(
          path: '/products/:id',
          builder: (context, state) => ProductDetailsPage(
                productId: state.pathParameters['id']!,
              )),
      GoRoute(
          path: '/products/new/:id',
          builder: (context, state) => ProductDetailsPageNew(
                productId: state.pathParameters['id']!,
              )),
      GoRoute(
          path: '/products/add/:id',
          builder: (context, state) => AddProductPage(
                productId: state.pathParameters['id']!,
              )),
      GoRoute(
          path: '/products', builder: (context, state) => const ProductsPage()),
      GoRoute(
          path: '/categories',
          builder: (context, state) => const CategoriesPage()),
      GoRoute(path: '/orders', builder: (context, state) => const OrdersPage()),
      GoRoute(
          path: '/settings', builder: (context, state) => const SettingsPage()),
      GoRoute(
          path: '/shipping', builder: (context, state) => const ShippingPage()),
      GoRoute(
          path: '/reports', builder: (context, state) => const ReportsPage()),
      GoRoute(
          path: '/analytics',
          builder: (context, state) => const AnalyticsPage()),
      GoRoute(
          path: '/inventory',
          builder: (context, state) => const InventoryPage()),
      GoRoute(
          path: '/store-info',
          builder: (context, state) => const StoreInfoPage()),
      GoRoute(
          path: '/email-settings',
          builder: (context, state) => const EmailSettingsPage()),
      GoRoute(
          path: '/payment-settings',
          builder: (context, state) => const PaymentSettingsPage()),
      GoRoute(
          path: '/promotions',
          builder: (context, state) => const PromotionsPage()),
      GoRoute(path: '/orders', builder: (context, state) => const OrdersPage()),
      GoRoute(
          path: '/orders/:id',
          builder: (context, state) => OrderDetailsPage(
                orderId: state.pathParameters['id']!,
              )),
      GoRoute(
          path: '/reviews', builder: (context, state) => const ReviewsPage()),
      GoRoute(
          path: '/reviews/:id',
          builder: (context, state) => ReviewDetailsPage(
                reviewId: state.pathParameters['id']!,
              )),
      GoRoute(
          path: '/access-denied',
          builder: (context, state) => const AccessDeniedPage()),
    ],
    errorBuilder: (context, state) => const NotFoundPage(),
  );
});
