import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:photo_momento/presentation/providers/order_provider.dart';
import 'package:photo_momento/presentation/widgets/custom_app_bar.dart';
import 'package:photo_momento/data/models/order_model.dart';

class OrderDetailScreen extends StatefulWidget {
  final String orderId;

  const OrderDetailScreen({
    super.key,
    required this.orderId,
  });

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  @override
  void initState() {
    super.initState();
    _loadOrder();
  }

  void _loadOrder() {
    final orderProvider = Provider.of<OrderProvider>(context, listen: false);
    orderProvider.loadOrder(widget.orderId);
  }

  @override
  Widget build(BuildContext context) {
    final orderProvider = Provider.of<OrderProvider>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
        title: 'Sipariş Detayı',
        showBackButton: true,
      ),
      body: orderProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : orderProvider.selectedOrder == null
          ? _buildOrderNotFound()
          : _buildOrderDetail(orderProvider.selectedOrder!),
    );
  }

  Widget _buildOrderNotFound() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 80,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 16),
          const Text(
            'Sipariş Bulunamadı',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          const Text('Bu sipariş mevcut değil veya erişiminiz yok'),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              context.pop();
            },
            child: const Text('Siparişlere Dön'),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderDetail(OrderModel order) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Order Header
          _buildOrderHeader(order),
          const SizedBox(height: 24),

          // Order Timeline
          _buildOrderTimeline(order),
          const SizedBox(height: 24),

          // Order Items
          _buildOrderItems(order),
          const SizedBox(height: 24),

          // Delivery Address
          _buildDeliveryAddress(order),
          const SizedBox(height: 24),

          // Payment Summary
          _buildPaymentSummary(order),
          const SizedBox(height: 24),

          // Order Actions
          _buildOrderActions(order),
        ],
      ),
    );
  }

  Widget _buildOrderHeader(OrderModel order) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  order.formattedOrderNumber,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getStatusColor(order.status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    _getStatusText(order.status),
                    style: TextStyle(
                      color: _getStatusColor(order.status),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Sipariş Tarihi: ${order.formattedDate}',
              style: TextStyle(
                color: Colors.grey.shade600,
              ),
            ),
            if (order.estimatedDelivery != null) ...[
              const SizedBox(height: 4),
              Text(
                'Tahmini Teslimat: ${_formatDate(order.estimatedDelivery!)}',
                style: TextStyle(
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildOrderTimeline(OrderModel order) {
    final statusSteps = _getStatusSteps(order.status);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Sipariş Durumu',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            ...statusSteps.asMap().entries.map((entry) {
              final index = entry.key;
              final step = entry.value;
              final isCompleted = index <= _getStatusIndex(order.status);
              final isCurrent = index == _getStatusIndex(order.status);

              return _buildTimelineStep(
                step['title']!,
                step['description']!,
                isCompleted: isCompleted,
                isCurrent: isCurrent,
                isLast: index == statusSteps.length - 1,
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineStep(
      String title,
      String description, {
        required bool isCompleted,
        required bool isCurrent,
        required bool isLast,
      }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Timeline Line and Dot
        Column(
          children: [
            // Dot
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: isCompleted ? Colors.green : (isCurrent ? Colors.blue : Colors.grey.shade300),
                shape: BoxShape.circle,
              ),
              child: isCompleted
                  ? const Icon(Icons.check, size: 14, color: Colors.white)
                  : isCurrent
                  ? const Icon(Icons.circle, size: 8, color: Colors.white)
                  : null,
            ),
            // Line
            if (!isLast)
              Container(
                width: 2,
                height: 40,
                color: isCompleted ? Colors.green : Colors.grey.shade300,
              ),
          ],
        ),
        const SizedBox(width: 12),
        // Content
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: isCompleted || isCurrent ? Colors.black : Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    color: isCompleted || isCurrent ? Colors.grey.shade600 : Colors.grey.shade400,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildOrderItems(OrderModel order) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Sipariş Kalemleri',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            ...order.items.map((item) => _buildOrderItem(item)).toList(),
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Toplam Ürün',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                Text(
                  '${order.totalItems} ürün',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderItem(OrderItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          // Product Image
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6),
              color: Colors.grey.shade200,
            ),
            child: item.imageUrls.isNotEmpty
                ? ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: Image.network(
                item.imageUrls.first,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(
                    Icons.photo,
                    color: Colors.grey.shade400,
                  );
                },
              ),
            )
                : Icon(
              Icons.photo,
              color: Colors.grey.shade400,
            ),
          ),
          const SizedBox(width: 12),
          // Product Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.productName,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${item.size} • ${item.paperType}',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${item.quantity} adet x ${item.formattedPrice}',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      item.formattedTotal,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeliveryAddress(OrderModel order) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Teslimat Adresi',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  Icons.location_on_outlined,
                  color: Colors.grey.shade600,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order.deliveryAddress.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(order.deliveryAddress.fullName),
                      Text(order.deliveryAddress.phone),
                      Text(order.deliveryAddress.addressLine1),
                      if (order.deliveryAddress.addressLine2 != null)
                        Text(order.deliveryAddress.addressLine2!),
                      Text(
                          '${order.deliveryAddress.district}/${order.deliveryAddress.city}'),
                      Text(order.deliveryAddress.postalCode),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentSummary(OrderModel order) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Ödeme Özeti',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            _buildPaymentRow('Ara Toplam', order.subtotal),
            _buildPaymentRow('Kargo Ücreti', order.shippingCost),
            if (order.discount > 0)
              _buildPaymentRow('İndirim', -order.discount),
            const Divider(),
            _buildPaymentRow('TOPLAM', order.total, isTotal: true),
            const SizedBox(height: 12),
            if (order.paymentMethod != null) ...[
              const Divider(),
              const SizedBox(height: 8),
              const Text(
                'Ödeme Yöntemi',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${order.paymentMethod!.cardHolder} •••• ${order.paymentMethod!.cardNumber.substring(order.paymentMethod!.cardNumber.length - 4)}',
                style: TextStyle(
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentRow(String label, double amount, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            '${amount.toStringAsFixed(2)}₺',
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: isTotal ? Colors.blue : null,
              fontSize: isTotal ? 16 : 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderActions(OrderModel order) {
    return Row(
      children: [
        if (order.canCancel)
          Expanded(
            child: OutlinedButton(
              onPressed: () => _cancelOrder(order),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: const BorderSide(color: Colors.red),
              ),
              child: const Text('Siparişi İptal Et'),
            ),
          ),
        if (order.canCancel) const SizedBox(width: 12),
        if (order.canTrack)
          Expanded(
            child: ElevatedButton(
              onPressed: () => _trackOrder(order),
              child: const Text('Kargoyu Takip Et'),
            ),
          ),
        if (!order.canCancel && !order.canTrack)
          const Expanded(
            child: Text(
              'Bu sipariş için mevcut işlem bulunmuyor',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
      ],
    );
  }

  void _trackOrder(OrderModel order) {
    if (order.shippingTrackingNumber != null) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Kargo Takip'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Sipariş: ${order.formattedOrderNumber}'),
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
    }
  }

  void _cancelOrder(OrderModel order) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Siparişi İptal Et'),
        content: const Text('Bu siparişi iptal etmek istediğinizden emin misiniz? Bu işlem geri alınamaz.'),
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

  List<Map<String, String>> _getStatusSteps(OrderStatus currentStatus) {
    return [
      {'title': 'Sipariş Alındı', 'description': 'Siparişiniz başarıyla oluşturuldu'},
      {'title': 'Ödeme Onaylandı', 'description': 'Ödemeniz onaylandı'},
      {'title': 'Baskı Hazırlanıyor', 'description': 'Fotoğraflarınız baskıya hazırlanıyor'},
      {'title': 'Baskı Tamamlandı', 'description': 'Tüm baskılar tamamlandı'},
      {'title': 'Kargoya Verildi', 'description': 'Siparişiniz kargoya verildi'},
      {'title': 'Teslim Edildi', 'description': 'Siparişiniz teslim edildi'},
    ];
  }

  int _getStatusIndex(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return 0;
      case OrderStatus.confirmed:
        return 1;
      case OrderStatus.processing:
        return 2;
      case OrderStatus.printing:
        return 3;
      case OrderStatus.ready:
        return 4;
      case OrderStatus.shipped:
        return 5;
      case OrderStatus.delivered:
        return 6;
      case OrderStatus.cancelled:
        return -1;
      case OrderStatus.refunded:
        return -1;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}