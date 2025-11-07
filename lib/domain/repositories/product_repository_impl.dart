import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:photo_momento/domain/repositories/product_repository.dart';
import 'package:photo_momento/data/models/product_model.dart';
import 'package:photo_momento/core/exceptions/exceptions.dart';

class ProductRepositoryImpl implements ProductRepository {
  final FirebaseFirestore _firestore;

  ProductRepositoryImpl({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<List<ProductModel>> getProducts({
    String? category,
    bool? inStockOnly,
    bool? activeOnly,
  }) async {
    try {
      Query query = _firestore.collection('products');

      // Apply filters
      if (category != null && category.isNotEmpty) {
        query = query.where('category', isEqualTo: category);
      }

      if (activeOnly == true) {
        query = query.where('isActive', isEqualTo: true);
      }

      if (inStockOnly == true) {
        query = query.where('stock', isGreaterThan: 0);
      }

      // Order by creation date
      query = query.orderBy('createdAt', descending: true);

      final snapshot = await query.get();

      return snapshot.docs
          .map((doc) => ProductModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw ProductException('Ürünler yüklenirken hata oluştu: $e');
    }
  }

  @override
  Future<ProductModel> getProduct(String productId) async {
    try {
      final doc = await _firestore.collection('products').doc(productId).get();

      if (!doc.exists) {
        throw ProductException('Ürün bulunamadı');
      }

      return ProductModel.fromFirestore(doc);
    } catch (e) {
      throw ProductException('Ürün yüklenirken hata oluştu: $e');
    }
  }

  @override
  Future<List<ProductModel>> getFeaturedProducts() async {
    try {
      final snapshot = await _firestore
          .collection('products')
          .where('isActive', isEqualTo: true)
          .where('stock', isGreaterThan: 0)
          .orderBy('totalSales', descending: true)
          .limit(10)
          .get();

      return snapshot.docs
          .map((doc) => ProductModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw ProductException('Öne çıkan ürünler yüklenirken hata oluştu: $e');
    }
  }

  @override
  Future<void> updateProductStock(String productId, int newStock) async {
    try {
      await _firestore.collection('products').doc(productId).update({
        'stock': newStock,
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });
    } catch (e) {
      throw ProductException('Stok güncellenirken hata oluştu: $e');
    }
  }

  @override
  Stream<List<ProductModel>> streamProducts() {
    return _firestore
        .collection('products')
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => ProductModel.fromFirestore(doc))
        .toList())
        .handleError((error) {
      throw ProductException('Ürünler dinlenirken hata oluştu: $error');
    });
  }

  @override
  Future<List<ProductModel>> searchProducts(String query) async {
    try {
      // Basic search implementation
      // For more advanced search, consider using Algolia or similar
      final snapshot = await _firestore
          .collection('products')
          .where('isActive', isEqualTo: true)
          .get();

      final allProducts = snapshot.docs
          .map((doc) => ProductModel.fromFirestore(doc))
          .toList();

      return allProducts.where((product) {
        final searchLower = query.toLowerCase();
        return product.name.toLowerCase().contains(searchLower) ||
            product.category.toLowerCase().contains(searchLower) ||
            product.size.toLowerCase().contains(searchLower) ||
            product.paperType.toLowerCase().contains(searchLower);
      }).toList();
    } catch (e) {
      throw ProductException('Ürün arama sırasında hata oluştu: $e');
    }
  }

  @override
  Future<List<String>> getProductCategories() async {
    try {
      final snapshot = await _firestore
          .collection('products')
          .where('isActive', isEqualTo: true)
          .get();

      final categories = snapshot.docs
          .map((doc) => doc.data()['category'] as String? ?? '')
          .where((category) => category.isNotEmpty)
          .toSet()
          .toList();

      categories.sort();
      return categories;
    } catch (e) {
      throw ProductException('Kategoriler yüklenirken hata oluştu: $e');
    }
  }

  @override
  Future<List<ProductModel>> getLowStockProducts({int threshold = 10}) async {
    try {
      final snapshot = await _firestore
          .collection('products')
          .where('isActive', isEqualTo: true)
          .where('stock', isLessThanOrEqualTo: threshold)
          .orderBy('stock')
          .get();

      return snapshot.docs
          .map((doc) => ProductModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw ProductException('Düşük stoklu ürünler yüklenirken hata oluştu: $e');
    }
  }
}