import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:photo_momento/presentation/providers/auth_provider.dart';
import 'package:photo_momento/presentation/providers/cart_provider.dart';
import 'package:photo_momento/presentation/providers/product_provider.dart';
import 'package:photo_momento/presentation/widgets/custom_app_bar.dart';
import 'package:photo_momento/presentation/widgets/loading_button.dart';
import 'package:photo_momento/data/models/product_model.dart';
import 'package:photo_momento/core/services/photo_service.dart';

class NewOrderScreen extends StatefulWidget {
  const NewOrderScreen({super.key});

  @override
  State<NewOrderScreen> createState() => _NewOrderScreenState();
}

class _NewOrderScreenState extends State<NewOrderScreen> {
  final PhotoService _photoService = PhotoService();

  ProductModel? _selectedProduct;
  String _selectedPaperType = 'glossy';
  int _quantity = 1;
  List<String> _selectedPhotos = [];
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  void _loadProducts() {
    final productProvider = Provider.of<ProductProvider>(context, listen: false);
    productProvider.loadProducts(activeOnly: true, inStockOnly: true);
  }

  @override
  Widget build(BuildContext context) {
    final productProvider = Provider.of<ProductProvider>(context);
    final cartProvider = Provider.of<CartProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
        title: 'Yeni Sipariş',
        showBackButton: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Selection
            _buildProductSelection(productProvider),

            const SizedBox(height: 24),

            // Paper Type Selection
            if (_selectedProduct != null) _buildPaperTypeSelection(),

            const SizedBox(height: 24),

            // Photo Selection
            if (_selectedProduct != null) _buildPhotoSelection(authProvider),

            const SizedBox(height: 24),

            // Quantity Selection
            if (_selectedProduct != null) _buildQuantitySelection(),

            const SizedBox(height: 24),

            // Special Note
            if (_selectedProduct != null) _buildSpecialNote(),

            const SizedBox(height: 32),

            // Add to Cart Button
            if (_selectedProduct != null) _buildAddToCartButton(cartProvider),
          ],
        ),
      ),
    );
  }

  Widget _buildProductSelection(ProductProvider productProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Ürün Seçimi',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),

        if (productProvider.isLoading)
          const Center(child: CircularProgressIndicator()),

        if (!productProvider.isLoading && productProvider.products.isEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: Text('Henüz ürün bulunmuyor'),
            ),
          ),

        if (!productProvider.isLoading && productProvider.products.isNotEmpty)
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.2,
            ),
            itemCount: productProvider.products.length,
            itemBuilder: (context, index) {
              final product = productProvider.products[index];
              return _buildProductCard(product);
            },
          ),
      ],
    );
  }

  Widget _buildProductCard(ProductModel product) {
    final isSelected = _selectedProduct?.id == product.id;

    return Card(
      elevation: isSelected ? 4 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected ? Colors.blue : Colors.transparent,
          width: isSelected ? 2 : 0,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            setState(() {
              _selectedProduct = product;
              _selectedPaperType = product.paperType;
              _quantity = 1;
              _selectedPhotos.clear();
            });
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Product Info
                Column(
                  children: [
                    Text(
                      product.size,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      product.paperType,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),

                // Price
                Text(
                  product.formattedPrice,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),

                // Stock Info
                if (product.isLowStock)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade100,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'Az Stok',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.orange.shade800,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPaperTypeSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Kağıt Tipi',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),

        Row(
          children: [
            _buildPaperTypeOption('Parlak', 'glossy'),
            const SizedBox(width: 12),
            _buildPaperTypeOption('Mat', 'matte'),
          ],
        ),
      ],
    );
  }

  Widget _buildPaperTypeOption(String title, String value) {
    final isSelected = _selectedPaperType == value;

    return Expanded(
      child: Card(
        elevation: isSelected ? 4 : 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: isSelected ? Colors.blue : Colors.transparent,
            width: isSelected ? 2 : 0,
          ),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              setState(() {
                _selectedPaperType = value;
              });
            },
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Icon(
                    Icons.photo,
                    color: isSelected ? Colors.blue : Colors.grey.shade600,
                    size: 32,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: isSelected ? Colors.blue : Colors.grey.shade800,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPhotoSelection(AuthProvider authProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Fotoğraf Seçimi',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),

        // Photo Selection Buttons
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _isUploading ? null : () => _pickPhotosFromGallery(authProvider),
                icon: const Icon(Icons.photo_library),
                label: const Text('Galeriden Seç'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _isUploading ? null : () => _takePhotoWithCamera(authProvider),
                icon: const Icon(Icons.camera_alt),
                label: const Text('Kamera'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // Selected Photos Grid
        if (_selectedPhotos.isNotEmpty) _buildSelectedPhotosGrid(),

        // Uploading Indicator
        if (_isUploading)
          Container(
            padding: const EdgeInsets.all(16),
            child: const Column(
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 8),
                Text('Fotoğraflar yükleniyor...'),
              ],
            ),
          ),

        // Selection Info
        if (_selectedPhotos.isEmpty && !_isUploading)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                'Fotoğraf seçmek için yukarıdaki butonları kullanın\n(Maksimum ${AppConstants.maxPhotosPerOrder} fotoğraf)',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey.shade600,
                ),
              ),
            ),
          ),

        if (_selectedPhotos.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              'Seçili: ${_selectedPhotos.length}/${AppConstants.maxPhotosPerOrder} fotoğraf',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildSelectedPhotosGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 1,
      ),
      itemCount: _selectedPhotos.length,
      itemBuilder: (context, index) {
        return Stack(
          children: [
            // Photo
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                image: DecorationImage(
                  image: NetworkImage(_selectedPhotos[index]),
                  fit: BoxFit.cover,
                ),
              ),
            ),

            // Delete Button
            Positioned(
              top: 4,
              right: 4,
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedPhotos.removeAt(index);
                  });
                },
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.close,
                    color: Colors.white,
                    size: 12,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildQuantitySelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Adet',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),

        Row(
          children: [
            // Decrease Button
            IconButton(
              onPressed: _quantity > 1 ? () {
                setState(() {
                  _quantity--;
                });
              } : null,
              icon: const Icon(Icons.remove),
              style: IconButton.styleFrom(
                backgroundColor: Colors.grey.shade200,
              ),
            ),

            // Quantity Display
            Container(
              width: 60,
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _quantity.toString(),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            // Increase Button
            IconButton(
              onPressed: _quantity < 50 ? () {
                setState(() {
                  _quantity++;
                });
              } : null,
              icon: const Icon(Icons.add),
              style: IconButton.styleFrom(
                backgroundColor: Colors.grey.shade200,
              ),
            ),

            const Spacer(),

            // Total Price
            Text(
              'Toplam: ${(_selectedProduct!.price * _quantity).toStringAsFixed(2)}₺',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSpecialNote() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Özel Not (İsteğe Bağlı)',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),

        TextField(
          maxLines: 3,
          decoration: InputDecoration(
            hintText: 'Siparişinizle ilgili özel bir notunuz varsa buraya yazabilirsiniz...',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            contentPadding: const EdgeInsets.all(16),
          ),
          onChanged: (value) {
            // Special note will be handled by cart provider
          },
        ),
      ],
    );
  }

  Widget _buildAddToCartButton(CartProvider cartProvider) {
    final totalPrice = _selectedProduct!.price * _quantity;
    final isPhotoSelected = _selectedPhotos.isNotEmpty;

    return LoadingButton(
      isLoading: cartProvider.isLoading,
      onPressed: isPhotoSelected ? () {
        _addToCart(cartProvider);
      } : null,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.shopping_cart, size: 20),
          const SizedBox(width: 8),
          Text(
            'SEPETE EKLE - ${totalPrice.toStringAsFixed(2)}₺',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // Photo Selection Methods
  Future<void> _pickPhotosFromGallery(AuthProvider authProvider) async {
    if (!authProvider.isLoggedIn) {
      _showLoginRequiredDialog();
      return;
    }

    try {
      setState(() {
        _isUploading = true;
      });

      final photos = await _photoService.pickAndUploadPhotos(
        userId: authProvider.user!.id,
        maxPhotos: AppConstants.maxPhotosPerOrder - _selectedPhotos.length,
      );

      setState(() {
        _selectedPhotos.addAll(photos);
        _isUploading = false;
      });
    } on PhotoException catch (e) {
      setState(() {
        _isUploading = false;
      });
      _showErrorDialog(e.message);
    }
  }

  Future<void> _takePhotoWithCamera(AuthProvider authProvider) async {
    if (!authProvider.isLoggedIn) {
      _showLoginRequiredDialog();
      return;
    }

    // Camera functionality would be implemented here
    // For now, we'll use the same gallery picker
    await _pickPhotosFromGallery(authProvider);
  }

  void _addToCart(CartProvider cartProvider) {
    if (_selectedProduct == null || _selectedPhotos.isEmpty) return;

    // Create a temporary product with selected paper type
    final productWithSelectedPaper = _selectedProduct!.copyWith(
      paperType: _selectedPaperType,
    );

    cartProvider.addToCart(
      productWithSelectedPaper,
      _quantity,
      _selectedPhotos,
    );

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${_selectedProduct!.size} ürünü sepete eklendi'),
        backgroundColor: Colors.green,
      ),
    );

    // Navigate back or to cart
    context.pop();
  }

  void _showLoginRequiredDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Giriş Gerekli'),
        content: const Text('Fotoğraf yüklemek için giriş yapmalısınız'),
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

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hata'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Tamam'),
          ),
        ],
      ),
    );
  }
}