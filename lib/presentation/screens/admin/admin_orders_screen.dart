import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:photo_momento/presentation/providers/auth_provider.dart';
import 'package:photo_momento/presentation/providers/order_provider.dart';
import 'package:photo_momento/presentation/widgets/custom_app_bar.dart';
import 'package:photo_momento/data/models/order_model.dart';

class AdminOrdersScreen extends StatefulWidget {
  const AdminOrdersScreen({super.key});

  @override
  State<AdminOrdersScreen> createState() => _AdminOrdersScreenState();
}

class _AdminOrdersScreenState extends State<AdminOrdersScreen> {
  final TextEditingController _searchController = TextEditingController();
  OrderStatus? _selectedFilter;

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  void _loadOrders() {
    final orderProvider = Provider.of<OrderProvider>(context, listen: false);
    orderProvider.loadAllOrders();
    orderProvider.initializeAllOrdersStream();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final orderProvider = Provider.of<OrderProvider>(context);

    if (!authProvider.isAdmin) {
      return _buildAccessDenied();
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
        title: 'Sipariş Yönetimi',
        showBackButton: true,
      ),
      body: Column(
        children: [
          // Search and Filter Section
          _buildSearchFilterSection(orderProvider),

          // Orders List
          Expanded(
            child: _buildOrdersList(orderProvider),
          ),
        ],
      ),
    );
  }

  Widget _buildAccessDenied() {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Sipariş Yönetimi',
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
          ],
        ),
      ),
    );
  }

  Widget _buildSearchFilterSection(OrderProvider orderProvider) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.grey.shade50,
      child: Column(
        children: [
          // Search Bar
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Sipariş no, müşteri adı...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            ),
            onChanged: (value) {
              _applyFilters();
            },
          ),
          const SizedBox(height: 12),

          // Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip('Tümü', null),
                _buildFilterChip('Bekleyen', OrderStatus.pending),
                _buildFilterChip('Onaylanan', OrderStatus.confirmed),
                _buildFilterChip('Baskıda', OrderStatus.printing),
                _buildFilterChip('Kargoda', OrderStatus.shipped),
                _buildFilterChip('Tamamlanan', OrderStatus.delivered),
                _buildFilterChip('İptal', OrderStatus.cancelled),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, OrderStatus? status) {
    final isSelected = _selectedFilter == status;

    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            _selectedFilter = selected ? status : null;
          });
          _applyFilters();
        },
        backgroundColor: Colors.white,
        selectedColor: Colors.blue.shade100,
        checkmarkColor: Colors.blue,
        labelStyle: TextStyle(
          color: isSelected ? Colors.blue : Colors.grey.shade700,
        ),
        side: BorderSide(
          color: isSelected ? Colors.blue : Colors.grey.shade300,
        ),
      ),
    );
  }

  Widget _buildOrdersList(OrderProvider orderProvider) {
    if (orderProvider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (orderProvider.allOrders.isEmpty) {
      return _buildEmptyOrders();
    }

    // Filter orders
    final filteredOrders = _selectedFilter == null
        ? orderProvider.allOrders
        : orderProvider.allOrders.where((order) => order.status == _selectedFilter).toList();

    if (filteredOrders.isEmpty) {
      return _buildNoOrdersForFilter();
    }

    return RefreshIndicator(
      onRefresh: () async {
        await orderProvider.loadAllOrders();
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: filteredOrders.length,
        itemBuilder: (context, index) {
          final order = filteredOrders[index];
          return _buildOrderCard(order, orderProvider);
        },
      ),
    );
  }

  Widget _buildOrderCard(OrderModel order, OrderProvider orderProvider) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order.formattedOrderNumber,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        order.customerName,
                        style: TextStyle(
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusColor(order.status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _getStatusText(order.status),
                    style: TextStyle(
                      color: _getStatusColor(order.status),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Order Details
            Row(
              children: [
                Icon(Icons.phone, size: 16, color: Colors.grey.shade600),
                const SizedBox(width: 4),
                Text(
                  order.customerPhone,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
                const SizedBox(width: 16),
                Icon(Icons.email, size: 16, color: Colors.grey.shade600),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    order.customerEmail,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // Products and Total
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${order.totalItems} ürün • ${order.formattedDate}',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
                Text(
                  order.formattedTotal,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Quick Actions
            _buildQuickActions(order, orderProvider),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions(OrderModel order, OrderProvider orderProvider) {
    return Row(
      children: [
        // View Details
        Expanded(
          child: OutlinedButton(
            onPressed: () {
              _viewOrderDetails(order);
            },
            child: const Text('Detaylar'),
          ),
        ),
        const SizedBox(width: 8),

        // Status Actions
        if (order.status == OrderStatus.pending) ...[
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                _updateOrderStatus(order, OrderStatus.confirmed, orderProvider);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
              ),
              child: const Text('Onayla'),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: () {
              _cancelOrder(order, orderProvider);
            },
            icon: const Icon(Icons.cancel, size: 20),
            color: Colors.red,
          ),
        ],

        if (order.status == OrderStatus.confirmed) ...[
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                _updateOrderStatus(order, OrderStatus.printing, orderProvider);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
              ),
              child: const Text('Baskıya Al'),
            ),
          ),
        ],

        if (order.status == OrderStatus.printing) ...[
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                _updateOrderStatus(order, OrderStatus.ready, orderProvider);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
              ),
              child: const Text('Hazır'),
            ),
          ),
        ],

        if (order.status == OrderStatus.ready) ...[
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                _shipOrder(order, orderProvider);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
              ),
              child: const Text('Kargola'),
            ),
          ),
        ],

        // Contact Customer
        IconButton(
          onPressed: () {
            _contactCustomer(order);
          },
          icon: const Icon(Icons.phone, size: 20),
          color: Colors.blue,
        ),
      ],
    );
  }

  Widget _buildEmptyOrders() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.list_alt_outlined,
            size: 80,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 16),
          const Text(
            'Henüz Sipariş Yok',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          const Text('Müşteri siparişleri burada görünecek'),
        ],
      ),
    );
  }

  Widget _buildNoOrdersForFilter() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.filter_alt_outlined,
            size: 80,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 16),
          const Text(
            'Bu Filtreye Uygun Sipariş Yok',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          const Text('Farklı bir filtre seçin veya filtreyi temizleyin'),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _selectedFilter = null;
              });
            },
            child: const Text('Filtreyi Temizle'),
          ),
        ],
      ),
    );
  }

  void _applyFilters() {
    setState(() {});
  }

  void _viewOrderDetails(OrderModel order) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Sipariş Detayı - ${order.formattedOrderNumber}'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Müşteri', order.customerName),
              _buildDetailRow('Telefon', order.customerPhone),
              _buildDetailRow('E-posta', order.customerEmail),
              _buildDetailRow('Adres', order.deliveryAddress.addressLine1),
              _buildDetailRow('İlçe/Şehir', '${order.deliveryAddress.district}/${order.deliveryAddress.city}'),
              _buildDetailRow('Toplam', order.formattedTotal),
              _buildDetailRow('Durum', _getStatusText(order.status)),

              const SizedBox(height: 16),
              const Text(
                'Sipariş Kalemleri:',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              ...order.items.map((item) => Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text('• ${item.productName} (${item.quantity} adet) - ${item.formattedTotal}'),
              )).toList(),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Kapat'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  void _updateOrderStatus(OrderModel order, OrderStatus newStatus, OrderProvider orderProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Durum Güncelle'),
        content: Text('Sipariş durumunu "${_getStatusText(newStatus)}" olarak güncellemek istiyor musunuz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _confirmStatusUpdate(order, newStatus, orderProvider);
            },
            child: const Text('Güncelle'),
          ),
        ],
      ),
    );
  }

  void _confirmStatusUpdate(OrderModel order, OrderStatus newStatus, OrderProvider orderProvider) {
    orderProvider.updateOrderStatus(order.id, newStatus).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Sipariş durumu "${_getStatusText(newStatus)}" olarak güncellendi'),
          backgroundColor: Colors.green,
        ),
      );
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Durum güncelleme başarısız: $error'),
          backgroundColor: Colors.red,
        ),
      );
    });
  }

  void _shipOrder(OrderModel order, OrderProvider orderProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Kargo Bilgisi'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Kargo takip numarasını girin:'),
            const SizedBox(height: 12),
            TextField(
              decoration: const InputDecoration(
                hintText: 'Takip numarası...',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                // Store tracking number
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _confirmShipping(order, orderProvider);
            },
            child: const Text('Kargoya Ver'),
          ),
        ],
      ),
    );
  }

  void _confirmShipping(OrderModel order, OrderProvider orderProvider) {
    orderProvider.updateOrderStatus(order.id, OrderStatus.shipped).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sipariş kargoya verildi'),
          backgroundColor: Colors.green,
        ),
      );
    });
  }

  void _cancelOrder(OrderModel order, OrderProvider orderProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Siparişi İptal Et'),
        content: const Text('Bu siparişi iptal etmek istediğinizden emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Vazgeç'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _confirmCancel(order, orderProvider);
            },
            child: const Text(
              'İptal Et',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmCancel(OrderModel order, OrderProvider orderProvider) {
    orderProvider.cancelOrder(order.id).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sipariş iptal edildi'),
          backgroundColor: Colors.green,
        ),
      );
    });
  }

  void _contactCustomer(OrderModel order) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Müşteri İletişim',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.phone, color: Colors.green),
              title: const Text('Telefon'),
              subtitle: Text(order.customerPhone),
              onTap: () {
                // Implement phone call
                Navigator.of(context).pop();
              },
            ),
            ListTile(
              leading: const Icon(Icons.email, color: Colors.blue),
              title: const Text('E-posta'),
              subtitle: Text(order.customerEmail),
              onTap: () {
                // Implement email
                Navigator.of(context).pop();
              },
            ),
            ListTile(
              leading: const Icon(Icons.sms, color: Colors.orange),
              title: const Text('SMS Gönder'),
              onTap: () {
                // Implement SMS
                Navigator.of(context).pop();
              },
            ),
          ],
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

  String _getStatusText(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return 'Bekleyen';
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
}