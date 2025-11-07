import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:photo_momento/presentation/screens/auth/login_screen.dart';
import 'package:photo_momento/presentation/screens/auth/register_screen.dart';
import 'package:photo_momento/presentation/screens/auth/forgot_password_screen.dart';
import 'package:photo_momento/presentation/screens/customer/home_screen.dart';
import 'package:photo_momento/presentation/screens/customer/new_order_screen.dart';
import 'package:photo_momento/presentation/screens/customer/cart_screen.dart';
import 'package:photo_momento/presentation/screens/customer/orders_screen.dart';
import 'package:photo_momento/presentation/screens/customer/order_detail_screen.dart';
import 'package:photo_momento/presentation/screens/customer/profile_screen.dart';
import 'package:photo_momento/presentation/screens/customer/help_screen.dart';
import 'package:photo_momento/presentation/screens/admin/admin_dashboard_screen.dart';
import 'package:photo_momento/presentation/screens/admin/admin_orders_screen.dart';
import 'package:photo_momento/presentation/screens/admin/admin_products_screen.dart';
import 'package:photo_momento/presentation/screens/admin/admin_customers_screen.dart';
import 'package:photo_momento/presentation/screens/admin/admin_reports_screen.dart';
import 'package:photo_momento/presentation/screens/admin/admin_settings_screen.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    routes: [
      // Auth Routes
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        name: 'register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/forgot-password',
        name: 'forgot_password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),

      // Customer Routes
      GoRoute(
        path: '/',
        name: 'home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/new-order',
        name: 'new_order',
        builder: (context, state) => const NewOrderScreen(),
      ),
      GoRoute(
        path: '/cart',
        name: 'cart',
        builder: (context, state) => const CartScreen(),
      ),
      GoRoute(
        path: '/orders',
        name: 'orders',
        builder: (context, state) => const OrdersScreen(),
      ),
      GoRoute(
        path: '/order/:id',
        name: 'order_detail',
        builder: (context, state) {
          final orderId = state.pathParameters['id']!;
          return OrderDetailScreen(orderId: orderId);
        },
      ),
      GoRoute(
        path: '/profile',
        name: 'profile',
        builder: (context, state) => const ProfileScreen(),
      ),
      GoRoute(
        path: '/help',
        name: 'help',
        builder: (context, state) => const HelpScreen(),
      ),

      // Admin Routes - Nested Structure
      GoRoute(
        path: '/admin',
        name: 'admin_dashboard',
        builder: (context, state) => const AdminDashboardScreen(),
        routes: [
          GoRoute(
            path: 'orders',
            name: 'admin_orders',
            builder: (context, state) => const AdminOrdersScreen(),
          ),
          GoRoute(
            path: 'products',
            name: 'admin_products',
            builder: (context, state) => const AdminProductsScreen(),
          ),
          GoRoute(
            path: 'customers',
            name: 'admin_customers',
            builder: (context, state) => const AdminCustomersScreen(),
          ),
          GoRoute(
            path: 'reports',
            name: 'admin_reports',
            builder: (context, state) => const AdminReportsScreen(),
          ),
          GoRoute(
            path: 'settings',
            name: 'admin_settings',
            builder: (context, state) => const AdminSettingsScreen(),
          ),
        ],
      ),
    ],
    redirect: (context, state) {
      // Add authentication redirect logic here
      // This will be implemented after we have the auth provider set up
      return null;
    },
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              '404',
              style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text(
              'Sayfa Bulunamadı',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go('/'),
              child: const Text('Ana Sayfaya Dön'),
            ),
          ],
        ),
      ),
    ),
  );
}