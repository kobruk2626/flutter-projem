import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:photo_momento/presentation/providers/auth_provider.dart';
import 'package:photo_momento/presentation/providers/cart_provider.dart';
import 'package:photo_momento/presentation/widgets/custom_app_bar.dart';
import 'package:photo_momento/presentation/widgets/photo_slider.dart';
import 'package:photo_momento/presentation/widgets/quick_action_card.dart';
import 'package:photo_momento/data/models/product_model.dart';
import 'package:photo_momento/data/models/order_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final List<ProductModel> _featuredProducts = [];
  final List<OrderModel> _recentActivities = [];

  @override
  void initState() {
    super.initState();
    _loadFeaturedProducts();
    _loadRecentActivities();
  }

  void _loadFeaturedProducts() {
    // Mock data - will be replaced with API call
    setState(() {
      _featuredProducts.addAll([
        ProductModel(
          id: '1',
          name: '10x15 Parlak Fotoğraf',
          category: 'photo_print',
          size: '10x15',
          paperType: 'glossy',
          price: 25.0,
          stock: 125,
          minStock: 10,
          isActive: true,
          imageUrl: 'assets/images/10x15_glossy.jpg',
          description: 'Yüksek kaliteli parlak fotoğraf baskısı',
          createdAt: DateTime.now(),
          totalSales: 45,
        ),
        ProductModel(
          id: '2',
          name: '13x18 Mat Fotoğraf',
          category: 'photo_print',
          size: '13x18',
          paperType: 'matte',
          price: 35.0,
          stock: 89,
          minStock: 10,
          isActive: true,
          imageUrl: 'assets/images/13x18_matte.jpg',
          description: 'Doğal görünümlü mat fotoğraf baskısı',
          createdAt: DateTime.now(),
          totalSales: 32,
        ),
        ProductModel(
          id: '3',
          name: '15x21 Canvas Fotoğraf',
          category: 'photo_print',
          size: '15x21',
          paperType: 'canvas',
          price: 45.0,
          stock: 12,
          minStock: 5,
          isActive: true,
          imageUrl: 'assets/images/15x21_canvas.jpg',
          description: 'Sanatsal canvas fotoğraf baskısı',
          createdAt: DateTime.now(),
          totalSales: 28,
        ),
        ProductModel(
          id: '4',
          name: '20x25 Parlak Fotoğraf',
          category: 'photo_print',
          size: '20x25',
          paperType: 'glossy',
          price: 60.0,
          stock: 45,
          minStock: 5,
          isActive: true,
          imageUrl: 'assets/images/20x25_glossy.jpg',
          description: 'Büyük boy parlak fotoğraf baskısı',
          createdAt: DateTime.now(),
          totalSales: 18,
        ),
      ]);
    });
  }

  void _loadRecentActivities() {
    // Mock data - will be replaced with API call
    setState(() {
      _recentActivities.addAll([
        OrderModel(
          id: '12346',
          userId: 'user1',
          customerName: 'Ahmet Memet',
          customerEmail: 'ahmet@email.com',
          customerPhone: '+905551234567',
          deliveryAddress: Address(
            id: '1',
            title: 'Ev Adresi',
            fullName: 'Ahmet Memet',
            phone: '+905551234567',
            addressLine1: 'Atatürk Cad. No:123',
            district: 'Kadıköy',
            city: 'İstanbul',
            postalCode: '34700',
            isDefault: true,
          ),
          items: [
            OrderItem(
              productId: '1',
              productName: '10x15 Parlak Fotoğraf',
              size: '10x15',
              paperType: 'glossy',
              price: 25.0,
              quantity: 3,
              imageUrls: [],
            ),
          ],
          subtotal: 75.0,
          shippingCost: 15.0,
          total: 90.0,
          status: OrderStatus.shipped,
          createdAt: DateTime.now().subtract(const Duration(hours: 2)),
          estimatedDelivery: DateTime.now().add(const Duration(days: 2)),
          imageUrls: [],
        ),
        OrderModel(
          id: '12345',
          userId: 'user1',
          customerName: 'Ahmet Memet',
          customerEmail: 'ahmet@email.com',
          customerPhone: '+905551234567',
          deliveryAddress: Address(
            id: '1',
            title: 'Ev Adresi',
            fullName: 'Ahmet Memet',
            phone: '+905551234567',
            addressLine1: 'Atatürk Cad. No:123',
            district: 'Kadıköy',
            city: 'İstanbul',
            postalCode: '34700',
            isDefault: true,
          ),
          items: [
            OrderItem(
              productId: '2',
              productName: '13x18 Mat Fotoğraf',
              size: '13x18',
              paperType: 'matte',
              price: 35.0,
              quantity: 2,
              imageUrls: [],
            ),
          ],
          subtotal: 70.0,
          shippingCost: 15.0,
          total: 85.0,
          status: OrderStatus.printing,
          createdAt: DateTime.now().subtract(const Duration(days: 1)),
          estimatedDelivery: DateTime.now().add(const Duration(days: 3)),
          imageUrls: [],
        ),
      ]);
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final cartProvider = Provider.of<CartProvider>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
        title: 'Photo Momento',
        showHomeButton: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Section
            _buildWelcomeSection(authProvider),

            const SizedBox(height: 24),

            // Quick Actions
            _buildQuickActionsSection(authProvider, cartProvider),

            const SizedBox(height: 24),

            // Featured Products Slider
            _buildFeaturedProductsSection(),

            const SizedBox(height: 24),

            // Recent Activities
            _buildRecentActivitiesSection(authProvider),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(authProvider),
    );
  }

  Widget _buildWelcomeSection(AuthProvider authProvider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (authProvider.isLoggedIn) ...[
            // Logged in user
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '👋 Hoş Geldiniz, ${authProvider.user?.name ?? ''}!',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${_recentActivities.length} aktif siparişiniz bulunuyor',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                if (authProvider.isLoggedIn)
                  IconButton(
                    icon: const Icon(Icons.exit_to_app),
                    onPressed: () => _showLogoutDialog(authProvider),
                  ),
              ],
            ),
          ] else ...[
            // Guest user
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '👋 Hoş Geldiniz!',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Fotoğraflarınız anılara dönüşsün...',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => context.push('/login'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text('Giriş Yap'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => context.push('/register'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text('Kayıt Ol'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildQuickActionsSection(AuthProvider authProvider, CartProvider cartProvider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Hızlı Erişim',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 0.9,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            children: [
              QuickActionCard(
                icon: Icons.photo_camera,
                title: 'Yeni\nSipariş',
                color: Colors.blue,
                onTap: () => _navigateToNewOrder(authProvider),
              ),
              QuickActionCard(
                icon: Icons.list_alt,
                title: 'Siparişlerim',
                color: Colors.green,
                onTap: () => _navigateToOrders(authProvider),
              ),
              QuickActionCard(
                icon: Icons.shopping_cart,
                title: 'Sepetim\n(${cartProvider.itemCount})',
                color: Colors.orange,
                onTap: () => _navigateToCart(authProvider),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturedProductsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Fiyat Listesi',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                'Scroll →',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        PhotoSlider(products: _featuredProducts),
      ],
    );
  }

  Widget _buildRecentActivitiesSection(AuthProvider authProvider) {
    if (!authProvider.isLoggedIn) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Son Hareketler',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            _buildGuestActivities(),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Son Hareketler',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              TextButton(
                onPressed: () => context.push('/orders'),
                child: const Text('Tümünü Gör'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ..._recentActivities.map((order) => _buildActivityItem(order)).toList(),
        ],
      ),
    );
  }

  Widget _buildGuestActivities() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.card_giftcard, color: Colors.blue.shade600, size: 16),
              const SizedBox(width: 8),
              Text(
                'Üye olun ve ilk siparişinizde %15 indirim kazanın!',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.trending_up, color: Colors.green.shade600, size: 16),
              const SizedBox(width: 8),
              Text(
                'En popüler ürün: 15x21 Canvas',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.new_releases, color: Colors.orange.shade600, size: 16),
              const SizedBox(width: 8),
              Text(
                'Yeni ürün: Canvas baskı seçeneği',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActivityItem(OrderModel order) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          // Status Icon
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _getStatusColor(order.status).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _getStatusIcon(order.status),
              color: _getStatusColor(order.status),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          // Order Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${order.formattedOrderNumber} • ${order.formattedTotal}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _getStatusText(order.status),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: _getStatusColor(order.status),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  order.formattedDate,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          // Action Button
          IconButton(
            icon: const Icon(Icons.arrow_forward_ios, size: 16),
            onPressed: () => context.push('/order/${order.id}'),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigationBar(AuthProvider authProvider) {
    return BottomAppBar(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          // Home Button
          _buildBottomNavItem(
            icon: Icons.home,
            label: 'Ana Sayfa',
            isSelected: true,
            onTap: () {},
          ),
          // Orders Button
          _buildBottomNavItem(
            icon: Icons.list_alt,
            label: 'Siparişlerim',
            isSelected: false,
            onTap: () => _navigateToOrders(authProvider),
          ),
          // Profile Button
          _buildBottomNavItem(
            icon: Icons.person_outline,
            label: 'Profil',
            isSelected: false,
            onTap: () => _navigateToProfile(authProvider),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavItem({
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  color: isSelected ? Colors.blue : Colors.grey.shade600,
                  size: 24,
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: isSelected ? Colors.blue : Colors.grey.shade600,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Helper Methods
  Color _getStatusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return Colors.orange;
      case OrderStatus.confirmed:
        return Colors.blue;
      case OrderStatus.processing:
        return Colors.blue.shade600;
      case OrderStatus.printing:
        return Colors.purple;
      case OrderStatus.ready:
        return Colors.green;
      case OrderStatus.shipped:
        return Colors.teal;
      case OrderStatus.delivered:
        return Colors.green.shade600;
      case OrderStatus.cancelled:
        return Colors.red;
      case OrderStatus.refunded:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return Icons.pending;
      case OrderStatus.confirmed:
        return Icons.check_circle_outline;
      case OrderStatus.processing:
        return Icons.settings;
      case OrderStatus.printing:
        return Icons.print;
      case OrderStatus.ready:
        return Icons.inventory_2;
      case OrderStatus.shipped:
        return Icons.local_shipping;
      case OrderStatus.delivered:
        return Icons.verified;
      case OrderStatus.cancelled:
        return Icons.cancel;
      case OrderStatus.refunded:
        return Icons.money_off;
    }
  }

  String _getStatusText(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return 'Beklemede';
      case OrderStatus.confirmed:
        return 'Onaylandı';
      case OrderStatus.processing:
        return 'İşleniyor';
      case OrderStatus.printing:
        return 'Baskıda';
      case OrderStatus.ready:
        return 'Hazır';
      case OrderStatus.shipped:
        return 'Kargoda';
      case OrderStatus.delivered:
        return 'Teslim Edildi';
      case OrderStatus.cancelled:
        return 'İptal Edildi';
      case OrderStatus.refunded:
        return 'İade Edildi';
    }
  }

  // Navigation Methods
  void _navigateToNewOrder(AuthProvider authProvider) {
    if (!authProvider.isLoggedIn) {
      _showLoginRequiredDialog('Yeni sipariş oluşturmak için giriş yapmalısınız');
      return;
    }
    context.push('/new-order');
  }

  void _navigateToOrders(AuthProvider authProvider) {
    if (!authProvider.isLoggedIn) {
      _showLoginRequiredDialog('Siparişlerinizi görüntülemek için giriş yapmalısınız');
      return;
    }
    context.push('/orders');
  }

  void _navigateToCart(AuthProvider authProvider) {
    if (!authProvider.isLoggedIn) {
      _showLoginRequiredDialog('Sepetinizi görüntülemek için giriş yapmalısınız');
      return;
    }
    context.push('/cart');
  }

  void _navigateToProfile(AuthProvider authProvider) {
    if (!authProvider.isLoggedIn) {
      _showLoginRequiredDialog('Profilinizi görüntülemek için giriş yapmalısınız');
      return;
    }
    context.push('/profile');
  }

  void _showLoginRequiredDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Giriş Gerekli'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.push('/login');
            },
            child: const Text('Giriş Yap'),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(AuthProvider authProvider) {
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
              authProvider.signOut();
            },
            child: const Text('Çıkış Yap'),
          ),
        ],
      ),
    );
  }
}