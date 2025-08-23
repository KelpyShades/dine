import 'package:dine/components/store/data/models/menu_item_model.dart';
import 'package:dine/components/store/data/models/order_model.dart';
import 'package:dine/components/store/data/models/vendor_models.dart';
import 'package:dine/components/store/views/cart_screen.dart';
import 'package:dine/components/store/views/items_screen.dart';
import 'package:dine/components/store/views/order_confirmation_screen.dart';
import 'package:dine/components/store/views/store_screen.dart';
import 'package:dine/components/store/views/vendor_screen.dart';
import 'package:dine/components/vendor/views/add_menu_item_screen.dart';
import 'package:dine/components/vendor/views/vendor_analytics_screen.dart';
import 'package:dine/components/vendor/views/vendor_auth_screen.dart';
import 'package:dine/components/vendor/views/vendor_dashboard_screen.dart';
import 'package:dine/components/vendor/views/vendor_menu_screen.dart';
import 'package:dine/components/vendor/views/vendor_orders_screen.dart';
import 'package:dine/components/vendor/views/vendor_register_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    // redirect: (context, state) {
    //   return '/';
    // },
    routes: [
      GoRoute(path: '/', builder: (context, state) => const StoreScreen()),
      GoRoute(
        path: '/item',
        builder: (context, state) => ItemsScreen(item: state.extra as MenuItem),
      ),
      GoRoute(
        path: '/vendor',
        builder: (context, state) =>
            VendorScreen(vendor: state.extra as Vendor),
      ),
      GoRoute(path: '/cart', builder: (context, state) => const CartScreen()),
      GoRoute(
        path: '/order-confirmation',
        builder: (context, state) =>
            OrderConfirmationScreen(order: state.extra as Order),
      ),
      GoRoute(
        path: '/vendor-auth',
        builder: (context, state) => const VendorAuthScreen(),
      ),
      GoRoute(
        path: '/vendor-register',
        builder: (context, state) => VendorRegisterScreen(),
      ),
      GoRoute(
        path: '/vendor-dashboard',
        builder: (context, state) => const VendorDashboardScreen(),
      ),
      GoRoute(
        path: '/add-menu-item',
        builder: (context, state) => const AddMenuItemScreen(),
      ),
      GoRoute(
        path: '/vendor-menu',
        builder: (context, state) => const VendorMenuScreen(),
      ),
      GoRoute(
        path: '/vendor-orders',
        builder: (context, state) => const VendorOrdersScreen(),
      ),
      GoRoute(
        path: '/vendor-analytics',
        builder: (context, state) =>
            VendorAnalyticsScreen(),
      ),
    ],
  );
});
