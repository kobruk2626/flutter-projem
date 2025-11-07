import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:photo_momento/presentation/providers/auth_provider.dart';
import 'package:photo_momento/presentation/providers/order_provider.dart';
import 'package:photo_momento/presentation/providers/product_provider.dart';
import 'package:photo_momento/presentation/widgets/custom_app_bar.dart';
import 'package:photo_momento/data/models/order_model.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    final orderProvider = Provider.of<OrderProvider>(context, listen: false);
    final productProvider = Provider.of<ProductProvider>(context, listen: false);

    orderProvider.loadAllOrders();
    productProvider.loadProducts();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final orderProvider = Provider.of<OrderProvider>(context);
    final productProvider = Provider.of<ProductProvider>(context);

    if (!authProvider.isAdmin) {
      return _buildAccessDenied();
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
        title: 'Yönetici Paneli',
        showBackButton: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Quick Stats
            _buildQuickStats(orderProvider, productProvider),
            const SizedBox(height: 24),

            // Urgent Actions
            _buildUrgentActions(orderProvider, productProvider),
            const SizedBox(height: 24),

            // Recent Orders
            _buildRecentOrders(orderProvider),
            const SizedBox(height: 24),

            // Quick Actions
            _buildQuickActions(),
          ],
        ),
      ),
    );
  }

  Widget _buildAccessDenied() {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Yönetici Paneli',
        showBackButton: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.admin_panel_settings,
              size: 80,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 16),
            const Text(
              'Erişim Reddedildi',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            const Text('Bu sayfaya erişim yetkiniz bulunmuyor'),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                context.go('/');
              },
              child: const Text('Ana Sayfaya Dön'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickStats(OrderProvider orderProvider, ProductProvider productProvider) {
    final pendingOrders = orderProvider.allOrders.where((o) => o.status == OrderStatus.pending).length;
    final printingOrders = orderProvider.allOrders.where((o) => o.status == OrderStatus.printing).length;
    final lowStockProducts = productProvider.products.where((p) => p.isLowStock).length;

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      children: [
        _buildStatCard(
          'Bekleyen Siparişler',
          pendingOrders.toString(),
          Colors.orange,
          Icons.pending_actions,
        ),
        _buildStatCard(
          'Baskıdaki Siparişler',
          printingOrders.toString(),
          Colors.purple,
          Icons.print,
        ),
        _buildStatCard(
          'Toplam Sipariş',
          orderProvider.allOrders.length.toString(),
          Colors.blue,
          Icons.shopping_cart,
        ),
        _buildStatCard(
          'Az Stok Ürün',
          lowStockProducts.toString(),
          Colors.red,
          Icons.warning,
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, Color color, IconData icon) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUrgentActions(OrderProvider orderProvider, ProductProvider productProvider) {
    final urgentOrders = orderProvider.allOrders.where((o) =>
    o.status == OrderStatus.pending || o.status == OrderStatus.printing
    ).take(3).toList();

    final lowStockProducts = productProvider.products.where((p) => p.isLowStock).take(2).toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Acil Eylem Gerekenler',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),

            if (urgentOrders.isEmpty && lowStockProducts.isEmpty)
              const Text('Şu an için acil eylem gereken durum bulunmuyor.'),

            // Urgent Orders
            if (urgentOrders.isNotEmpty) ...[
              const Text(
                '⏰ Hazırlanacak Siparişler:',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              ...urgentOrders.map((order) => _buildUrgentOrderItem(order)).toList(),
            ],

            // Low Stock Products
            if (lowStockProducts.isNotEmpty) ...[
              const SizedBox(height: 12),
              const Text(
                '⚠️ Stok Uyarıları:',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              ...lowStockProducts.map((product) => _buildLowStockItem(product)).toList(),
            ],

            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  context.push('/admin/orders');
                },
                child: const Text('Tümünü Gör'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUrgentOrderItem(OrderModel order) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  order.formattedOrderNumber,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                Text(
                  '${order.customerName} • ${order.formattedTotal}',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              context.push('/admin/orders');
            },
            icon: const Icon(Icons.arrow_forward, size: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildLowStockItem(ProductModel product) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                Text(
                  'Stok: ${product.stock} (Min: ${product.minStock})',
                  style: TextStyle(fontSize: 12, color: Colors.orange.shade700),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              context.push('/admin/products');
            },
            icon: const Icon(Icons.arrow_forward, size: 16),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentOrders(OrderProvider orderProvider) {
    final recentOrders = orderProvider.allOrders.take(5).toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Son Siparişler',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),

            if (recentOrders.isEmpty)
              const Text('Henüz sipariş bulunmuyor.'),

            ...recentOrders.map((order) => _buildRecentOrderItem(order)).toList(),

            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  context.push('/admin/orders');
                },
                child: const Text('Tüm Siparişler'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentOrderItem(OrderModel order) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        children: [
          // Status Indicator
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: _getStatusColor(order.status),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),

          // Order Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  order.formattedOrderNumber,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                Text(
                  '${order.customerName} • ${order.formattedDate}',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),

          // Amount
          Text(
            order.formattedTotal,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Hızlı İşlemler',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),

            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              children: [
                _buildQuickActionCard(
                  'Sipariş Yönetimi',
                  Icons.list_alt,
                  Colors.blue,
                      () => context.push('/admin/orders'),
                ),
                _buildQuickActionCard(
                  'Ürün Yönetimi',
                  Icons.photo_library,
                  Colors.green,
                      () => context.push('/admin/products'),
                ),
                _buildQuickActionCard(
                  'Müşteri Yönetimi',
                  Icons.people,
                  Colors.purple,
                      () => context.push('/admin/customers'),
                ),
                _buildQuickActionCard(
                  'Raporlar',
                  Icons.analytics,
                  Colors.orange,
                      () => context.push('/admin/reports'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionCard(String title, IconData icon, Color color, VoidCallback onTap) {
    return Card(
      elevation: 2,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: color, size: 32),
                const SizedBox(height: 8),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

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
}