import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:photo_momento/presentation/providers/auth_provider.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final bool showBackButton;
  final bool showHomeButton;

  const CustomAppBar({
    super.key,
    required this.title,
    this.actions,
    this.showBackButton = false,
    this.showHomeButton = false,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    return AppBar(
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 18,
        ),
      ),
      centerTitle: true,
      backgroundColor: Colors.white,
      foregroundColor: Colors.black,
      elevation: 0,
      leading: _buildLeading(context),
      actions: _buildActions(context, authProvider),
    );
  }

  Widget? _buildLeading(BuildContext context) {
    if (showBackButton) {
      return IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => Navigator.of(context).pop(),
      );
    }

    if (showHomeButton) {
      return IconButton(
        icon: const Icon(Icons.home),
        onPressed: () => Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false),
      );
    }

    return null;
  }

  List<Widget> _buildActions(BuildContext context, AuthProvider authProvider) {
    final List<Widget> actionWidgets = [];

    // Add notification icon for logged-in users
    if (authProvider.isLoggedIn) {
      actionWidgets.add(
        IconButton(
          icon: const Icon(Icons.notifications_none),
          onPressed: () {
            // Navigate to notifications
          },
        ),
      );

      // Add cart icon for customers
      if (!authProvider.isAdmin) {
        actionWidgets.add(
          IconButton(
            icon: const Icon(Icons.shopping_cart_outlined),
            onPressed: () {
              Navigator.of(context).pushNamed('/cart');
            },
          ),
        );
      }

      // Add help icon
      actionWidgets.add(
        IconButton(
          icon: const Icon(Icons.help_outline),
          onPressed: () {
            Navigator.of(context).pushNamed('/help');
          },
        ),
      );

      // Add profile or logout for admin
      if (authProvider.isAdmin) {
        actionWidgets.add(
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _showLogoutDialog(context),
          ),
        );
      } else {
        actionWidgets.add(
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () {
              Navigator.of(context).pushNamed('/profile');
            },
          ),
        );
      }
    }

    // Add custom actions
    if (actions != null) {
      actionWidgets.addAll(actions!);
    }

    return actionWidgets;
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Çıkış Yap'),
        content: const Text('Çıkış yapmak istediğinizden emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Provider.of<AuthProvider>(context, listen: false).signOut();
            },
            child: const Text('Çıkış Yap'),
          ),
        ],
      ),
    );
  }
}