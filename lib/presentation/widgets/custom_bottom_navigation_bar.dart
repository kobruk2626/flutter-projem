import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CustomBottomNavigationBar extends StatelessWidget {
  final String currentRoute;
  final bool isAdmin;

  const CustomBottomNavigationBar({
    super.key,
    required this.currentRoute,
    required this.isAdmin,
  });

  @override
  Widget build(BuildContext context) {
    if (isAdmin) {
      return _buildAdminBottomNav(context);
    } else {
      return _buildCustomerBottomNav(context);
    }
  }

  Widget _buildCustomerBottomNav(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                context,
                icon: Icons.home_outlined,
                activeIcon: Icons.home,
                label: 'Ana Sayfa',
                route: '/home',
                isActive: currentRoute == '/home',
              ),
              _buildNavItem(
                context,
                icon: Icons.shopping_bag_outlined,
                activeIcon: Icons.shopping_bag,
                label: 'Siparişlerim',
                route: '/orders',
                isActive: currentRoute == '/orders',
              ),
              _buildNavItem(
                context,
                icon: Icons.person_outlined,
                activeIcon: Icons.person,
                label: 'Profilim',
                route: '/profile',
                isActive: currentRoute == '/profile',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAdminBottomNav(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                context,
                icon: Icons.dashboard_outlined,
                activeIcon: Icons.dashboard,
                label: 'Dashboard',
                route: '/admin/dashboard',
                isActive: currentRoute == '/admin/dashboard',
              ),
              _buildNavItem(
                context,
                icon: Icons.shopping_cart_outlined,
                activeIcon: Icons.shopping_cart,
                label: 'Siparişler',
                route: '/admin/orders',
                isActive: currentRoute == '/admin/orders',
              ),
              _buildNavItem(
                context,
                icon: Icons.people_outlined,
                activeIcon: Icons.people,
                label: 'Müşteriler',
                route: '/admin/customers',
                isActive: currentRoute == '/admin/customers',
              ),
              _buildNavItem(
                context,
                icon: Icons.photo_library_outlined,
                activeIcon: Icons.photo_library,
                label: 'Ürünler',
                route: '/admin/products',
                isActive: currentRoute == '/admin/products',
              ),
              _buildNavItem(
                context,
                icon: Icons.analytics_outlined,
                activeIcon: Icons.analytics,
                label: 'Raporlar',
                route: '/admin/reports',
                isActive: currentRoute == '/admin/reports',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
      BuildContext context, {
        required IconData icon,
        required IconData activeIcon,
        required String label,
        required String route,
        required bool isActive,
      }) {
    return GestureDetector(
      onTap: () {
        if (currentRoute != route) {
          context.go(route);
        }
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isActive ? activeIcon : icon,
            color: isActive ? Colors.blue : Colors.grey.shade600,
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isActive ? Colors.blue : Colors.grey.shade600,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}