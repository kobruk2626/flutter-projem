import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:photo_momento/presentation/providers/auth_provider.dart';
import 'package:photo_momento/presentation/providers/order_provider.dart';
import 'package:photo_momento/presentation/widgets/custom_app_bar.dart';
import 'package:photo_momento/data/models/order_model.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  final TextEditingController _searchController = TextEditingController();
  OrderStatus? _selectedFilter;

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  void _loadOrders() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final orderProvider = Provider.of<OrderProvider>(context, listen: false);

    if (authProvider.isLoggedIn) {
      orderProvider.loadUserOrders(authProvider.user!.id);
      orderProvider.initializeUserOrdersStream(authProvider.user!.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final orderProvider = Provider.of<OrderProvider>(context);

    if (!authProvider.isLoggedIn) {
      return _buildLoginRequired();
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
        title: 'Siparişlerim',
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

  Widget _buildLoginRequired() {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Siparişlerim',
        showBackButton: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.list_alt,
              size: 80,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 16),
            Text(
              'Siparişlerinizi Görüntülemek İçin',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Giriş yapmalısınız',
              style: TextStyle(
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                context.push('/login');
              },
              child: const Text('Giriş Yap'),
            ),
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
              hintText: 'Sipariş no, ürün adı...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            ),
            onChanged: (value) {
              // Search functionality would be implemented here
            },
          ),
          const SizedBox(height: 12),

          // Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip('Tümü', null, orderProvider),
                _buildFilterChip('Bekleyen', OrderStatus.pending, orderProvider),
                _buildFilterChip('Baskıda', OrderStatus.printing, orderProvider),
                _buildFilterChip('Kargoda', OrderStatus.shipped, orderProvider),
                _buildFilterChip('Tamamlanan', OrderStatus.delivered, orderProvider),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, OrderStatus? status, OrderProvider orderProvider) {
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
          _applyFilter(orderProvider);
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

    if (orderProvider.orders.isEmpty) {
      return _buildEmptyOrders();
    }

    // Filter orders if a filter is selected
    final filteredOrders = _selectedFilter == null
        ? orderProvider.orders
        : orderProvider.orders.where((order) => order.status == _selectedFilter).toList();

    if (filteredOrders.isEmpty) {
      return _buildNoOrdersForFilter();
    }

    return RefreshIndicator(
      onRefresh: () async {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        await orderProvider.loadUserOrders(authProvider.user!.id);
      },
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: filteredOrders.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final order = filteredOrders[index];
          return _buildOrderCard(order);
        },
      ),
    );
  }

  Widget _buildOrderCard(OrderModel order) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header - Order Number & Status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  order.formattedOrderNumber,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
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

            const SizedBox(height: 8),

            // Order Details
            Text(
              '${order.totalItems} ürün • ${order.formattedTotal}',
              style: TextStyle(
                color: Colors.grey.shade600,
              ),
            ),

            const SizedBox(height: 4),

            Text(
              order.formattedDate,
              style: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 12,
              ),
            ),

            const SizedBox(height: 12),

            // Order Items Preview
            _buildOrderItemsPreview(order),

            const SizedBox(height: 12),

            // Actions
            _buildOrderActions(order),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderItemsPreview(OrderModel order) {
    final previewItems = order.items.take(2).toList();
    final hasMoreItems = order.items.length > 2;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...previewItems.map((item) => Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Row(
            children: [
              Container(
                width: 4,
                height: 4,
                decoration: const BoxDecoration(
                  color: Colors.grey,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${item.productName} (${item.quantity} adet)',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        )),
        if (hasMoreItems)
          Text(
            '+ ${order.items.length - 2} daha...',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade500,
              fontStyle: FontStyle.italic,
            ),
          ),
      ],
    );
  }

  Widget _buildOrderActions(OrderModel order) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () {
              context.push('/order/${order.id}');
            },
            child: const Text('Detayları Gör'),
          ),
        ),
        const SizedBox(width: 8),
        if (order.canTrack)
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                _trackOrder(order);
              },
              child: const Text('Kargoyu Takip Et'),
            ),
          ),
        if (order.canCancel) ...[
          const SizedBox(width: 8),
          IconButton(
            onPressed: () {
              _cancelOrder(order);
            },
            icon: const Icon(Icons.cancel_outlined),
            color: Colors.red,
          ),
        ],
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
          Text(
            'Henüz Siparişiniz Yok',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'İlk siparişinizi oluşturmak için hemen başlayın',
            style: TextStyle(
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              context.push('/new-order');
            },
            child: const Text('Yeni Sipariş Oluştur'),
          ),
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
          Text(
            'Bu Filtreye Uygun Sipariş Yok',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Farklı bir filtre seçin veya filtreyi temizleyin',
            style: TextStyle(
              color: Colors.grey.shade600,
            ),
          ),
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

  void _applyFilter(OrderProvider orderProvider) {
    // Filtering is handled in the build method
    setState(() {});
  }

  void _trackOrder(OrderModel order) {
    if (order.shippingTrackingNumber != null) {
      // Open tracking URL or show tracking dialog
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Kargo Takip'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Sipariş No: ${order.formattedOrderNumber}'),
              Text('Takip No: ${order.shippingTrackingNumber}'),
              const SizedBox(height: 16),
              const Text('Kargo firmasının web sitesinden takip edebilirsiniz.'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Kapat'),
            ),
          ],
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Bu sipariş için henüz kargo takip numarası bulunmuyor'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  void _cancelOrder(OrderModel order) {
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
              _confirmCancelOrder(order);
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

  void _confirmCancelOrder(OrderModel order) {
    final orderProvider = Provider.of<OrderProvider>(context, listen: false);

    orderProvider.cancelOrder(order.id).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sipariş iptal edildi'),
          backgroundColor: Colors.green,
        ),
      );
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('İptal işlemi başarısız: $error'),
          backgroundColor: Colors.red,
        ),
      );
    });
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
}