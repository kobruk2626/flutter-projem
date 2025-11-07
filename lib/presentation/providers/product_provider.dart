import 'package:flutter/material.dart';
import 'package:photo_momento/domain/repositories/product_repository.dart';
import 'package:photo_momento/data/models/product_model.dart';
import 'package:photo_momento/data/repositories/product_repository_impl.dart';
import 'package:photo_momento/core/exceptions/exceptions.dart';

class ProductProvider with ChangeNotifier {
  final ProductRepository _productRepository;

  ProductProvider({ProductRepository? productRepository})
      : _productRepository = productRepository ?? ProductRepositoryImpl();

  List<ProductModel> _products = [];
  List<ProductModel> _featuredProducts = [];
  List<ProductModel> _lowStockProducts = [];
  bool _isLoading = false;
  String? _error;
  ProductModel? _selectedProduct;
  List<String> _categories = [];

  List<ProductModel> get products => _products;
  List<ProductModel> get featuredProducts => _featuredProducts;
  List<ProductModel> get lowStockProducts => _lowStockProducts;
  bool get isLoading => _isLoading;
  String? get error => _error;
  ProductModel? get selectedProduct => _selectedProduct;
  List<String> get categories => _categories;

  // Load all products
  Future<void> loadProducts({
    String? category,
    bool inStockOnly = false,
    bool activeOnly = true,
  }) async {
    try {
      _setLoading(true);
      _products = await _productRepository.getProducts(
        category: category,
        inStockOnly: inStockOnly,
        activeOnly: activeOnly,
      );
      _error = null;
    } on ProductException catch (e) {
      _error = e.message;
    } catch (e) {
      _error = 'Ürünler yüklenirken bir hata oluştu: $e';
    } finally {
      _setLoading(false);
    }
  }

  // Load featured products
  Future<void> loadFeaturedProducts() async {
    try {
      _setLoading(true);
      _featuredProducts = await _productRepository.getFeaturedProducts();
      _error = null;
    } on ProductException catch (e) {
      _error = e.message;
    } catch (e) {
      _error = 'Öne çıkan ürünler yüklenirken bir hata oluştu: $e';
    } finally {
      _setLoading(false);
    }
  }

  // Load low stock products
  Future<void> loadLowStockProducts({int threshold = 10}) async {
    try {
      _setLoading(true);
      _lowStockProducts = await _productRepository.getLowStockProducts(threshold: threshold);
      _error = null;
    } on ProductException catch (e) {
      _error = e.message;
    } catch (e) {
      _error = 'Düşük stoklu ürünler yüklenirken bir hata oluştu: $e';
    } finally {
      _setLoading(false);
    }
  }

  // Load categories
  Future<void> loadCategories() async {
    try {
      _categories = await _productRepository.getProductCategories();
      _error = null;
      notifyListeners();
    } on ProductException catch (e) {
      _error = e.message;
      notifyListeners();
    } catch (e) {
      _error = 'Kategoriler yüklenirken bir hata oluştu: $e';
      notifyListeners();
    }
  }

  // Get single product
  Future<void> loadProduct(String productId) async {
    try {
      _setLoading(true);
      _selectedProduct = await _productRepository.getProduct(productId);
      _error = null;
    } on ProductException catch (e) {
      _error = e.message;
    } catch (e) {
      _error = 'Ürün yüklenirken bir hata oluştu: $e';
    } finally {
      _setLoading(false);
    }
  }

  // Search products
  Future<void> searchProducts(String query) async {
    try {
      _setLoading(true);
      if (query.isEmpty) {
        await loadProducts();
      } else {
        _products = await _productRepository.searchProducts(query);
      }
      _error = null;
    } on ProductException catch (e) {
      _error = e.message;
    } catch (e) {
      _error = 'Ürün aranırken bir hata oluştu: $e';
    } finally {
      _setLoading(false);
    }
  }

  // Update product stock (for admin)
  Future<void> updateProductStock(String productId, int newStock) async {
    try {
      await _productRepository.updateProductStock(productId, newStock);

      // Update local state
      final index = _products.indexWhere((p) => p.id == productId);
      if (index != -1) {
        _products[index] = _products[index].copyWith(stock: newStock);
        notifyListeners();
      }

      // Update featured products if needed
      final featuredIndex = _featuredProducts.indexWhere((p) => p.id == productId);
      if (featuredIndex != -1) {
        _featuredProducts[featuredIndex] = _featuredProducts[featuredIndex].copyWith(stock: newStock);
        notifyListeners();
      }

      // Update low stock products if needed
      final lowStockIndex = _lowStockProducts.indexWhere((p) => p.id == productId);
      if (lowStockIndex != -1) {
        if (newStock > 10) { // threshold değeri
          _lowStockProducts.removeAt(lowStockIndex);
        } else {
          _lowStockProducts[lowStockIndex] = _lowStockProducts[lowStockIndex].copyWith(stock: newStock);
        }
        notifyListeners();
      }

      _error = null;
    } on ProductException catch (e) {
      _error = e.message;
      notifyListeners();
    } catch (e) {
      _error = 'Stok güncellenirken bir hata oluştu: $e';
      notifyListeners();
    }
  }

  // Get products by category
  List<ProductModel> getProductsByCategory(String category) {
    return _products.where((product) => product.category == category).toList();
  }

  // Get available products (in stock and active)
  List<ProductModel> get availableProducts {
    return _products.where((product) => product.isActive && product.stock > 0).toList();
  }

  // Get out of stock products
  List<ProductModel> get outOfStockProducts {
    return _products.where((product) => product.stock == 0).toList();
  }

  // Get low stock products from current list
  List<ProductModel> get currentLowStockProducts {
    return _products.where((product) => product.isLowStock).toList();
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Clear selected product
  void clearSelectedProduct() {
    _selectedProduct = null;
    notifyListeners();
  }

  // Set selected product
  void setSelectedProduct(ProductModel product) {
    _selectedProduct = product;
    notifyListeners();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }
}