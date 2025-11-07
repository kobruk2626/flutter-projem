import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:photo_momento/presentation/providers/auth_provider.dart';
import 'package:photo_momento/presentation/providers/cart_provider.dart';
import 'package:photo_momento/presentation/providers/order_provider.dart';
import 'package:photo_momento/presentation/widgets/custom_app_bar.dart';
import 'package:photo_momento/presentation/widgets/loading_button.dart';
import 'package:photo_momento/data/models/order_model.dart';
import 'package:photo_momento/core/constants/app_constants.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  String? _promoCode;
  bool _isApplyingPromo = false;

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final orderProvider = Provider.of<OrderProvider>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
        title: 'Sepetim',
        showBackButton: true,
      ),
      body: cartProvider.items.isEmpty
          ? _buildEmptyCart()
          : _buildCartContent(cartProvider, authProvider, orderProvider),
    );
  }

  Widget _buildEmptyCart() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            size: 80,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 16),
          Text(
            'Sepetiniz Boş',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Henüz sepete ürün eklemediniz',
            style: TextStyle(
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              context.push('/new-order');
            },
            child: const Text('Alışverişe Başla'),
          ),
        ],
      ),
    );
  }

  Widget _buildCartContent(
      CartProvider cartProvider, AuthProvider authProvider, OrderProvider orderProvider) {
    return Column(
      children: [
        // Cart Items List
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Cart Items
                _buildCartItems(cartProvider),
                const SizedBox(height: 24),

                // Promo Code Section
                _buildPromoCodeSection(),
                const SizedBox(height: 24),

                // Order Summary
                _buildOrderSummary(cartProvider),
              ],
            ),
          ),
        ),

        // Checkout Section
        _buildCheckoutSection(cartProvider, authProvider, orderProvider),
      ],
    );
  }

  Widget _buildCartItems(CartProvider cartProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Sepetinizdeki Ürünler (${cartProvider.itemCount})',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),

        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: cartProvider.items.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final item = cartProvider.items[index];
            return _buildCartItem(item, index, cartProvider);
          },
        ),
      ],
    );
  }

  Widget _buildCartItem(OrderItem item, int index, CartProvider cartProvider) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.grey.shade200,
              ),
              child: item.imageUrls.isNotEmpty
                  ? ClipRRect(
                borderRadius: BorderRadius.circular(8),
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
                  Text(
                    item.formattedPrice,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),
            ),

            // Quantity Controls
            Column(
              children: [
                // Quantity
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    item.quantity.toString(),
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                // Quantity Buttons
                Row(
                  children: [
                    // Decrease
                    IconButton(
                      onPressed: () {
                        cartProvider.updateQuantity(index, item.quantity - 1);
                      },
                      icon: const Icon(Icons.remove, size: 16),
                      style: IconButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: const Size(24, 24),
                      ),
                    ),

                    // Increase
                    IconButton(
                      onPressed: () {
                        cartProvider.updateQuantity(index, item.quantity + 1);
                      },
                      icon: const Icon(Icons.add, size: 16),
                      style: IconButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: const Size(24, 24),
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(width: 8),

            // Remove Button
            IconButton(
              onPressed: () {
                cartProvider.removeFromCart(index);
              },
              icon: const Icon(Icons.delete_outline, size: 20),
              color: Colors.red.shade400,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPromoCodeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Promosyon Kodu',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),

        Row(
          children: [
            Expanded(
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Promosyon kodunuzu girin...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                ),
                onChanged: (value) {
                  _promoCode = value;
                },
              ),
            ),
            const SizedBox(width: 12),
            ElevatedButton(
              onPressed: _isApplyingPromo ? null : () {
                _applyPromoCode();
              },
              child: _isApplyingPromo
                  ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
                  : const Text('Uygula'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildOrderSummary(CartProvider cartProvider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            'Sipariş Özeti',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),

          // Summary Items
          _buildSummaryRow('Ara Toplam', cartProvider.subtotal),
          _buildSummaryRow('Kargo', cartProvider.shippingCost),
          _buildSummaryRow('İndirim', 0.0), // Would come from promo code
          const Divider(),
          _buildSummaryRow('Toplam', cartProvider.total, isTotal: true),

          // Free Shipping Info
          if (cartProvider.subtotal < AppConstants.freeShippingThreshold)
            Container(
              margin: const EdgeInsets.only(top: 8),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.local_shipping,
                    color: Colors.orange.shade600,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${(AppConstants.freeShippingThreshold - cartProvider.subtotal).toStringAsFixed(2)}₺ daha harcayarak kargo bedava!',
                      style: TextStyle(
                        color: Colors.orange.shade800,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, double amount, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.w600 : FontWeight.normal,
              color: isTotal ? Colors.blue : null,
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

  Widget _buildCheckoutSection(
      CartProvider cartProvider, AuthProvider authProvider, OrderProvider orderProvider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Colors.grey.shade300),
        ),
      ),
      child: Column(
        children: [
          // Total and Checkout Button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Toplam Tutar',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    '${cartProvider.total.toStringAsFixed(2)}₺',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),
              SizedBox(
                width: 200,
                child: LoadingButton(
                  isLoading: orderProvider.isLoading,
                  onPressed: cartProvider.isCartValid
                      ? () => _completeOrder(cartProvider, authProvider, orderProvider)
                      : null,
                  child: const Text(
                    'SİPARİŞİ TAMAMLA',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),

          // Validation Messages
          if (!cartProvider.isCartValid) ...[
            const SizedBox(height: 8),
            _buildValidationMessages(cartProvider),
          ],
        ],
      ),
    );
  }

  Widget _buildValidationMessages(CartProvider cartProvider) {
    final missingItems = <String>[];

    if (cartProvider.selectedAddress == null) {
      missingItems.add('teslimat adresi');
    }
    if (cartProvider.selectedPaymentMethod == null) {
      missingItems.add('ödeme yöntemi');
    }

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            color: Colors.orange.shade600,
            size: 16,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Siparişi tamamlamak için ${missingItems.join(' ve ')} seçmelisiniz',
              style: TextStyle(
                color: Colors.orange.shade800,
                fontSize: 12,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              // Navigate to profile to complete missing info
              context.push('/profile');
            },
            child: Text(
              'Tamamla',
              style: TextStyle(
                color: Colors.orange.shade800,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _applyPromoCode() {
    if (_promoCode == null || _promoCode!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lütfen promosyon kodunu girin'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isApplyingPromo = true;
    });

    // Simulate API call
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        _isApplyingPromo = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('"$_promoCode" kodu uygulandı'),
          backgroundColor: Colors.green,
        ),
      );
    });
  }

  Future<void> _completeOrder(
      CartProvider cartProvider, AuthProvider authProvider, OrderProvider orderProvider) async {
    try {
      final order = cartProvider.createOrder(
        authProvider.user!.id,
        authProvider.user!.name,
        authProvider.user!.email,
        authProvider.user!.phone ?? '',
      );

      final createdOrder = await orderProvider.createOrder(order);

      if (createdOrder != null) {
        // Clear cart
        cartProvider.clearCart();

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Siparişiniz başarıyla oluşturuldu!'),
            backgroundColor: Colors.green,
          ),
        );

        // Navigate to order detail
        context.push('/order/${createdOrder.id}');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Sipariş oluşturulurken hata: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}