import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:photo_momento/presentation/providers/auth_provider.dart';
import 'package:photo_momento/presentation/providers/product_provider.dart';
import 'package:photo_momento/presentation/widgets/custom_app_bar.dart';
import 'package:photo_momento/data/models/product_model.dart';

class AdminProductsScreen extends StatefulWidget {
  const AdminProductsScreen({super.key});

  @override
  State<AdminProductsScreen> createState() => _AdminProductsScreenState();
}

class _AdminProductsScreenState extends State<AdminProductsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'tumu';
  bool _showInactive = false;

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  void _loadProducts() {
    final productProvider = Provider.of<ProductProvider>(context, listen: false);
    productProvider.loadProducts();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final productProvider = Provider.of<ProductProvider>(context);

    if (!authProvider.isAdmin) {
      return _buildAccessDenied();
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
        title: 'Ürün Yönetimi',
        showBackButton: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              _addNewProduct();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search and Filter Section
          _buildSearchFilterSection(productProvider),

          // Products List
          Expanded(
            child: _buildProductsList(productProvider),
          ),
        ],
      ),
    );
  }

  Widget _buildAccessDenied() {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Ürün Yönetimi',
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

  Widget _buildSearchFilterSection(ProductProvider productProvider) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.grey.shade50,
      child: Column(
        children: [
          // Search Bar
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Ürün adı, boyut...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            ),
            onChanged: (value) {
              _applyFilters(productProvider);
            },
          ),
          const SizedBox(height: 12),

          // Filter Row
          Row(
            children: [
              // Category Filter
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  items: const [
                    DropdownMenuItem(value: 'tumu', child: Text('Tüm Kategoriler')),
                    DropdownMenuItem(value: 'photo_print', child: Text('Fotoğraf Baskı')),
                    DropdownMenuItem(value: 'canvas', child: Text('Canvas Baskı')),
                    DropdownMenuItem(value: 'album', child: Text('Albüm')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedCategory = value!;
                    });
                    _applyFilters(productProvider);
                  },
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Show Inactive Toggle
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Pasif Ürünler'),
                    Switch(
                      value: _showInactive,
                      onChanged: (value) {
                        setState(() {
                          _showInactive = value;
                        });
                        _applyFilters(productProvider);
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProductsList(ProductProvider productProvider) {
    if (productProvider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (productProvider.products.isEmpty) {
      return _buildEmptyProducts();
    }

    // Filter products
    final filteredProducts = productProvider.products.where((product) {
      final matchesCategory = _selectedCategory == 'tumu' || product.category == _selectedCategory;
      final matchesStatus = _showInactive || product.isActive;
      final query = _searchController.text.toLowerCase();
      final matchesSearch = query.isEmpty ||
          product.name.toLowerCase().contains(query) ||
          product.size.toLowerCase().contains(query) ||
          product.paperType.toLowerCase().contains(query);

      return matchesCategory && matchesStatus && matchesSearch;
    }).toList();

    if (filteredProducts.isEmpty) {
      return _buildNoProductsForFilter();
    }

    return RefreshIndicator(
      onRefresh: () async {
        await productProvider.loadProducts();
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: filteredProducts.length,
        itemBuilder: (context, index) {
          final product = filteredProducts[index];
          return _buildProductCard(product, productProvider);
        },
      ),
    );
  }

  Widget _buildProductCard(ProductModel product, ProductProvider productProvider) {
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
                        product.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${product.size} • ${product.paperType}',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    // Status Badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: product.isActive
                            ? Colors.green.withOpacity(0.1)
                            : Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        product.isActive ? 'Aktif' : 'Pasif',
                        style: TextStyle(
                          color: product.isActive ? Colors.green : Colors.red,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Stock Badge
                    if (product.isLowStock)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'Az Stok',
                          style: TextStyle(
                            color: Colors.orange.shade700,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Product Details
            Row(
              children: [
                // Product Image
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.grey.shade200,
                  ),
                  child: product.imageUrl.startsWith('http')
                      ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      product.imageUrl,
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

                // Product Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            product.formattedPrice,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                          Text(
                            'Stok: ${product.stock}',
                            style: TextStyle(
                              color: product.isLowStock ? Colors.orange : Colors.grey.shade600,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Min. Stok: ${product.minStock}',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        'Toplam Satış: ${product.totalSales}',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Actions
            _buildProductActions(product, productProvider),
          ],
        ),
      ),
    );
  }

  Widget _buildProductActions(ProductModel product, ProductProvider productProvider) {
    return Row(
      children: [
        // Edit Button
        Expanded(
          child: OutlinedButton(
            onPressed: () {
              _editProduct(product);
            },
            child: const Text('Düzenle'),
          ),
        ),
        const SizedBox(width: 8),

        // Stock Management
        Expanded(
          child: OutlinedButton(
            onPressed: () {
              _manageStock(product, productProvider);
            },
            child: const Text('Stok Yönet'),
          ),
        ),
        const SizedBox(width: 8),

        // Toggle Status
        IconButton(
          onPressed: () {
            _toggleProductStatus(product, productProvider);
          },
          icon: Icon(
            product.isActive ? Icons.pause : Icons.play_arrow,
            color: product.isActive ? Colors.orange : Colors.green,
          ),
        ),

        // Delete Button
        IconButton(
          onPressed: () {
            _deleteProduct(product, productProvider);
          },
          icon: const Icon(Icons.delete, color: Colors.red),
        ),
      ],
    );
  }

  Widget _buildEmptyProducts() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.photo_library_outlined,
            size: 80,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 16),
          const Text(
            'Henüz Ürün Yok',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          const Text('İlk ürününüzü ekleyerek başlayın'),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _addNewProduct,
            child: const Text('Ürün Ekle'),
          ),
        ],
      ),
    );
  }

  Widget _buildNoProductsForFilter() {
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
            'Bu Filtreye Uygun Ürün Yok',
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
                _selectedCategory = 'tumu';
                _showInactive = false;
                _searchController.clear();
              });
            },
            child: const Text('Filtreyi Temizle'),
          ),
        ],
      ),
    );
  }

  void _applyFilters(ProductProvider productProvider) {
    setState(() {});
  }

  void _addNewProduct() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Yeni Ürün Ekle'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Yeni ürün ekleme özelliği yakında eklenecek.'),
            SizedBox(height: 8),
            Text('Şu an için ürünleri Firebase Console üzerinden ekleyebilirsiniz.'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Tamam'),
          ),
        ],
      ),
    );
  }

  void _editProduct(ProductModel product) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ürünü Düzenle'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Ürün düzenleme özelliği yakında eklenecek.'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Tamam'),
          ),
        ],
      ),
    );
  }

  void _manageStock(ProductModel product, ProductProvider productProvider) {
    final stockController = TextEditingController(text: product.stock.toString());

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Stok Yönetimi - ${product.name}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Mevcut Stok: ${product.stock}'),
            Text('Minimum Stok: ${product.minStock}'),
            const SizedBox(height: 16),
            TextField(
              controller: stockController,
              decoration: const InputDecoration(
                labelText: 'Yeni Stok Miktarı',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
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
              final newStock = int.tryParse(stockController.text);
              if (newStock != null && newStock >= 0) {
                Navigator.of(context).pop();
                _updateStock(product, newStock, productProvider);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Geçerli bir stok miktarı girin'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: const Text('Güncelle'),
          ),
        ],
      ),
    );
  }

  void _updateStock(ProductModel product, int newStock, ProductProvider productProvider) {
    productProvider.updateProductStock(product.id, newStock).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Stok miktarı $newStock olarak güncellendi'),
          backgroundColor: Colors.green,
        ),
      );
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Stok güncelleme başarısız: $error'),
          backgroundColor: Colors.red,
        ),
      );
    });
  }

  void _toggleProductStatus(ProductModel product, ProductProvider productProvider) {
    final newStatus = !product.isActive;
    final statusText = newStatus ? 'aktif' : 'pasif';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ürün Durumu'),
        content: Text('Bu ürünü $statusText yapmak istiyor musunuz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // In a real app, you would update the product status in the database
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Ürün $statusText yapıldı'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('Onayla'),
          ),
        ],
      ),
    );
  }

  void _deleteProduct(ProductModel product, ProductProvider productProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ürünü Sil'),
        content: const Text('Bu ürünü silmek istediğinizden emin misiniz? Bu işlem geri alınamaz.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // In a real app, you would delete the product from the database
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Ürün silme özelliği yakında eklenecek'),
                  backgroundColor: Colors.orange,
                ),
              );
            },
            child: const Text(
              'Sil',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}